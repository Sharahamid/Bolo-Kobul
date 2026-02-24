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
