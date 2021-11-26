defmodule Omw.Dictionary do
  use Agent

  alias Omw.Dictionary.Words

  def start_link(_init_arg) do
    Agent.start_link(&prepare_dictionary/0, name: __MODULE__)
  end

  def get_random_slug() do
    __MODULE__
    |> Agent.get(&Enum.take_random(&1, 2))
    |> Enum.join("-")
  end

  defp prepare_dictionary() do
    Words.all()
  end
end
