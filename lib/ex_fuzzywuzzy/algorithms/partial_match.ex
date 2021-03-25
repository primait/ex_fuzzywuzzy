defmodule ExFuzzywuzzy.Algorithms.PartialMatch do
  @moduledoc """
  Implementation for the partial matching algorithms used by the library interface.
  The models defined are linked to the calling ratios functions, making no sense to be used externally
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

  @typep slice :: {non_neg_integer(), non_neg_integer()}

  @doc """
  Calculates a list of string pairs which are the best matching substrings extracted from the provided ones
  """
  @spec matching_blocks(String.t(), String.t()) :: [{String.t(), String.t()}]
  def matching_blocks(left, right) do
    {left_length, right_length} = {String.length(left), String.length(right)}

    # first string should be the shortest
    {first, second, first_length, second_length} =
      if right_length < left_length,
        do: {right, left, right_length, left_length},
        else: {left, right, left_length, right_length}

    []
    |> do_matching_blocks(first, second, {0, first_length}, {0, second_length})
    |> Enum.concat([{first, String.slice(second, second_length - first_length, first_length)}])
  end

  @spec do_matching_blocks([{String.t(), String.t()}], String.t(), String.t(), slice(), slice()) :: [
          {String.t(), String.t()}
        ]
  defp do_matching_blocks(acc, left, right, {left_from, left_to}, {right_from, right_to}) do
    case longest_common_substring(
           String.slice(left, left_from, left_to - left_from),
           String.slice(right, right_from, right_to - right_from)
         ) do
      nil ->
        acc

      %__MODULE__{
        left_starting_index: left_index,
        right_starting_index: right_index,
        length: k
      } ->
        i = left_index + left_from
        j = right_index + right_from

        acc
        |> (fn state ->
              # 0 < left_index and 0 < right_index
              if left_from < i and right_from < j do
                do_matching_blocks(state, left, right, {left_from, i}, {right_from, j})
              else
                state
              end
            end).()
        |> (fn state ->
              [{left, String.slice(right, max(j - i, 0), String.length(left))} | state]
            end).()
        |> (fn state ->
              # k < left_to - i and k < right_to - j
              if i + k < left_to and j + k < right_to do
                do_matching_blocks(state, left, right, {i + k, left_to}, {j + k, right_to})
              else
                state
              end
            end).()
    end
  end

  @doc """
  Calculates the longest common substring between two strings, returning a tuple containing
  the matched substring, the length of the substring itself, the starting index of the matches
  on the left and on the right
  """
  @spec longest_common_substring(String.t(), String.t()) :: nil | t()
  def longest_common_substring(left, right) do
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
