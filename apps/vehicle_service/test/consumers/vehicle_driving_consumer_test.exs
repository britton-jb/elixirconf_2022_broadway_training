defmodule VehicleService.VehicleDrivingConsumerTest do
  use VehicleService.DataCase, async: false
  use Mimic
  @moduletag capture_log: true

  alias Broadway.Message
  alias VehicleService.{Journeys, Repo, Vehicle, Vehicles, VehicleDrivingConsumer}

  setup :set_mimic_global
  setup :verify_on_exit!

  setup do
    {:ok, vehicle} = Vehicles.insert(%{start_x: 10, start_y: 10})
    bad_message = "123456"
    good_message = "#{vehicle.id}"

    {:ok, vehicle: vehicle, good_message: good_message, bad_message: bad_message}
  end

  test "fails the message if the vehicle is not found", %{bad_message: bad_message} do
    assert Repo.aggregate(Vehicle, :count) == 1

    ref =
      Broadway.test_message(VehicleDrivingConsumer, bad_message, metadata: %{ecto_sandbox: self()})

    assert_receive {:ack, ^ref, [] = _successful_messages,
                    [%Message{batcher: :default}] = _failed_messages},
                   1000

    assert Repo.aggregate(Vehicle, :count) == 1
  end

  test "should stop driving and mark the journey complete when the destination is reached", %{
    good_message: good_message,
    vehicle: vehicle
  } do
    expect(Journeys, :is_destination_reached?, fn _vehicle -> true end)

    ref =
      Broadway.test_message(
        VehicleDrivingConsumer,
        good_message,
        metadata: %{ecto_sandbox: self()}
      )

    assert_receive {:ack, ^ref, [%Message{batcher: :journey_complete}], [] = _failed_messages},
                   1000

    updated_vehicle = Vehicles.get(vehicle.id)
    refute updated_vehicle.is_on_journey
  end

  @out_of_bounds_tuple {-11, -11}
  @queue_name VehicleDrivingConsumer.queue_name()
  test "should retry the message when out of bounds", %{
    vehicle: vehicle,
    good_message: good_message
  } do
    expect(Journeys, :increment_step, fn _vehicle -> @out_of_bounds_tuple end)
    expect(AMQP.Basic, :publish, fn _channel, _exchange, @queue_name, ^good_message -> :ok end)

    ref =
      Broadway.test_message(
        VehicleDrivingConsumer,
        good_message,
        metadata: %{ecto_sandbox: self()}
      )

    assert_receive {:ack, ^ref, [%Message{batcher: :out_of_bounds}], [] = _failed_messages}, 1000

    updated_vehicle = Vehicles.get(vehicle.id)

    assert updated_vehicle.current_x == vehicle.current_x
    assert updated_vehicle.current_y == vehicle.current_y
    assert updated_vehicle.start_x == vehicle.start_x
    assert updated_vehicle.start_y == vehicle.start_y
  end

  @next_tuple {2, 3}
  test "should continue driving when given a valid changeset, but the destination is not reached",
       %{vehicle: vehicle, good_message: good_message} do
    Journeys
    |> expect(:increment_step, fn _vehicle -> @next_tuple end)
    |> expect(:is_destination_reached?, fn _vehicle -> false end)

    expect(AMQP.Basic, :publish, fn _channel, _exchange, @queue_name, ^good_message -> :ok end)

    ref =
      Broadway.test_message(
        VehicleDrivingConsumer,
        good_message,
        metadata: %{ecto_sandbox: self()}
      )

    assert_receive {:ack, ^ref, [%Message{batcher: :driving}], [] = _failed_messages}, 1000

    updated_vehicle = Vehicles.get(vehicle.id)

    assert updated_vehicle.current_x == elem(@next_tuple, 0)
    assert updated_vehicle.current_y == elem(@next_tuple, 1)
    assert updated_vehicle.start_x == vehicle.start_x
    assert updated_vehicle.start_y == vehicle.start_y
  end
end
