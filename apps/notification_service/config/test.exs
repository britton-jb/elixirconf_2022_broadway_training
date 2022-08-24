import Config

# Configure your database
#
# The MIX_TEST_PARTITION environment variable can be used
# to provide built-in test partitioning in CI environment.
# Run `mix help test` for more information.
config :notification_service, NotificationService.Repo,
  username: "postgres",
  password: "postgres",
  hostname: "localhost",
  port: "5433",
  database: "notification_service_test#{System.get_env("MIX_TEST_PARTITION")}",
  pool: Ecto.Adapters.SQL.Sandbox,
  pool_size: 10

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :notification_service, NotificationServiceWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "Kcw+eo2YyX9Fh96Yp7jAntWezvadEaoriVmUbHMzMXKAiUJIjJ3Tc6OxI2Czf5yR",
  server: false

# In test we don't send emails.
config :notification_service, NotificationService.Mailer, adapter: Swoosh.Adapters.Test

config :notification_service, :producer_module, {Broadway.DummyProducer, []}

# Print only info and warnings and errors during test
config :logger, level: :info

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime
