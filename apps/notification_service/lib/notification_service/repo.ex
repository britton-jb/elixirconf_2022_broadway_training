defmodule NotificationService.Repo do
  use Ecto.Repo,
    otp_app: :notification_service,
    adapter: Ecto.Adapters.Postgres
end
