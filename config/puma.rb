# Puma configuration file

# Bind Puma to a Unix socket for Nginx
bind "unix:///home/ubuntu/apps/bolokobul/shared/tmp/sockets/bolokobul-puma.sock"

# PID and state files
pidfile "/home/ubuntu/apps/bolokobul/shared/tmp/pids/puma.pid"
state_path "/home/ubuntu/apps/bolokobul/shared/tmp/pids/puma.state"

# Threads settings
threads 5, 5

# Environment
environment ENV.fetch("RAILS_ENV") { "production" }

# Allow puma to be restarted by `rails restart`
plugin :tmp_restart


