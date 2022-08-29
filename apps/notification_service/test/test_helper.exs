ExUnit.start()
Ecto.Adapters.SQL.Sandbox.mode(NotificationService.Repo, :manual)

defmodule BroadwayEctoSandbox do
  def attach(repo) do
    events = [
      [:broadway, :processor, :start],
      [:broadway, :batch_processor, :start]
    ]

    :telemetry.attach_many({__MODULE__, repo}, events, &__MODULE__.handle_event/4, %{repo: repo})
  end

  def handle_event(_event_name, _event_measurement, %{messages: messages}, %{repo: repo}) do
    with [%Broadway.Message{metadata: %{ecto_sandbox: pid}} | _] <- messages do
      Ecto.Adapters.SQL.Sandbox.allow(repo, pid, self())
    end

    :ok
  end
end

BroadwayEctoSandbox.attach(NotificationService.Repo)
