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

  def bulk_insert(vehicle_maps) do
    {_rows, vehicles} = Repo.insert_all(Vehicle, vehicle_maps, returning: true)
    {:ok, vehicles}
  end
end
