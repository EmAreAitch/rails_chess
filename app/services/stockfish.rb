require "open3"

class Stockfish
  def initialize(name:)
    @engine_path = Rails.root.join("lib", "stockfish", "stockfish").to_s
    @name = name
    @stdin, @stdout, @stderr, @wait_thr = Open3.popen3(@engine_path)
  end

  def current_player
    return @name
  end

  def send_command(command)
    @stdin.puts command
    @stdin.flush
  end

  def best_move(position, go)
    retries = 0
    begin
      send_command("position #{position}")
      send_command("go #{go}")
      loop do
        line = @stdout.gets
        next unless line
        return line.split[1] if line.start_with? "bestmove"
      end
    rescue StandardError
      if retries < 2
        close
        @stdin, @stdout, @stderr, @wait_thr = Open3.popen3(@engine_path)
        retries += 1
        retry
      else
        raise
      end
    ensure
      @stdout.flush
    end
  end

  def close
    begin
      send_command("quit")
    rescue StandardError
      nil
    end
    @stdin.close
    @stdout.close
    @stderr.close
    @wait_thr.terminate
  end
end
