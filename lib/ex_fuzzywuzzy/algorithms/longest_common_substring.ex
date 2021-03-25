defmodule ExFuzzywuzzy.Algorithms.LongestCommonSubstring do
  @moduledoc """
  Helper module for the application of the longest common substring algorithm between two strings
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

  @doc """
  Calculates the longest common substring between two strings, returning a tuple containing
  the matched substring, the length of the substring itself, the starting index of the matches
  on the left and on the right
  """
  @spec lcs(String.t(), String.t()) :: nil | t()
  def lcs(left, right) do
    left_length = String.length(left)

    for(
      from_index <- 0..left_length,
      to_index <- from_index..left_length,
      from_index != to_index,
      do: {from_index, to_index - from_index}
    )
    |> Enum.sort(fn {_, l1}, {_, l2} -> l1 > l2 end)
    |> Enum.reduce_while(nil, fn {from_index, length}, _ ->
      query = String.slice(left, from_index, length)

      case String.split(right, query, parts: 2) do
        [prefix_match, _] ->
          {:halt,
           %__MODULE__{
             substring: query,
             left_starting_index: from_index,
             right_starting_index: String.length(prefix_match),
             length: length
           }}

        _ ->
          {:cont, nil}
      end
    end)
  end
end
