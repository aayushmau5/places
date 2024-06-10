defmodule Places.BotSupervisor do
  alias Places.BotGenServer
  use DynamicSupervisor

  @spec start_link(any()) :: :ignore | {:error, any()} | {:ok, pid()}
  def start_link(args) do
    DynamicSupervisor.start_link(__MODULE__, args, name: __MODULE__)
  end

  @impl true
  def init(_args) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end

  @spec start_child(number()) ::
          :ignore | {:error, any()} | {:ok, pid()} | {:ok, pid(), any()}
  def start_child(index) do
    DynamicSupervisor.start_child(__MODULE__, {BotGenServer, [index]})
  end

  def kill_child(pid) do
    DynamicSupervisor.terminate_child(__MODULE__, pid)
  end

  @spec run_n_children(integer()) :: list()
  def run_n_children(n) do
    children = DynamicSupervisor.which_children(__MODULE__)
    count = length(children)

    if count < n do
      Enum.map((1 + count)..n, &start_child/1)
    else
      children
      |> Enum.map(fn {_, pid, _, _} -> pid end)
      |> Enum.take(n - count)
      |> Enum.map(&kill_child/1)
    end

    length(DynamicSupervisor.which_children(__MODULE__))
  end
end
