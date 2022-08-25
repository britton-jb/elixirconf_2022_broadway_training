defmodule VehicleService.NaiveVehicleRegistryConsumer do
  use Broadway

  require Logger

  alias Broadway.Message
  alias VehicleService.Vehicles

  def start_link(_opts) do
    producer_module = Application.fetch_env!(:vehicle_service, :naive_producer_module)

    Broadway.start_link(__MODULE__,
      name: VehicleService.NaiveVehicleRegistryConsumer,
      producer: [module: producer_module],
      processors: [default: [concurrency: 2]]
    )
  end

  @impl true
  def handle_message(_processor, %Message{data: vehicle_registry_json} = message, _context) do
    Logger.info("Handling message #{vehicle_registry_json}")

    decoded = Jason.decode!(vehicle_registry_json)

    case Vehicles.insert(decoded) do
      {:ok, _} -> message
      {:error, _error} -> Broadway.Message.failed(message, "Ignored error - failed to insert")
    end
  end
end
