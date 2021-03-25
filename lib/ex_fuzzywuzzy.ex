defmodule ExFuzzywuzzy do
  @external_resource readme = "README.md"
  @moduledoc """
  ex_fuzzywuzzy is a fuzzy string matching library that uses a customizable measure
  to calculate a distance ratio

  #{
    readme
    |> File.read!()
    |> String.split("<!--MDOC !-->")
    |> Enum.fetch!(1)
  }
  """

  alias ExFuzzywuzzy.Algorithms.PartialMatch

  @typedoc """
  Ratio calculator-like signature
  """
  @type ratio_calculator :: (String.t(), String.t() -> float())

  @typedoc """
  Configurable runtime option types
  """
  @type fuzzywuzzy_option ::
          {:similarity_fn, ratio_calculator()}
          | {:case_sensitive, boolean()}
          | {:precision, non_neg_integer()}

  @typedoc """
  Configurable runtime options for ratio
  """
  @type fuzzywuzzy_options :: [fuzzywuzzy_option()]

  @typedoc """
  Ratio methods available that match the full string
  """
  @type full_match_method :: :standard | :quick | :token_sort | :token_set

  @typedoc """
  Ratio methods available that works on the best matching substring
  """
  @type partial_match_method :: :partial | :partial_token_sort | :partial_token_set

  @typedoc """
  All ratio methods available
  """
  @type match_method :: full_match_method() | partial_match_method()

  @doc """
  Calculates the standard ratio between two strings as a percentage.
  It demands the calculus to the chosen measure, standardizing the produced output

  ```elixir
  iex> ratio("this is a test", "this is a test!")
  96.55
  ```
  """
  @spec ratio(String.t(), String.t(), fuzzywuzzy_options()) :: float()
  def ratio(left, right, options \\ []) do
    apply_ratio(left, right, &do_ratio/3, options)
  end

  @spec do_ratio(String.t(), String.t(), ratio_calculator()) :: float()
  defp do_ratio(left, right, ratio_fn), do: ratio_fn.(left, right)

  @doc """
  Like standard ratio, but ignores any non-alphanumeric character

  ```elixir
  iex> quick_ratio("this is a test", "this is a test!")
  100.0
  ```
  """
  @spec quick_ratio(String.t(), String.t(), fuzzywuzzy_options()) :: float()
  def quick_ratio(left, right, options \\ []) do
    left
    |> quick_ratio_normalizer()
    |> apply_ratio(quick_ratio_normalizer(right), &do_ratio/3, options)
  end

  @spec quick_ratio_normalizer(String.t()) :: String.t()
  defp quick_ratio_normalizer(string) do
    string
    |> string_normalizer()
    |> Enum.join(" ")
  end

  @doc """
  Calculates the partial ratio between two strings, that is the ratio between
  the best matching m-length substrings

  ```elixir
  iex> partial_ratio("this is a test", "this is a test!")
  100.0

  iex> partial_ratio("yankees", "new york yankees")
  100.0
  ```
  """
  @spec partial_ratio(String.t(), String.t(), fuzzywuzzy_options()) :: float()
  def partial_ratio(left, right, options \\ []) do
    apply_ratio(left, right, &do_partial_ratio/3, options)
  end

  @spec do_partial_ratio(String.t(), String.t(), ratio_calculator()) :: float()
  defp do_partial_ratio(left, right, ratio_fn) do
    left
    |> PartialMatch.matching_blocks(right)
    |> Enum.map(fn %PartialMatch{left_block: left_candidate, right_block: right_candidate} ->
      ratio_fn.(left_candidate, right_candidate)
    end)
    |> Enum.max()
  end

  @doc """
  Calculates the token sort ratio between two strings, that is the ratio calculated
  after tokenizing and sorting alphabetically each string

  ```elixir
  iex> token_sort_ratio("fuzzy wuzzy was a bear", "wuzzy fuzzy was a bear")
  100.0

  iex> token_sort_ratio("fuzzy muzzy was a bear", "wuzzy fuzzy was a bear")
  77.27
  ```
  """
  @spec token_sort_ratio(String.t(), String.t(), fuzzywuzzy_options()) :: float()
  def token_sort_ratio(left, right, options \\ []) do
    apply_ratio(left, right, &do_token_sort_ratio/3, options)
  end

  @spec do_token_sort_ratio(String.t(), String.t(), ratio_calculator()) :: float()
  defp do_token_sort_ratio(left, right, ratio_fn) do
    left
    |> token_sort_normalizer()
    |> ratio_fn.(token_sort_normalizer(right))
  end

  @spec token_sort_normalizer(String.t()) :: String.t()
  defp token_sort_normalizer(string) do
    string
    |> string_normalizer()
    |> Enum.sort()
    |> Enum.join(" ")
  end

  @doc """
  Like token sort ratio, but a partial ratio - instead of a standard one - is applied

  ```elixir
  iex> partial_token_sort_ratio("fuzzy wuzzy was a bear", "wuzzy fuzzy was a bear")
  100.0

  iex> partial_token_sort_ratio("fuzzy was a bear", "fuzzy fuzzy was a bear")
  81.25
  ```
  """
  @spec partial_token_sort_ratio(String.t(), String.t(), fuzzywuzzy_options()) :: float()
  def partial_token_sort_ratio(left, right, options \\ []) do
    apply_ratio(left, right, &do_partial_token_sort_ratio/3, options)
  end

  @spec do_partial_token_sort_ratio(String.t(), String.t(), ratio_calculator()) :: float()
  defp do_partial_token_sort_ratio(left, right, _) do
    do_token_sort_ratio(left, right, fn a, b -> partial_ratio(a, b) / 100 end)
  end

  @doc """
  Calculates the token set ratio between two strings, that is the ratio calculated
  after tokenizing each string, splitting in two sets (a set with fully matching tokens,
  a set with other tokens), then sorting on set membership and alphabetically

  ```elixir
  iex> token_set_ratio("fuzzy was a bear", "fuzzy fuzzy was a bear")
  100.0

  iex> token_set_ratio("fuzzy was a bear", "muzzy wuzzy was a bear")
  78.95
  ```
  """
  @spec token_set_ratio(String.t(), String.t(), fuzzywuzzy_options()) :: float()
  def token_set_ratio(left, right, options \\ []), do: apply_ratio(left, right, &do_token_set_ratio/3, options)

  @spec do_token_set_ratio(String.t(), String.t(), ratio_calculator()) :: float()
  defp do_token_set_ratio(left, right, ratio_fn) do
    left_tokens = token_set_normalizer(left)
    right_tokens = token_set_normalizer(right)

    base =
      left_tokens
      |> MapSet.intersection(right_tokens)
      |> Enum.sort()
      |> Enum.join(" ")
      |> String.trim()

    left_minus_right = token_set_diff(left_tokens, right_tokens, base)

    right_minus_left = token_set_diff(right_tokens, left_tokens, base)

    [
      {base, left_minus_right},
      {base, right_minus_left},
      {left_minus_right, right_minus_left}
    ]
    |> Enum.map(fn {left, right} -> ratio_fn.(left, right) end)
    |> Enum.max()
  end

  @spec token_set_normalizer(String.t()) :: MapSet.t()
  defp token_set_normalizer(string) do
    string
    |> string_normalizer()
    |> MapSet.new()
  end

  @spec token_set_diff(MapSet.t(), MapSet.t(), String.t()) :: String.t()
  defp token_set_diff(left, right, prefix) do
    body =
      left
      |> MapSet.difference(right)
      |> Enum.sort()
      |> Enum.join(" ")

    String.trim(prefix <> " " <> body)
  end

  @doc """
  Like token set ratio, but a partial ratio - instead a full one - is applied

  ```elixir
  iex> partial_token_set_ratio("grizzly was a bear", "a grizzly inside a box")
  100.0

  iex> partial_token_set_ratio("grizzly was a bear", "be what you wear")
  37.5
  ```
  """
  @spec partial_token_set_ratio(String.t(), String.t(), fuzzywuzzy_options()) :: float()
  def partial_token_set_ratio(left, right, options \\ []) do
    apply_ratio(left, right, &do_partial_token_set_ratio/3, options)
  end

  @spec do_partial_token_set_ratio(String.t(), String.t(), ratio_calculator()) :: float()
  defp do_partial_token_set_ratio(left, right, _) do
    do_token_set_ratio(left, right, fn a, b -> partial_ratio(a, b) / 100 end)
  end

  @doc """
  Calculates the ratio between the strings using various methods, returning the best score and algorithm
  """
  @spec best_score_ratio(String.t(), String.t(), boolean(), fuzzywuzzy_options()) :: {match_method(), float()}
  def best_score_ratio(left, right, partial \\ false, options \\ []) do
    [
      {:standard, &ratio/3},
      {:quick, &quick_ratio/3},
      {:token_sort, &token_sort_ratio/3},
      {:token_set, &token_set_ratio/3}
    ]
    |> Enum.concat(
      if partial do
        [
          {:partial, &partial_ratio/3},
          {:partial_token_sort, &partial_token_sort_ratio/3},
          {:partial_token_set, &partial_token_set_ratio/3}
        ]
      else
        []
      end
    )
    |> Enum.map(fn {method, calculator} -> {method, calculator.(left, right, options)} end)
    |> Enum.max_by(&elem(&1, 1))
  end

  @doc """
  Weighted ratio. Not implemented yet
  """

  @spec weighted_ratio(String.t(), String.t(), fuzzywuzzy_options()) :: float()
  def weighted_ratio(_, _, _) do
    raise "not_implemented"
  end

  @doc """
  Process a list of strings, finding the best match on a string reference. Not implemented yet
  """
  @spec process(String.t(), [String.t()], fuzzywuzzy_options()) :: String.t()
  def process(_, _, _) do
    raise "not_implemented"
  end

  @spec string_normalizer(String.t()) :: [String.t()]
  defp string_normalizer(string), do: String.split(string, ~R/[^[:alnum:]\-]/u, trim: true)

  @spec apply_ratio(
          String.t(),
          String.t(),
          (String.t(), String.t(), ratio_calculator() -> float()),
          fuzzywuzzy_options()
        ) ::
          float()
  defp apply_ratio("", _, _, _), do: 0.0
  defp apply_ratio(_, "", _, _), do: 0.0
  defp apply_ratio(string, string, _, _), do: 100.0

  defp apply_ratio(left, right, ratio_fn, options) do
    {left, right} =
      if get_option(options, :case_sensitive),
        do: {left, right},
        else: {String.upcase(left), String.upcase(right)}

    similarity_fn = get_option(options, :similarity_fn)
    precision = get_option(options, :precision)
    Float.round(100 * ratio_fn.(left, right, similarity_fn), precision)
  end

  @spec get_option(fuzzywuzzy_options(), atom()) :: any()
  defp get_option(options, option) do
    Keyword.get(
      options,
      option,
      Application.get_env(:ex_fuzzywuzzy, option)
    )
  end
end
