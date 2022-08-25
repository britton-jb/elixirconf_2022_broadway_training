defmodule NotificationService.Repo.Migrations.CreateNotifications do
  use Ecto.Migration

  def change do
    create table(:notifications) do
      add :type, :integer

      timestamps()
    end
  end
end
