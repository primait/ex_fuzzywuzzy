defmodule ExFuzzywuzzy.Similarity do
  @moduledoc """
  Defines the `ExFuzzywuzzy.Similarity` behaviour for implementing a similarity calculator.

  A custom calculator expects two strings and calculates the similarity between them
  as a floating-point decimal between 0 and 1.

  Out-of-the-box, ExFuzzywuzzy provides Levenshtein and Jaro algorithms.
  """

  @callback calculate(String.t(), String.t()) :: float()
end
