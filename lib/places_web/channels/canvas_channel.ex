defmodule PlacesWeb.CanvasChannel do
  use PlacesWeb, :channel

  @metadata %{rows: 30, cols: 50, cellSize: 20}

  def get_metadata, do: @metadata |> Jason.encode!()

  @impl true
  def join("room:canvas", payload, socket) do
    if authorized?(payload) do
      {:ok, @metadata, socket}
    else
      {:error, %{reason: "unauthorized"}}
    end
  end

  # Channels can be used in a request/response fashion
  # by sending replies to requests from the client
  @impl true
  def handle_in("ping", payload, socket) do
    {:reply, {:ok, payload}, socket}
  end

  # It is also common to receive messages from the client and
  # broadcast to everyone in the current topic (canvas:lobby).
  @impl true
  def handle_in("click", pos, socket) do
    broadcast_from(socket, "click", pos)
    {:noreply, socket}
  end

  # Add authorization logic here as required.
  defp authorized?(_payload) do
    true
  end

  def random() do
    %{rows: rows, cols: cols} = @metadata

    PlacesWeb.Endpoint.broadcast("room:canvas", "click", %{
      x: Enum.random(0..(cols - 1)),
      y: Enum.random(0..(rows - 1))
    })
  end
end
