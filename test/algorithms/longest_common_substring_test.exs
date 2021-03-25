defmodule ExFuzzywuzzy.Test do
  use ExUnit.Case

  alias ExFuzzywuzzy.Algorithms.LongestCommonSubstring

  test "lcs" do
    assert LCS.lcs("aaaaaa", "aaaaaa") == %LongestCommonSubstring{
             substring: "aaaaaa",
             left_starting_index: 0,
             right_starting_index: 0,
             length: 6
           }

    assert LCS.lcs("XXXaaaaaaXXXX", "YYaaaaaaYYYYY") == %LongestCommonSubstring{
             substring: "aaaaaa",
             left_starting_index: 3,
             right_starting_index: 2,
             length: 6
           }

    assert LCS.lcs("aabc", "dc") == %LongestCommonSubstring{
             substring: "c",
             left_starting_index: 3,
             right_starting_index: 1,
             length: 1
           }

    assert LCS.lcs("XXXaaaaaaXXXXaaaaaa", "YYaaaaaaYYYYYaaaaaa") == %LongestCommonSubstring{
             substring: "aaaaaa",
             left_starting_index: 3,
             right_starting_index: 2,
             length: 6
           }

    assert LCS.lcs("XaaXaaa", "YaaYaaa") == %LongestCommonSubstring{
             substring: "aaa",
             left_starting_index: 4,
             right_starting_index: 4,
             length: 3
           }

    assert LCS.lcs("XXXaaaaaaXXXXaaaaaaa", "YYaaaaaaYYYYYaaaaaaa") == %LongestCommonSubstring{
             substring: "aaaaaaa",
             left_starting_index: 13,
             right_starting_index: 13,
             length: 7
           }

    assert is_nil(LongestCommonSubstring.lcs("bbbbbb", "aaaaaa"))
  end
end
