Mimic.copy(AMQP.Basic)
Mimic.copy(VehicleService.Journies)

ExUnit.start()
Ecto.Adapters.SQL.Sandbox.mode(VehicleService.Repo, :manual)
BroadwayEctoSandbox.attach(VehicleService.Repo)
