defmodule Omw.Tracker.Server do
  use GenServer

  import Omw.Tracker.Registry, only: [via: 1]

  alias Omw.Tracker.Session

  def init(init_arg) do
    {:ok, init_arg}
  end

  def start_link(slug) do
    session = Session.new(slug)
    GenServer.start_link(__MODULE__, session, name: via(slug))
  end

  def handle_call({:update, new_info}, _from, state) do
    new_state = Session.update(state, new_info)
    {:reply, new_state, new_state}
  end

  def handle_call(:state, _from, state) do
    {:reply, state, state}
  end

  def handle_call(:stop, _from, state) do
    {:stop, :normal, state}
  end
end
