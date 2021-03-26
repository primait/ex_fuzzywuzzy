defmodule ExFuzzywuzzyTest do
  use ExUnit.Case
  doctest ExFuzzywuzzy, import: true

  import ExFuzzywuzzy
  alias ExFuzzywuzzy.Similarity.JaroWinkler

  test "standard ratio full match" do
    assert ratio("new york mets", "new york mets", case_sensitive: true) == 100.0
    assert ratio("new york mets", "new YORK mets", case_sensitive: true, precision: 0) == 69.0

    assert ratio("new york mets", "new york mets",
             case_sensitive: true,
             similarity_fn: &JaroWinkler.calculate/2,
             precision: 0
           ) == 100

    assert ratio("{", "{", case_sensitive: true) == 100.0
    assert ratio("{a", "{a", case_sensitive: true) == 100.0

    assert ratio("new york mets", "new york mets",
             case_sensitive: true,
             similarity_fn: &JaroWinkler.calculate/2,
             precision: 0
           ) == 100

    assert ratio("神是狗", "神是狗", similarity_fn: &JaroWinkler.calculate/2) == 100.0
  end

  test "standard ratio full match case insensitive" do
    assert ratio("new york mets", "new YORK mets", case_sensitive: false) == 100.0

    assert ratio("new york mets", "new YORK mets",
             case_sensitive: false,
             similarity_fn: &JaroWinkler.calculate/2,
             precision: 1
           ) == 100.0

    assert ratio("你貴姓大名？", "你貴姓大名？", case_sensitive: false) == 100.0
  end

  test "standard ratio non full match case insensitive" do
    assert ratio("ciao", "ci", precision: 0) == 67.0
    assert ratio("神狗", "神是狗", similarity_fn: &JaroWinkler.calculate/2, precision: 3) == 61.111
  end

  test "partial ratio" do
    assert partial_ratio("the wonderful new york mets", "new YORK mets", case_sensitive: false) == 100.0
    assert partial_ratio("the wonderful new york mets", "new YORK mets", case_sensitive: true) == 69.23
  end

  test "token sort ratio" do
    assert token_sort_ratio("the wonderful new york mets", "new YORK mets the WONDERFUL", case_sensitive: false) ==
             100.0

    assert token_sort_ratio("神 是    狗", "狗 是 神", case_sensitive: false) == 100.0
  end

  test "token set ratio" do
    assert token_set_ratio("the wonderful new york new york mets", "new YORK mets the WONDERFUL", case_sensitive: false) ==
             100.0

    assert token_set_ratio(
             """
             神
             神
             是
             神
             神
             是
             """,
             "狗 是 神",
             case_sensitive: false
           ) == 100.0
  end

  test "best score ratio" do
    assert best_score_ratio(
             """
             神
             神
             是
             神
             神
             是
             """,
             "狗 是 神",
             case_sensitive: false
           ) ==
             {:token_set, 100.0}

    assert best_score_ratio("blue jeans are the most wonderful wear", "next month the new YORK mets will be WONDERFUL",
             partial: true,
             case_sensitive: true
           ) ==
             {:partial_token_set, 100.0}
  end
end
