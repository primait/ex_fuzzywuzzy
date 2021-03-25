defmodule ExFuzzywuzzyPerformanceTest do
  use ExUnit.Case

  import ExFuzzywuzzy
  alias ExFuzzywuzzy.Similarity.JaroWinkler

  @lorem_sample "lorem.txt"
  @japanese_sample "japanese.txt"

  test "levenshtein performance match" do
    left = read_sample(@lorem_sample)
    right = read_sample(@japanese_sample)

    assert ratio(left, left) == 100.0
    assert ratio(right, right) == 100.0
    assert ratio(left, right) < 40.0
  end

  test "jaro-winkler performance match" do
    left = read_sample(@lorem_sample)
    right = read_sample(@japanese_sample)

    assert ratio(left, left, similarity_fn: &JaroWinkler.calculate/2) == 100.0
    assert ratio(right, right, similarity_fn: &JaroWinkler.calculate/2) == 100.0
    assert ratio(left, right, similarity_fn: &JaroWinkler.calculate/2) < 40.0
  end

  defp read_sample(sample_name) do
    __DIR__
    |> Path.join("data")
    |> Path.join(sample_name)
    |> File.read!()
  end
end
