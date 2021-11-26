defmodule Omw.Tracker.DictionaryTest do
  use ExUnit.Case

  alias Omw.Tracker
  alias Omw.Tracker.Session

  test "creates a session" do
    session_name = "elixir-nice"
    {:ok, pid} = Tracker.new(session_name)

    assert is_pid(pid)

    %Session{
      heading: nil,
      latitude: nil,
      longitude: nil,
      slug: ^session_name,
      speed: nil
    } = Tracker.state(session_name)
  end

  test "updates a session" do
    session_name = "elixir-fun"
    Tracker.new(session_name)

    %Session{
      heading: 0,
      latitude: -80,
      longitude: 80,
      slug: ^session_name,
      speed: 100
    } =
      Tracker.update(session_name, %{
        "heading" => 0,
        "latitude" => -80,
        "longitude" => 80,
        "speed" => 100
      })
  end

  test "stops a session" do
    session_name = "elixir-cool"
    Tracker.new(session_name)
    :ok = Tracker.stop(session_name)
  end
end
