import Config

config :vehicle_service, VehicleService.Repo,
  username: "postgres",
  password: "postgres",
  hostname: "localhost",
  database: "notification_service_test#{System.get_env("MIX_TEST_PARTITION")}",
  pool: Ecto.Adapters.SQL.Sandbox,
  pool_size: 10,
  port: "5433"

config :vehicle_service, :naive_producer_module, {Broadway.DummyProducer, []}
config :vehicle_service, :producer_module, {Broadway.DummyProducer, []}
config :vehicle_service, :driving_producer_module, {Broadway.DummyProducer, []}
