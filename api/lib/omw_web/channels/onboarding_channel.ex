defmodule OmwWeb.OnboardingChannel do
  use OmwWeb, :channel

  alias Omw.Dictionary

  def join("onboarding", _payload, socket) do
    {:ok, socket}
  end

  def handle_in("GENERATE_NEW_SESSION_NAME", _payload, socket) do
    random_session = Dictionary.get_random_slug()
    {:reply, {:ok, random_session}, socket}
  end
end
