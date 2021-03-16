defmodule ExFuzzywuzzy.Similarity.JaroWinkler do
  @moduledoc """
  Implements the similarity calculus basing on the
  [Jaro-Winkler method](https://en.wikipedia.org/wiki/Jaro%E2%80%93Winkler_distance)
  """

  @behaviour ExFuzzywuzzy.Similarity

  @doc """
  The Jaro-Winkler
  Calculus delegates to Elixir standard library implementation
  """
  @spec calculate(String.t(), String.t()) :: float()
  defdelegate calculate(left, right), to: String, as: :jaro_distance
end
