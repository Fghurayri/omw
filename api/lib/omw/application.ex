defmodule Omw.Application do
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Phoenix
      OmwWeb.Telemetry,
      {Phoenix.PubSub, name: Omw.PubSub},
      OmwWeb.Endpoint,
      # Omw
      {Registry, keys: :unique, name: Omw.Tracker.Registry},
      Omw.Dictionary,
      Omw.Tracker.DynamicSupervisor
    ]

    opts = [strategy: :one_for_one, name: Omw.Supervisor]
    Supervisor.start_link(children, opts)
  end

  @impl true
  def config_change(changed, _new, removed) do
    OmwWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
