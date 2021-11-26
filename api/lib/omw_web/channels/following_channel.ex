defmodule OmwWeb.FollowingChannel do
  use OmwWeb, :channel

  @following "following:"

  def channel_topic, do: @following

  def join(@following <> _session_id, _payload, socket) do
    {:ok, socket}
  end
end
