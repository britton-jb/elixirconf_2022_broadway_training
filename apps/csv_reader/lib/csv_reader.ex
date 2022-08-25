defmodule CsvReader do
  alias AMQP.{Basic, Channel, Connection, Queue}

  require Logger

  @queue_name "vehicle_registry"

  def read_csv do
    {:ok, connection} = Connection.open()
    {:ok, channel} = Channel.open(connection)
    Queue.declare(channel, @queue_name)

    "../../../vehicles.csv"
    |> Path.expand(__DIR__)
    |> File.stream!()
    |> CSV.decode(headers: true)
    |> Enum.each(fn
      {:ok, vehicle_row} ->
        Basic.publish(channel, "", @queue_name, Jason.encode!(vehicle_row))

      error ->
        Logger.error("Error while trying to read csv row: #{inspect(error)}")
    end)

    AMQP.Connection.close(connection)
  end
end
