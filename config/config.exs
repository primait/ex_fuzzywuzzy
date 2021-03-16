import Config

config :logger, :console, colors: [enabled: false]

config :ex_fuzzywuzzy, :similarity_fn, &ExFuzzywuzzy.Similarity.Levenshtein.calculate/2

config :ex_fuzzywuzzy, :case_sensitive, false

config :ex_fuzzywuzzy, :precision, 2

import_config "#{config_env()}.exs"
