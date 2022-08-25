defmodule NotificationService.Notifications.Publisher do
  alias AMQP.{Basic, Channel, Connection, Queue}

  def declare_queue(retry_queue) do
    {:ok, connection} = Connection.open()
    {:ok, channel} = Channel.open(connection)
    Queue.declare(channel, retry_queue)
  end

  def publish(retry_queue, message) do
    {:ok, connection} = Connection.open()
    {:ok, channel} = Channel.open(connection)
    Basic.publish(channel, "", retry_queue, Jason.encode!(message.data))
  end
end
