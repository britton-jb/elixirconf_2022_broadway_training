defmodule VehicleService.Vehicle do
  use Ecto.Schema
  import Ecto.Changeset

  schema "vehicles" do
    field(:start_x, :integer)
    field(:start_y, :integer)
    field(:current_x, :integer)
    field(:current_y, :integer)
    field(:is_on_journey, :boolean, default: true)

    timestamps()
  end

  def insert_changeset(params \\ %{}) do
    %__MODULE__{}
    |> cast(params, [:start_x, :start_y])
    |> validate_required([:start_x, :start_y])
    |> validate_inclusion(:start_x, 0..1_000)
    |> validate_inclusion(:start_y, 0..1_000)
    |> set_current_coordinate(:current_x, :start_x)
    |> set_current_coordinate(:current_y, :start_y)
  end

  defp set_current_coordinate(changeset, key, value_key) do
    {:ok, value} = fetch_change(changeset, value_key)
    put_change(changeset, key, value)
  end
end
