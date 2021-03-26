defmodule ExFuzzywuzzy.Algorithms.PartialMatch do
  @moduledoc """
  Implementation for the partial matching algorithms used by the library interface.
  The model defined is linked to the calling ratio functions, making no sense to be used externally
  """

  alias ExFuzzywuzzy.Algorithms.LongestCommonSubstring

  defstruct [:left_block, :right_block, :left_starting_index, :right_starting_index, :length]

  @typedoc """
  The position of a grapheme in a string
  """
  @type index :: non_neg_integer()

  @typedoc """
  The data collected applying partial matching algorithm
  """
  @type t :: %__MODULE__{
          left_block: String.t(),
          right_block: String.t(),
          left_starting_index: index(),
          right_starting_index: index(),
          length: non_neg_integer()
        }

  @typep slice :: {index(), index(), index(), index()}

  @doc """
  Calculates a list of string pairs which are the best matching substrings extracted from the provided ones
  """
  @spec matching_blocks(String.t(), String.t()) :: [t()]
  def matching_blocks(left, right), do: matching_blocks(left, right, String.length(left), String.length(right))

  @spec matching_blocks(String.t(), String.t(), index(), index()) :: [t()]
  def matching_blocks(left, right, left_length, right_length) when right_length < left_length do
    # swapping after calculus isn't done in order to guarantee the same ratio when the calling order is swapped
    matching_blocks(right, left, right_length, left_length)
  end

  def matching_blocks(left, right, left_length, right_length) do
    [{0, left_length, 0, right_length}]
    |> do_matching_blocks(left, right, [])
    |> Enum.concat([
      %__MODULE__{
        left_block: left,
        right_block: String.slice(right, right_length - left_length, left_length),
        left_starting_index: left_length,
        right_starting_index: right_length,
        length: 0
      }
    ])
    |> Enum.sort()
    |> Enum.reduce([], fn
      %__MODULE__{
        left_block: first_left_block,
        right_block: first_right_block,
        left_starting_index: first_left_index,
        right_starting_index: first_right_index,
        length: first_length
      },
      [
        %__MODULE__{
          left_block: second_left_block,
          right_block: second_right_block,
          left_starting_index: second_left_index,
          right_starting_index: second_right_index,
          length: second_length
        }
        | other_matches
      ]
      when first_left_index + first_length == second_left_index and
             first_right_index + first_length == second_right_index ->
        [
          %__MODULE__{
            left_block: first_left_block <> second_left_block,
            right_block: first_right_block <> second_right_block,
            left_starting_index: first_left_index + second_left_index,
            right_starting_index: first_right_index + second_right_index,
            length: first_length + second_length
          }
          | other_matches
        ]

      match, matches ->
        [match | matches]
    end)
    |> Enum.reverse()
  end

  @spec do_matching_blocks([slice()], String.t(), String.t(), [t()]) :: [t()]
  defp do_matching_blocks(to_be_processed, left, right, matches)

  defp do_matching_blocks([], _, _, acc), do: acc

  defp do_matching_blocks([{left_from, left_to, right_from, right_to} | remaining], left, right, matches) do
    case LongestCommonSubstring.lcs(
           String.slice(left, left_from, left_to - left_from),
           String.slice(right, right_from, right_to - right_from)
         ) do
      nil ->
        do_matching_blocks(remaining, left, right, matches)

      lcs = %LongestCommonSubstring{
        left_starting_index: left_index,
        right_starting_index: right_index,
        length: k
      } ->
        i = left_from + left_index
        j = right_from + right_index

        remaining
        |> update_left_boundary(left_from, right_from, lcs)
        |> update_right_boundary(left_from, left_to, right_from, right_to, lcs)
        |> do_matching_blocks(left, right, [
          %__MODULE__{
            left_block: left,
            right_block: String.slice(right, max(j - i, 0), String.length(left)),
            left_starting_index: i,
            right_starting_index: j,
            length: k
          }
          | matches
        ])
    end
  end

  @spec update_left_boundary([slice()], index(), index(), LongestCommonSubstring.t()) :: [slice()]
  defp update_left_boundary(remaining, left_from, right_from, %LongestCommonSubstring{
         left_starting_index: left_index,
         right_starting_index: right_index
       })
       when left_index > 0 and right_index > 0,
       do: [{left_from, left_from + left_index, right_from, right_from + right_index} | remaining]

  defp update_left_boundary(remaining, _, _, _), do: remaining

  @spec update_right_boundary([slice()], index(), index(), index(), index(), LongestCommonSubstring.t()) :: [slice()]
  defp update_right_boundary(remaining, left_from, left_to, right_from, right_to, %LongestCommonSubstring{
         left_starting_index: left_index,
         right_starting_index: right_index,
         length: k
       })
       when left_from + left_index + k < left_to and right_from + right_index + k < right_to,
       do: [{left_from + left_index + k, left_to, right_from + right_index + k, right_to} | remaining]

  defp update_right_boundary(remaining, _, _, _, _, _), do: remaining
end
