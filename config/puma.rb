# SECRET_KEY_BASE comes from the server's config/application.yml (never commit it here)

# Bind Puma to a Unix socket for Nginx
bind "unix:///home/ubuntu/apps/bolokobul/shared/tmp/sockets/bolokobul-puma.sock"

# PID and state files

# Threads settings
threads 5, 5

# Workers for multi-core
workers 2
preload_app!

# Environment
environment ENV.fetch("RAILS_ENV") { "production" }


# Logging

# Allow puma to be restarted by `rails restart`
