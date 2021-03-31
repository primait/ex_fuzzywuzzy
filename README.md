# ExFuzzywuzzy
[![Build Status](https://drone-1.prima.it/api/badges/primait/ex_fuzzywuzzy/status.svg)](https://drone-1.prima.it/primait/ex_fuzzywuzzy)
[![Module Version](https://img.shields.io/hexpm/v/ex_fuzzywuzzy.svg)](https://hex.pm/packages/ex_fuzzywuzzy)
[![Hex Docs](https://img.shields.io/badge/hex-docs-lightgreen.svg)](https://hexdocs.pm/ex_fuzzywuzzy/)
[![Total Download](https://img.shields.io/hexpm/dt/ex_fuzzywuzzy.svg)](https://hex.pm/packages/ex_fuzzywuzzy)
[![License](https://img.shields.io/hexpm/l/ex_fuzzywuzzy.svg)](https://hex.pm/packages/ex_fuzzywuzzy)
[![Last Updated](https://img.shields.io/github/last-commit/primait/ex_fuzzywuzzy.svg)](https://github.com/primait/ex_fuzzywuzzy/commits/master)

ExFuzzyWuzzy is a fuzzy string matching library that provides many ways of calculating
a matching ratio between two strings, starting from a similarity function which can be
based on Levenshtein or Jaro-Winkler or a custom one.

The library is an Elixir port of SeatGeek's [fuzzywuzzy](https://github.com/seatgeek/fuzzywuzzy).

## Installation

To install ExFuzzyWuzzy, just add an entry to your `mix.exs`:
```elixir
def deps do
  [
    {:ex_fuzzywuzzy, "~> 0.2.0"}
  ]
end
```

## Usage
<!--MDOC !-->

Choose the ratio function which fits best your needs among the available, 
providing the two strings to be matched and - if needed - overwriting options 
over the configured ones.

Available methods are:
- Simple ratio
- Quick ratio
- Partial ratio
- Token sort ratio
- Partial token sort ratio
- Token set ratio
- Partial token set ratio
- Best score ratio

Available options are:
- Similarity function (Levenshtein and Jaro-Winkler provided in library)
- Case sensitiveness of match
- Decimal precision of output score

Here are some examples.

### Simple ratio
```elixir
iex> ExFuzzywuzzy.ratio("this is a test", "this is a test!")
96.55
```

### Quick ratio
```elixir
iex> ExFuzzywuzzy.quick_ratio("this is a test", "this is a test!")
100.0
```

### Partial ratio
```elixir
iex> ExFuzzywuzzy.partial_ratio("this is a test", "this is a test!")
100.0
```

### Best Score ratio
```elixir
iex> ExFuzzywuzzy.best_score_ratio("this is a test", "this is a test!")
{:quick, 100.0}
```
<!--MDOC !-->

## Contributing
Thank your for considering helping with this project. Please see
`CONTRIBUTING.md` file for contributing to this project.

## License
MIT License. Copyright (c) 2015-2021 Prima.it
