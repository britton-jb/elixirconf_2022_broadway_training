defmodule VehicleService.VehicleDrivingConsumerTest do
  use VehicleService.DataCase, async: true
  @moduletag capture_log: true

  alias VehicleService.{Repo, Vehicle, Vehicles, VehicleDrivingConsumer}

  setup do
    {:ok, vehicle} = Vehicles.insert(%{start_x: 10, start_y: 10})
    bad_message = 123_456

    {:ok, vehicle: vehicle, bad_message: bad_message}
  end

  test "drives a vehicle", %{vehicle: vehicle} do
    assert Repo.aggregate(Vehicle, :count) == 1

    ref =
      Broadway.test_message(VehicleDrivingConsumer, vehicle.id, metadata: %{ecto_sandbox: self()})

    assert_receive {:ack, ^ref, [%{data: _out_data}], []}, 1000

    updated_vehicle = Vehicles.get(vehicle.id)

    assert updated_vehicle.current_x != vehicle.current_x
    assert updated_vehicle.current_y != vehicle.current_y
    assert updated_vehicle.start_x == vehicle.start_x
    assert updated_vehicle.start_y == vehicle.start_y

    assert Repo.aggregate(Vehicle, :count) == 1
  end

  # TODO: Use mimic to ensure we're hitting all of these:
  # TODO: Add test for when VehicleService.Journies.is_destination_reached/1 returns true that we go to the :journey_complete batcher
  # TODO: Add test for when VehicleService.Journies.increment_step/1 returns {-11, -11} that we go to the :out_of_bounds batcher
  # TODO: Add test for when VehicleService.Journies.is_destination_reached/1 returns false that we go to the :driving batcher
end
