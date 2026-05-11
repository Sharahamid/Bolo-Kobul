# Ensure Rails secret key is set for Puma workers
ENV['SECRET_KEY_BASE'] ||= '7db98b0dc3a079688a5e7a7beb7c6cc8ad90bc0d988757f153d915538b6634c1afdb0f409b79f5e236b89f558bad70ca7ba98b6c06e96acca6ee19583a0d4e82'

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
