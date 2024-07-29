# This configuration file will be evaluated by Puma. The top-level methods that
# are invoked here are part of Puma's configuration DSL. For more information
# about methods provided by the DSL, see https://puma.io/puma/Puma/DSL.html.

# Puma can serve each request in a thread from an internal thread pool.
# The `threads` method setting takes two numbers: a minimum and maximum.
# Any libraries that use thread pools should be configured to match
# the maximum value specified for Puma. Default is set to 5 threads for minimum
# and maximum; this matches the default thread size of Active Record.
max_threads_count = ENV.fetch("RAILS_MAX_THREADS") { 5 }
min_threads_count = ENV.fetch("RAILS_MIN_THREADS") { max_threads_count }
threads min_threads_count, max_threads_count

# Specifies that the worker count should equal the number of processors in production.
if ENV["RAILS_ENV"] == "production"
  require "concurrent-ruby"
  worker_count =
    Integer(
      ENV.fetch("WEB_CONCURRENCY") { Concurrent.physical_processor_count }
    )
  workers worker_count if worker_count > 1
end

# Specifies the `worker_timeout` threshold that Puma will use to wait before
# terminating a worker in development environments.
worker_timeout 3600 if ENV.fetch("RAILS_ENV", "development") == "development"

# Specifies the `port` that Puma will listen on to receive requests; default is 3000.
port ENV.fetch("PORT") { 3000 }

# Specifies the `environment` that Puma will run in.
environment ENV.fetch("RAILS_ENV") { "development" }

# Specifies the `pidfile` that Puma will use.
pidfile ENV.fetch("PIDFILE") { "tmp/pids/server.pid" }

# Allow puma to be restarted by `bin/rails restart` command.
plugin :tmp_restart

require "drb"
require "fileutils"
require_relative "../lib/chess/game_manager.rb"

# Define the socket path within the Rails app directory
DRUBY_SOCKET_DIR = Rails.root.join("tmp", "sockets").to_s
DRUBY_SOCKET_PATH = File.join(DRUBY_SOCKET_DIR, "chess_druby.sock")

before_fork do |server, worker|
  # Ensure the sockets directory exists
  FileUtils.mkdir_p(DRUBY_SOCKET_DIR)

  # Remove the socket file if it already exists
  File.unlink(DRUBY_SOCKET_PATH) if File.exist?(DRUBY_SOCKET_PATH)

  # Start dRuby server in the master process using Unix socket
  game_manager = GameManager.instance
  DRb.start_service("drbunix:#{DRUBY_SOCKET_PATH}", game_manager)
  puts "dRuby server started on Unix socket: #{DRUBY_SOCKET_PATH}"
end

on_worker_boot do |worker_number|
  # Connect to dRuby server in each worker
  retries = 0
  socket_path =
    File.join(DRUBY_SOCKET_DIR, "chess_worker_#{worker_number + 1}.sock")
  File.unlink(socket_path) if File.exist?(socket_path)
  begin
    DRb.start_service("drbunix:#{socket_path}")
    $GameManager = DRbObject.new_with_uri("drbunix:#{DRUBY_SOCKET_PATH}")
    puts "Worker #{worker_number} connected to dRuby server via Unix socket"
  rescue DRb::DRbConnError => e
    retries += 1
    if retries < 3
      puts "Failed to connect to dRuby server, retrying in 2 seconds..."
      sleep 2
      retry
    else
      puts "Failed to connect to dRuby server after 3 attempts"
      raise e
    end
  end
end

# Cleanup
at_exit do
  Stockfish.instance.cleanup
  DRb.stop_service
end
