defmodule ExFuzzywuzzy.Algorithms.LongestCommonSubstring do
  @moduledoc """
  Helper module for the calculus of the longest common substring algorithm between two strings
  """

  defstruct [:substring, :left_starting_index, :right_starting_index, :length]

  @typedoc """
  The data collected applying partial matching algorithm
  """
  @type t :: %__MODULE__{
          substring: String.t(),
          left_starting_index: non_neg_integer(),
          right_starting_index: non_neg_integer(),
          length: non_neg_integer()
        }

  @typep grapheme :: String.t()
  @typep row :: map()
  @typep match :: {integer(), integer(), integer()}
  @typep longest_match :: {{row(), row()}, match()}

  @doc """
  Calculates the longest common substring between two strings, returning a tuple containing
  the matched substring, the length of the substring itself, the starting index of the matches
  on the left and on the right.
  """
  @spec lcs(String.t(), String.t()) :: nil | t()
  def lcs(left, right) do
    left_list = left |> String.graphemes() |> Enum.with_index()
    right_list = right |> String.graphemes() |> Enum.with_index()

    {_, match} = lcs_dynamic_programming(left_list, right_list)
    build_result(left, match)
  end

  @spec lcs_dynamic_programming([grapheme()], [grapheme()]) :: longest_match()
  defp lcs_dynamic_programming(left, right) do
    Enum.reduce(left, {{%{}, %{}}, {0, 0, 0}}, fn x, acc ->
      {{_, current}, lcs} = Enum.reduce(right, acc, &step(x, &1, &2))
      {{current, %{}}, lcs}
    end)
  end

  defp step({c, i}, {c, j}, {{previous, current}, match = {_, _, lcs_length}}) do
    length = Map.get(previous, j - 1, 0) + 1
    current = Map.put(current, j, length)
    match = if length > lcs_length, do: {i - length + 1, j - length + 1, length}, else: match
    {{previous, current}, match}
  end

  defp step(_, _, acc), do: acc

  defp build_result(_, {_, _, 0}), do: nil

  defp build_result(left, {left_start, right_start, length}) do
    %__MODULE__{
      substring: String.slice(left, left_start, length),
      left_starting_index: left_start,
      right_starting_index: right_start,
      length: length
    }
  end
end
