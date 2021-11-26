defmodule OmwWeb.TrackingChannel do
  use OmwWeb, :channel

  alias Omw.Tracker
  alias OmwWeb.FollowingChannel

  @tracking "tracking:"
  @following FollowingChannel.channel_topic()

  def join(@tracking <> session_id, _payload, socket) do
    Tracker.new(session_id)
    {:ok, socket}
  end

  def handle_in("NEW_COORDS", payload, socket) do
    @tracking <> session_id = socket.topic
    updated_coords = Tracker.update(session_id, payload)
    OmwWeb.Endpoint.broadcast(@following <> session_id, "NEW_COORDS", updated_coords)
    {:noreply, socket}
  end

  def terminate(_reason, socket) do
    @tracking <> session_id = socket.topic
    IO.puts("terminating #{session_id}")
    OmwWeb.Endpoint.broadcast(@following <> session_id, "TERMINATED", %{})
    Tracker.stop(session_id)
  end
end
