defmodule Omw.DictionaryTest do
  use ExUnit.Case

  alias Omw.Dictionary

  test "gets multiple valid random slugs" do
    slug1 = Dictionary.get_random_slug()
    slug2 = Dictionary.get_random_slug()

    assert are_valid_slugs?(slug1, slug2)
    assert slug1 != slug2
  end

  defp are_valid_slugs?(slug1, slug2) do
    regex = ~r/\w+\-\w+/
    String.match?(slug1, regex) and String.match?(slug2, regex)
  end
end
