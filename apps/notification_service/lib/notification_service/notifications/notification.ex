defmodule NotificationService.Notifications.Notification do
  use Ecto.Schema
  import Ecto.Changeset

  schema "notifications" do
    field :idempotency_key, :string
    field :type, Ecto.Enum, values: [vehicle: 1]

    timestamps()
  end

  @doc false
  def changeset(notification, attrs) do
    notification
    |> cast(attrs, [:idempotency_key, :type])
    |> validate_required([:idempotency_key, :type])
  end
end
