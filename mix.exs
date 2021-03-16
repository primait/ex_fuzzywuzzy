defmodule ExFuzzywuzzy.MixProject do
  use Mix.Project

  @source_url "https://github.com/primait/ex_fuzzywuzzy"
  @version "0.1.0"

  def project do
    [
      app: :ex_fuzzywuzzy,
      version: @version,
      elixir: "~> 1.4",
      build_embedded: Mix.env() == :prod,
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      docs: docs(),
      aliases: aliases(),
      package: package(),
      description: "Fuzzy string matching",
      dialyzer: [
        plt_add_apps: [:mix],
        plt_add_deps: :transitive,
        ignore_warnings: ".dialyzerignore"
      ]
    ]
  end

  defp package do
    [
      maintainers: ["Carlo Suriano"],
      licenses: ["MIT"],
      links: %{"GitHub" => @source_url}
    ]
  end

  def project do
    [
      elixirc_paths: elixirc_paths(Mix.env()),
    ]
  end

  defp docs do
    [
      main: "readme",
      source_ref: @version,
      source_url: @source_url,
      extras: ["README.md", "CONTRIBUTING.md"]
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp deps do
    []
  end

  defp aliases do
    [
      dep_check: ["deps.unlock --check-unused"],
      check: [
        "compile --all-warnings --ignore-module-conflict --warnings-as-errors --debug-info",
        "deps.unlock --check-unused",
        "format --check-formatted mix.exs \"lib/**/*.{ex,exs}\" \"test/**/*.{ex,exs}\" \"priv/**/*.{ex,exs}\" \"config/**/*.{ex,exs}\"",
        "credo -a --strict",
        "dialyzer"
      ],
      "format.all": [
        "format mix.exs \"lib/**/*.{ex,exs}\" \"test/**/*.{ex,exs}\" \"priv/**/*.{ex,exs}\" \"config/**/*.{ex,exs}\""
      ],
    ]
  end
end
