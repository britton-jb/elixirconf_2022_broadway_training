defmodule NotificationService.Notifications.NotificationConsumer do
  use Broadway

  require Logger

  alias Broadway.Message
  alias NotificationService.Notifications

  @retry_queue "retry_notifications"

  def start_link(_opts) do
    producer_module = Application.fetch_env!(:notification_service, :producer_module)

    Notifications.Publisher.declare_queue(@retry_queue)

    Broadway.start_link(__MODULE__,
      name: __MODULE__,
      producer: [
        module: producer_module,
        concurrency: 1,
        rate_limiting: [allowed_messages: 5, interval: 5000]
      ],
      processors: [default: [concurrency: 2]],
      batchers: [default: [batch_size: 10], duplicate: [batch_size: 100]]
    )
  end

  @impl true
  def prepare_messages(messages, _context) do
    messages
  end

  @impl true
  def handle_message(_processor, %Message{data: message_data} = message, _context) do
    %{
      "payload" => %{
        "after" =>
          %{
            "current_x" => current_x,
            "current_y" => current_y,
            "start_x" => start_x,
            "start_y" => start_y
          } = vehicle_map
      }
    } = decoded = Jason.decode!(message_data)

    vehicle_map = Map.put(vehicle_map, :type, :vehicle)

    distance_from_start =
      :math.sqrt(:math.pow(current_x - start_x, 2) + :math.pow(current_y - start_y, 2))

    Message.update_data(message, fn _data ->
      decoded
      |> Map.put(:distance_from_start, distance_from_start)
      |> Map.put(:vehicle_map, vehicle_map)
    end)
  end

  @impl true
  def handle_batch(:default, messages, _batch_info, _context) do
    Logger.info("Batching messages #{inspect(messages)}")

    messages
    |> Enum.map(& Map.take(&1.data.vehicle_map, [:type]))
    |> Notifications.insert_all()

    Enum.map(messages, fn message ->
      {message.data.vehicle_map["id"], message.data.distance_from_start}
      |> Notifications.send_notification()
      |> case do
        :ok -> message
        {:error, _reason} -> Broadway.Message.failed(message, "Failed to send notification")
      end
    end)
  end
end
