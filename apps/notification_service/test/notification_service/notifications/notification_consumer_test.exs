defmodule NotificationService.Notifications.NotificationConsumerTest do
  use NotificationService.DataCase, async: false
  @moduletag capture_log: true

  import ExUnit.CaptureLog

  alias Broadway.Message
  alias NotificationService.Repo
  alias NotificationService.Notifications.Notification
  alias NotificationService.Notifications.NotificationConsumer

  setup do
    message_1_body =
      Jason.encode!(%{
        payload: %{
          after: %{
            id: 1,
            current_x: 1,
            current_y: 1,
            start_x: 1,
            start_y: 1
          }
        }
      })

    message_1_metadata = %{
      key: Jason.encode!(%{payload: %{id: 1}}),
      ts: 12345
    }

    message_2_body =
      Jason.encode!(%{
        payload: %{
          after: %{
            id: 2,
            current_x: 2,
            current_y: 2,
            start_x: 2,
            start_y: 2
          }
        }
      })

    message_2_metadata = %{
      key: Jason.encode!(%{payload: %{id: 2}}),
      ts: 23456
    }

    {:ok,
     message_1: {message_1_body, message_1_metadata},
     message_2: {message_2_body, message_2_metadata}}
  end

  test "sends notifications", %{message_1: {message_body, message_metadata}} do
    assert Repo.aggregate(Notification, :count) == 0

    assert capture_log(fn ->
             ref =
               Broadway.test_message(NotificationConsumer, message_body,
                 metadata: Map.put(message_metadata, :ecto_sandbox, self())
               )

             assert_receive {:ack, ^ref, [%Message{data: %{idempotency_key: "12345-1"}}], []},
                            1000
           end) =~ "Batching messages"

    assert Repo.aggregate(Notification, :count) == 1
  end

  test "sends duplicate messages to the duplicate batcher", %{
    message_1: {message_body, message_metadata}
  } do
    Repo.insert(%Notification{idempotency_key: "12345-1"})
    assert Repo.aggregate(Notification, :count) == 1

    assert capture_log(fn ->
             ref =
               Broadway.test_message(NotificationConsumer, message_body,
                 metadata: Map.put(message_metadata, :ecto_sandbox, self())
               )

             assert_receive {:ack, ^ref, [%Message{data: %{idempotency_key: "12345-1"}}], []},
                            1000
           end) =~ "Handling duplicate messages"

    assert Repo.aggregate(Notification, :count) == 1
  end
end
