defmodule VehicleService.Repo.Migrations.AddVehicles do
  use Ecto.Migration

  def change do
    create table(:vehicles) do
      add :start_x, :integer
      add :start_y, :integer
      add :current_x, :integer
      add :current_y, :integer
      add :is_on_journey, :boolean

      timestamps()
    end
  end
end
