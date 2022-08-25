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

  def update_all(vehicle_maps) do
    now = NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second)

    vehicle_maps =
      Enum.map(vehicle_maps, fn vehicle_map ->
        Map.put(vehicle_map, :updated_at, now)
      end)

    {_rows, vehicles} =
      Repo.insert_all(Vehicle, vehicle_maps,
        returning: true,
        on_conflict: :replace_all,
        conflict_target: [:id]
      )

    {:ok, vehicles}
  end
end
