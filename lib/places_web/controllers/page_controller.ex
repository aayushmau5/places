defmodule PlacesWeb.PageController do
  use PlacesWeb, :controller

  def home(conn, _params) do
    # The home page is often custom made,
    # so skip the default app layout.
    conn
    |> render(:canvas)
  end
end
