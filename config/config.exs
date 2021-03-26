import Config

config :logger, :console, colors: [enabled: false]

config :ex_fuzzywuzzy,
  similarity_fn: &ExFuzzywuzzy.Similarity.Levenshtein.calculate/2,
  case_sensitive: false,
  precision: 0

import_config "#{config_env()}.exs"
