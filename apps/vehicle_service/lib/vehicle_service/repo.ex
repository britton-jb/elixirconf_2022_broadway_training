defmodule VehicleService.Repo do
  use Ecto.Repo,
    otp_app: :vehicle_service,
    adapter: Ecto.Adapters.Postgres
end
