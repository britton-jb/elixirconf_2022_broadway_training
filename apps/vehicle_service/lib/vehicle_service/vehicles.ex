defmodule VehicleService.Vehicles do
  alias VehicleService.{Repo, Vehicle}

  import Ecto.Query, only: [from: 2]

  def insert(params \\ %{}) do
    params
    |> Vehicle.insert_changeset()
    |> Repo.insert()
  end

  def get(id) do
    Repo.get(Vehicle, id)
  end

  def get_all(ids) do
    Repo.all(from(v in Vehicle, where: v.id in ^ids))
  end

  def all() do
    Repo.all(Vehicle)
  end
end
