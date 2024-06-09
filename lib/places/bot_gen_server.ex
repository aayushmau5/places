defmodule Places.BotGenServer do
  use GenServer

  @base_duration_ms 1_000

  def start_link(state) do
    GenServer.start_link(__MODULE__, state, name: __MODULE__)
  end

  @impl true
  def init(state) do
    send_bot_click_after_random()
    {:ok, state}
  end

  def handle_info(:bot_click, state) do
    PlacesWeb.CanvasChannel.random()
    send_bot_click_after_random()
    {:noreply, state}
  end

  def send_bot_click_after_random() do
    Process.send_after(self(), :bot_click, @base_duration_ms)
  end
end
