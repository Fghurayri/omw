defmodule OmwWeb.FollowingChannelTest do
  use OmwWeb.ChannelCase

  @tracking_topic_key "tracking:"
  @following_topic_key "following:"
  @tracking_event_name "NEW_COORDS"
  @terminated_event_name "TERMINATED"

  alias Omw.Dictionary

  setup do
    session_id = Dictionary.get_random_slug()

    tracking_topic = @tracking_topic_key <> session_id
    following_topic = @following_topic_key <> session_id

    {:ok, _, tracking_socket} =
      OmwWeb.UserSocket
      |> socket()
      |> subscribe_and_join(OmwWeb.TrackingChannel, tracking_topic)

    {:ok, _, following_socket} =
      OmwWeb.UserSocket
      |> socket()
      |> subscribe_and_join(OmwWeb.FollowingChannel, following_topic)

    %{
      tracking_socket: tracking_socket,
      following_socket: following_socket
    }
  end

  test "follower receives tracking updates", %{
    tracking_socket: tracking_socket,
    following_socket: following_socket
  } do
    event = %{
      "heading" => 0,
      "latitude" => -80,
      "longitude" => 80,
      "speed" => 100
    }

    push(tracking_socket, @tracking_event_name, event)
    broadcast_from!(following_socket, @tracking_event_name, event)
  end

  test "follower receives termination update", %{
    tracking_socket: tracking_socket,
    following_socket: following_socket
  } do
    push(tracking_socket, @terminated_event_name, %{})
    broadcast_from!(following_socket, @terminated_event_name, %{})
  end
end
