defmodule VehicleService.VehicleRegistryConsumerTest do
  use VehicleService.DataCase, async: true
  @moduletag capture_log: true

  alias VehicleService.{Repo, Vehicle, VehicleRegistryConsumer}

  setup do
    message = Jason.encode!(%{start_x: 0, start_y: 0})
    bad_message = Jason.encode!(%{start_x: -1, start_y: 0})
    {:ok, message: message, bad_message: bad_message}
  end

  test "inserts vehicle", %{message: message} do
    assert Repo.aggregate(Vehicle, :count) == 0

    ref =
      Broadway.test_message(VehicleRegistryConsumer, message, metadata: %{ecto_sandbox: self()})

    assert_receive {:ack, ^ref, [%{data: _out_data}], []}, 1000

    assert Repo.aggregate(Vehicle, :count) == 1
  end

  test "batches messages, inserting multiple vehicles", %{message: message} do
    assert Repo.aggregate(Vehicle, :count) == 0

    ref =
      Broadway.test_batch(VehicleRegistryConsumer, [message, message],
        metadata: %{ecto_sandbox: self()}
      )

    assert_receive {:ack, ^ref, [_msg1, _msg2], []}, 2000
    assert Repo.aggregate(Vehicle, :count) == 2
  end

  test "sends failed messages to the failed batcher", %{bad_message: message} do
    assert Repo.aggregate(Vehicle, :count) == 0

    ref = Broadway.test_message(VehicleRegistryConsumer, message, metadata: %{ecto_sandbox: self()})
    assert_receive {:ack, ^ref, [], [%{data: _out_data, status: {:failed, "Invalid changeset"}}]}, 1000

    assert Repo.aggregate(Vehicle, :count) == 0
  end
end
