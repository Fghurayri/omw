defmodule OmwWeb.TrackingChannelTest do
  use OmwWeb.ChannelCase

  @topic_key "tracking:"
  @event_name "NEW_COORDS"

  alias Omw.Dictionary
  alias Omw.Tracker
  alias Omw.Tracker.Session

  setup do
    session_id = Dictionary.get_random_slug()
    topic = @topic_key <> session_id

    {:ok, _, socket} =
      OmwWeb.UserSocket
      |> socket()
      |> subscribe_and_join(OmwWeb.TrackingChannel, topic)

    %{socket: socket, session_id: session_id}
  end

  test "updates a session through pushing to the channel", %{
    socket: socket,
    session_id: session_id
  } do
    %Session{
      heading: nil,
      latitude: nil,
      longitude: nil,
      slug: ^session_id,
      speed: nil
    } = Tracker.state(session_id)

    push(socket, @event_name, %{
      "heading" => 0,
      "latitude" => -80,
      "longitude" => 80,
      "speed" => 100
    })

    # smell :( to avoid flaky test
    Process.sleep(100)

    %Session{
      heading: 0,
      latitude: -80,
      longitude: 80,
      slug: ^session_id,
      speed: 100
    } = Tracker.state(session_id)
  end
end
