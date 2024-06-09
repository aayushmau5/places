defmodule Places.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      PlacesWeb.Telemetry,
      {DNSCluster, query: Application.get_env(:places, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: Places.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: Places.Finch},
      # Start a worker by calling: Places.Worker.start_link(arg)
      # {Places.Worker, arg},
      # Start to serve requests, typically the last entry
      PlacesWeb.Endpoint,
      {Places.BotGenServer, []}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Places.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    PlacesWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
