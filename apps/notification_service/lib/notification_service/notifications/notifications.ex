defmodule NotificationService.Notifications do
  import Ecto.Query

  alias NotificationService.Notifications.Notification
  alias NotificationService.Repo

  def by_idempotency_key(idempotency_keys) when is_list(idempotency_keys) do
    Notification
    |> where([n], n.idempotency_key in ^idempotency_keys)
    |> Repo.all()
  end

  def by_idempotency_key(idempotency_key), do: by_idempotency_key([idempotency_key])

  def insert_all(notification_maps) do
    now =
      NaiveDateTime.utc_now()
      |> NaiveDateTime.truncate(:second)

    notification_maps =
      notification_maps
      |> Enum.map(fn notification_map ->
        notification_map
        |> Map.put(:inserted_at, now)
        |> Map.put(:updated_at, now)
      end)

    Repo.insert_all(Notification, notification_maps)
  end

  def delete_all_by_idempotency_key(idempotency_keys) do
    Notification
    |> where([n], n.idempotency_key in ^idempotency_keys)
    |> where([n], n.type == :vehicle)
    |> Repo.delete_all()
  end

  def send_notification(_notification) do
    # Process.sleep(Enum.random([0, 300, 2000, 10_000]))

    if Mix.env() == :test do
      :ok
    else
      Enum.random([:ok, {:error, :rate_limited}, {:error, :service_down}])
    end
  end
end
