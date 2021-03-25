defmodule ExFuzzywuzzy.Algorithms.PartialMatch do
  @moduledoc """
  Implementation for the partial matching algorithms used by the library interface.
  The models defined are linked to the calling ratios functions, making no sense to be used externally
  """

  alias ExFuzzywuzzy.Algorithms.LongestCommonSubstring

  defstruct [:left_block, :right_block, :left_starting_index, :right_starting_index, :length]

  @typedoc """
  The data collected applying partial matching algorithm
  """
  @type t :: %__MODULE__{
          left_block: String.t(),
          right_block: String.t(),
          left_starting_index: non_neg_integer(),
          right_starting_index: non_neg_integer(),
          length: non_neg_integer()
        }

  @typep slice :: {non_neg_integer(), non_neg_integer()}

  @doc """
  Calculates a list of string pairs which are the best matching substrings extracted from the provided ones
  """
  @spec matching_blocks(String.t(), String.t()) :: [t()]
  def matching_blocks(left, right) do
    {left_length, right_length} = {String.length(left), String.length(right)}

    # first string should be the shortest
    {first, second, first_length, second_length} =
      if right_length < left_length,
        do: {right, left, right_length, left_length},
        else: {left, right, left_length, right_length}

    []
    |> do_matching_blocks(first, second, {0, first_length}, {0, second_length})
    |> Enum.concat([
      %__MODULE__{
        left_block: first,
        right_block: String.slice(second, second_length - first_length, first_length),
        left_starting_index: first_length,
        right_starting_index: second_length,
        length: 0
      }
    ])
  end

  @spec do_matching_blocks([t()], String.t(), String.t(), slice(), slice()) :: [t()]
  defp do_matching_blocks(acc, left, right, {left_from, left_to}, {right_from, right_to}) do
    case LongestCommonSubstring.lcs(
           String.slice(left, left_from, left_to - left_from),
           String.slice(right, right_from, right_to - right_from)
         ) do
      nil ->
        acc

      %LongestCommonSubstring{
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
              [
                %__MODULE__{
                  left_block: left,
                  right_block: String.slice(right, max(j - i, 0), String.length(left)),
                  left_starting_index: i,
                  right_starting_index: j,
                  length: k
                }
                | state
              ]
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
end
