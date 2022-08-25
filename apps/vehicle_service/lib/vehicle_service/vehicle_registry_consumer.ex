defmodule VehicleService.VehicleRegistryConsumer do
  use Broadway

  require Logger

  alias AMQP.{Basic, Channel, Connection, Queue}
  alias Broadway.Message
  alias VehicleService.{Vehicles, Vehicle}

  @queue_name "vehicle_registry"
  @failed_queue "vehicle_registry.dlq"

  def start_link(_opts) do
    Logger.info("STARTING REGISTRY CONSUMER")
    producer_module = Application.fetch_env!(:vehicle_service, :producer_module)

    {:ok, connection} = Connection.open()
    {:ok, channel} = Channel.open(connection)
    Queue.declare(channel, @queue_name)
    Queue.declare(channel, @failed_queue)

    Broadway.start_link(__MODULE__,
      name: VehicleService.VehicleRegistryConsumer,
      producer: [module: producer_module],
      processors: [default: [concurrency: 2]],
      batchers: [default: [batch_size: 10]]
    )
  end

  @doc """
  For handling CPU bound tasks
  """
  @impl true
  def handle_message(_processor, %Message{data: vehicle_registry_json} = message, _context) do
    Logger.debug("Handling message #{inspect(vehicle_registry_json)}")

    decoded_vehicle_registry = Jason.decode!(vehicle_registry_json)
    changeset = Vehicle.insert_changeset(decoded_vehicle_registry)

    if changeset.valid? do
      now = NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second)

      vehicle_map =
        Map.merge(%{is_on_journey: true, inserted_at: now, updated_at: now}, changeset.changes)

      Broadway.Message.put_data(message, vehicle_map)
    else
      Broadway.Message.failed(message, "Invalid changeset")
    end
  end

  @impl true
  def handle_batch(batcher, messages, batch_info, _context) do
    Logger.debug("Batching message #{inspect(messages)}")
    Logger.debug("Batcher: #{inspect(batcher)}")
    Logger.debug("Batch Info: #{inspect(batch_info)}")

    {:ok, _vehicles} =
      messages
      |> Enum.map(& &1.data)
      |> Vehicles.bulk_insert()

    messages
  end

  @impl true
  def handle_failed(messages, _context) do
    Logger.error("Failed: #{inspect(messages)}")
    {:ok, connection} = Connection.open()
    {:ok, channel} = Channel.open(connection)
    Enum.each(messages, &Basic.publish(channel, "", @failed_queue, &1))
    messages
  end
end
