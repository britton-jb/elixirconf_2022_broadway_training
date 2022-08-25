defmodule NotificationService.Notifications do
  import Ecto.Query

  alias NotificationService.Notifications.Notification
  alias NotificationService.Repo

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

  def send_notification(_notification) do
    # Process.sleep(Enum.random([0, 300, 2000, 10_000]))

    if Mix.env() == :test do
      :ok
    else
      Enum.random([:ok, {:error, :rate_limited}, {:error, :service_down}])
    end
  end
end
