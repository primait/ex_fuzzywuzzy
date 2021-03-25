defmodule ExFuzzywuzzy.Similarity.Levenshtein do
  @moduledoc """
  Implements the similarity calculus basing on the
  [Levenshtein distance](https://en.wikipedia.org/wiki/Levenshtein_distance)
  """

  alias ExFuzzywuzzy.Algorithms.PartialMatch

  @doc """
  The Levenshtein distance is calculated as the minimum number of edits in order to transition from one string to the other
  Implementation follows [Hjelmqvist algorithm](https://www.codeproject.com/Articles/13525/Fast-memory-efficient-Levenshtein-algorithm-2)
  """
  @spec calculate(String.t(), String.t()) :: float()
  def calculate(left, right) do
    left
    |> PartialMatch.matching_blocks(right)
    |> Enum.map(& &1.length)
    |> Enum.sum()
    |> (fn matches -> 2 * matches / (length(String.graphemes(left)) + length(String.graphemes(right))) end).()
  end
end
