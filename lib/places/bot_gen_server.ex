defmodule Places.BotGenServer do
  use GenServer

  @base_duration_ms 1_000

  def start_link(args) do
    GenServer.start_link(__MODULE__, args)
  end

  @impl true
  def init(state) do
    send_bot_click_after_random()
    {:ok, state}
  end

  @impl true
  def handle_info(:bot_click, state) do
    PlacesWeb.CanvasChannel.random()
    send_bot_click_after_random()
    {:noreply, state}
  end

  def send_bot_click_after_random() do
    Process.send_after(self(), :bot_click, @base_duration_ms + Enum.random(1..1_000))
  end
end
