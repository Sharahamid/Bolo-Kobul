# Ensure Rails secret key is set for Puma workers
ENV['SECRET_KEY_BASE'] ||= '84f38f0dd085237560c69ffd96d1334119e31934d01eb0693ae4ad53a6f1fea52519427448cb455c8cd0512d054877aacc2c25bca23d67ed183a1f7b8cf7a1a2'

# Bind Puma to a Unix socket for Nginx
bind "unix:///home/ubuntu/apps/bolokobul/shared/tmp/sockets/bolokobul-puma.sock"

# PID and state files
pidfile "/home/ubuntu/apps/bolokobul/shared/tmp/pids/puma.pid"
state_path "/home/ubuntu/apps/bolokobul/shared/tmp/pids/puma.state"

# Threads settings
threads 5, 5

# Workers for multi-core
workers 2
preload_app!

# Environment
environment ENV.fetch("RAILS_ENV") { "production" }

# Daemonize in production
daemonize true if ENV.fetch("RAILS_ENV") { "production" } == "production"

# Logging
stdout_redirect "/home/ubuntu/apps/bolokobul/shared/log/puma.stdout.log", "/home/ubuntu/apps/bolokobul/shared/log/puma.stderr.log", true

# Allow puma to be restarted by `rails restart`
plugin :tmp_restart
