defmodule VehicleService.VehicleDrivingConsumer do
  use Broadway

  require Logger

  alias AMQP.{Basic, Channel, Connection, Queue}

  alias Broadway.Message
  alias VehicleService.{Vehicles, Vehicle, Journies}
  alias Ecto.Changeset

  def queue_name, do: "vehicle_journies"

  def start_link(_opts) do
    Logger.info("STARTING DRIVING CONSUMER")
    producer_module = Application.fetch_env!(:vehicle_service, :driving_producer_module)

    {:ok, connection} = Connection.open()
    {:ok, channel} = Channel.open(connection)
    Queue.declare(channel, queue_name())
    Connection.close(connection)

    Broadway.start_link(__MODULE__,
      name: VehicleService.VehicleDrivingConsumer,
      producer: [module: producer_module],
      processors: [default: [concurrency: 5]],
      batchers: [
        driving: [batch_size: 100],
        journey_complete: [batch_size: 10],
        out_of_bounds: [batch_size: 50]
      ]
    )
  end

  @impl true
  def prepare_messages(messages, _context) do
    vehicles_by_id =
      messages
      |> Enum.map(& &1.data)
      |> Vehicles.get_all()
      |> Map.new(fn vehicle -> {"#{vehicle.id}", vehicle} end)

    Enum.map(messages, fn message ->
      case Message.put_data(message, vehicles_by_id[message.data]) do
        %Message{data: nil} -> Message.failed(message, "Could not find associated vehicle")
        message -> message
      end
    end)
  end

  @impl true
  def handle_message(_processor, %Message{status: {:failed, _}} = message, _context), do: message

  @impl true
  def handle_message(_processor, %Message{data: vehicle} = message, _context) do
    {new_x, new_y} = Journies.increment_step(vehicle)
    is_destination_reached? = Journies.is_destination_reached?(vehicle)

    vehicle_update_changeset =
      Vehicle.update_changeset(vehicle, %{
        current_x: new_x,
        current_y: new_y,
        is_on_journey: not is_destination_reached?
      })

    case {vehicle_update_changeset, is_destination_reached?} do
      # Out of bounds
      {%Changeset{valid?: false}, _is_destination_reached} ->
        Message.put_batcher(message, :out_of_bounds)

      # Still driving
      {%Changeset{valid?: true} = changeset, false} ->
        message
        |> Message.put_data(extract_update_map_from_changeset(changeset))
        |> Message.put_batcher(:driving)

      # Driving complete
      {%Changeset{valid?: true} = changeset, true} ->
        message
        |> Message.put_data(extract_update_map_from_changeset(changeset))
        |> Message.put_batcher(:journey_complete)
    end
  end

  defp extract_update_map_from_changeset(changeset) do
    changeset
    |> Changeset.apply_changes()
    |> Map.from_struct()
    |> Map.drop([:__meta__])
  end

  @impl true
  def handle_batch(:journey_complete, messages, _batch_info, _context) do
    {:ok, _vehicles} =
      messages
      |> Enum.map(fn %Message{data: changes_map} -> changes_map end)
      |> Vehicles.update_all()

    messages
  end

  @impl true
  def handle_batch(:driving, messages, _batch_info, _context) do
    {:ok, vehicles} =
      messages
      |> Enum.map(fn %Message{data: changes_map} -> changes_map end)
      |> Vehicles.update_all()

    {:ok, connection} = Connection.open()
    {:ok, channel} = Channel.open(connection)

    vehicles
    |> Enum.map(& &1.id)
    |> Enum.each(fn vehicle_id ->
      Basic.publish(channel, "", queue_name(), vehicle_id)
    end)

    Connection.close(connection)

    messages
  end

  @impl true
  def handle_batch(:out_of_bounds, messages, _batch_info, _context) do
    {:ok, connection} = Connection.open()
    {:ok, channel} = Channel.open(connection)

    messages
    |> Enum.map(fn %Message{data: %Vehicle{id: vehicle_id}} -> vehicle_id end)
    |> Enum.each(fn vehicle_id ->
      Basic.publish(channel, "", queue_name(), vehicle_id)
    end)

    Connection.close(connection)

    messages
  end

  @impl true
  def handle_failed(messages, _context) do
    Logger.warn("Failed to drive vehicles: #{inspect(messages)}")
    messages
  end
end
