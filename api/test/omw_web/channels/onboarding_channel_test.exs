defmodule OmwWeb.OnboardingChannelTest do
  use OmwWeb.ChannelCase

  @topic "onboarding"
  @event_name "GENERATE_NEW_SESSION_NAME"

  setup do
    {:ok, _, socket} =
      OmwWeb.UserSocket
      |> socket()
      |> subscribe_and_join(OmwWeb.OnboardingChannel, @topic)

    %{socket: socket}
  end

  test "generates a new session name", %{socket: socket} do
    ref = push(socket, @event_name, %{})
    assert_reply(ref, :ok, random_session)
    assert is_binary(random_session)
  end
end
