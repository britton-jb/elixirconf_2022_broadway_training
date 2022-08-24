defmodule NotificationServiceWeb.PageController do
  use NotificationServiceWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
