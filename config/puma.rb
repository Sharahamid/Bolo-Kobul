# Puma configuration file

# Bind Puma to a Unix socket for Nginx
  bind "unix:///home/ubuntu/apps/bolokobul/shared/tmp/sockets/bolokobul-puma.sock"

# Ensure the socket directory exists
directory "/home/ubuntu/apps/bolokobul/current"
environment "production"

# PID and state files
pidfile "/home/ubuntu/apps/bolokobul/shared/tmp/pids/puma.pid"
state_path "/home/ubuntu/apps/bolokobul/shared/tmp/pids/puma.state"

# Threads settings
threads 5, 5

# Environment
environment ENV.fetch("RAILS_ENV") { "production" }
port ENV.fetch("PORT") { 3000 }

# Allow puma to be restarted by `rails restart`
plugin :tmp_restart


