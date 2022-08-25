defmodule NotificationService.Notifications.Notification do
  use Ecto.Schema
  import Ecto.Changeset

  schema "notifications" do
    field :type, Ecto.Enum, values: [vehicle: 1]

    timestamps()
  end

  @doc false
  def changeset(notification, attrs) do
    notification
    |> cast(attrs, [:type])
    |> validate_required([:type])
  end
end
