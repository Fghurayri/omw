defmodule Omw.Tracker.DynamicSupervisor do
  use DynamicSupervisor

  alias Omw.Tracker.Server

  def start_link(init_arg) do
    DynamicSupervisor.start_link(__MODULE__, init_arg, name: __MODULE__)
  end

  def start_child(slug) do
    spec = %{
      id: Server,
      start: {Server, :start_link, [slug]},
      restart: :transient
    }

    DynamicSupervisor.start_child(__MODULE__, spec)
  end

  def init(_init_arg) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end
end
