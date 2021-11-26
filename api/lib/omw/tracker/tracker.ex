defmodule Omw.Tracker do
  import Omw.Tracker.Registry, only: [via: 1]

  alias Omw.Tracker.DynamicSupervisor

  def new(slug) do
    DynamicSupervisor.start_child(slug)
  end

  def update(slug, new_info) do
    GenServer.call(via(slug), {:update, new_info})
  end

  def state(slug) do
    GenServer.call(via(slug), :state)
  end

  def stop(slug) do
    try do
      GenServer.call(via(slug), :stop)
    catch
      :exit, {:normal, _} ->
        :ok

      _ ->
        :error
    end
  end
end
