import Config

config :vehicle_service, ecto_repos: [VehicleService.Repo]

config :vehicle_service, VehicleService.Repo,
  database: "vehicle_service",
  username: "postgres",
  password: "postgres",
  hostname: "localhost",
  port: "5433"

config :vehicle_service,
       :naive_producer_module,
       {BroadwayRabbitMQ.Producer, queue: "vehicle_registry", on_failure: :reject_and_requeue}

config :vehicle_service,
       :producer_module,
       {BroadwayRabbitMQ.Producer, queue: "vehicle_registry", on_failure: :ack}

config :vehicle_service,
       :driving_producer_module,
       {BroadwayRabbitMQ.Producer, queue: "vehicle_journeys", on_failure: :ack}

if config_env() == :test do
  import_config "#{config_env()}.exs"
end
