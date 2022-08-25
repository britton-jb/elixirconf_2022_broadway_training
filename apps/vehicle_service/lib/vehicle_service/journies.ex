defmodule VehicleService.Journies do
  @allowed_step_distances [-5, -4, -3, -2, -1, 1, 2, 3, 4, 5]

  def increment_step(vehicle) do
    x_increment = Enum.random(@allowed_step_distances)
    y_increment = Enum.random(@allowed_step_distances)

    {vehicle.current_x + x_increment, vehicle.current_y + y_increment}
  end

  def is_destination_reached?(vehicle) do
    # 1 in 100 chance that the destination has been reached.
    rem(vehicle.id, 100) == :rand.uniform(100)
  end
end
