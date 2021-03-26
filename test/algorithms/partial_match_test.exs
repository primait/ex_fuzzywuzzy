defmodule ExFuzzywuzzy.PartialMatch.Test do
  use ExUnit.Case

  alias ExFuzzywuzzy.Algorithms.PartialMatch

  test "extract matching blocks" do
    assert PartialMatch.matching_blocks("abcd", "abxcd") ==
             [
               %PartialMatch{
                 left_block: "abcd",
                 right_block: "abxc",
                 left_starting_index: 0,
                 right_starting_index: 0,
                 length: 2
               },
               %PartialMatch{
                 left_block: "abcd",
                 right_block: "bxcd",
                 left_starting_index: 2,
                 right_starting_index: 3,
                 length: 2
               },
               %PartialMatch{
                 left_block: "abcd",
                 right_block: "bxcd",
                 left_starting_index: 4,
                 right_starting_index: 5,
                 length: 0
               }
             ]
  end

  test "swap test" do
    assert PartialMatch.matching_blocks("test-ab", "ab") == [
             %PartialMatch{
               left_block: "ab",
               right_block: "ab",
               left_starting_index: 0,
               right_starting_index: 5,
               length: 2
             },
             %PartialMatch{
               left_block: "ab",
               right_block: "ab",
               left_starting_index: 2,
               right_starting_index: 7,
               length: 0
             }
           ]
  end

  test "swap test invariant" do
    assert PartialMatch.matching_blocks("abcd", "abxcd") == PartialMatch.matching_blocks("abxcd", "abcd")
    assert PartialMatch.matching_blocks("test-ab", "ab") == PartialMatch.matching_blocks("ab", "test-ab")
  end
end
