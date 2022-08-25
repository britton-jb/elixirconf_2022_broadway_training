defmodule NotificationService.Repo.Migrations.AddIdempotencyKeyToNotifications do
  use Ecto.Migration

  def change do
    alter table("notifications") do
      add :idempotency_key, :string, null: false
    end

    create index("notifications", [:idempotency_key])
  end
end
