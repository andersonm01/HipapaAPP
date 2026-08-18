# Puma configuration optimized for Railway (containerized environment)

# Thread configuration
max_threads_count = ENV.fetch("RAILS_MAX_THREADS") { 5 }
min_threads_count = ENV.fetch("RAILS_MIN_THREADS") { max_threads_count }
threads min_threads_count, max_threads_count

# Port and environment
port ENV.fetch("PORT") { 3000 }
environment ENV.fetch("RAILS_ENV") { "development" }

# Disable all state file operations for containerized environments
pidfile nil
state_path nil

# Single mode (no clustering)
# Avoid any file I/O that could fail in ephemeral container filesystems
