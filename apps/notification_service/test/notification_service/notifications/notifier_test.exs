defmodule NotificationService.Notifications.NotifierTest do
  use ExUnit.Case, async: true
  import Swoosh.TestAssertions

  alias NotificationService.Notifications.Notifier

  test "deliver_trip_started/1" do
    user = %{name: "Alice", email: "alice@example.com"}

    Notifier.deliver_trip_started(user)

    assert_email_sent(
      subject: "Welcome to Phoenix, Alice!",
      to: {"Alice", "alice@example.com"},
      text_body: ~r/Hello, Alice/
    )
  end

  test "deliver_trip_completed/1" do
    user = %{name: "Alice", email: "alice@example.com"}

    Notifier.deliver_trip_completed(user)

    assert_email_sent(
      subject: "Welcome to Phoenix, Alice!",
      to: {"Alice", "alice@example.com"},
      text_body: ~r/Hello, Alice/
    )
  end

  test "deliver_service_started/1" do
    user = %{name: "Alice", email: "alice@example.com"}

    Notifier.deliver_service_started(user)

    assert_email_sent(
      subject: "Welcome to Phoenix, Alice!",
      to: {"Alice", "alice@example.com"},
      text_body: ~r/Hello, Alice/
    )
  end

  test "deliver_service_completed/1" do
    user = %{name: "Alice", email: "alice@example.com"}

    Notifier.deliver_service_completed(user)

    assert_email_sent(
      subject: "Welcome to Phoenix, Alice!",
      to: {"Alice", "alice@example.com"},
      text_body: ~r/Hello, Alice/
    )
  end
end
