defmodule Omw.Tracker.Registry do
  def via(slug) do
    {:via, Registry, {__MODULE__, slug}}
  end
end
