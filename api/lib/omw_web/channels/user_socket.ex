defmodule OmwWeb.UserSocket do
  use Phoenix.Socket

  channel "onboarding", OmwWeb.OnboardingChannel
  channel "tracking:*", OmwWeb.TrackingChannel
  channel "following:*", OmwWeb.FollowingChannel

  def connect(_params, socket, _connect_info) do
    {:ok, socket}
  end

  def id(_socket), do: nil
end
