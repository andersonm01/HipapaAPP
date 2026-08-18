# Puma configuration optimized for Railway (containerized environment)

# Thread configuration
max_threads_count = ENV.fetch("RAILS_MAX_THREADS") { 5 }
min_threads_count = ENV.fetch("RAILS_MIN_THREADS") { max_threads_count }
threads min_threads_count, max_threads_count

# Port and environment
port ENV.fetch("PORT") { 3000 }
environment ENV.fetch("RAILS_ENV") { "development" }

# Don't call pidfile/state_path at all: Puma's DSL does `path.to_s`, so
# passing nil turns into an empty string (truthy), which makes Puma try
# to write a pidfile/state file to "" and crash with ENOENT. Leaving
# these unset keeps them at Puma's real default of disabled (nil).

# Single mode (no clustering)
