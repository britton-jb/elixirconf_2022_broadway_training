defmodule VehicleService.NaiveVehicleRegistryConsumerTest do
  use VehicleService.DataCase, async: true

  @moduletag capture_log: true

  alias VehicleService.{Repo, Vehicle, NaiveVehicleRegistryConsumer}

  setup do
    start_supervised!(NaiveVehicleRegistryConsumer)
    message = Jason.encode!(%{start_x: 0, start_y: 0})
    {:ok, %{message: message}}
  end

  test "inserts vehicle", %{message: message} do
    assert Repo.aggregate(Vehicle, :count) == 0

    ref =
      Broadway.test_message(NaiveVehicleRegistryConsumer, message,
        metadata: %{ecto_sandbox: self()}
      )

    assert_receive {:ack, ^ref, [%{data: ^message}], []}

    assert Repo.aggregate(Vehicle, :count) == 1
  end
end
