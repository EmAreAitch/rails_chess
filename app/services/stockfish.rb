require "open3"

class Stockfish
  include Singleton

  def initialize
    @engine_path = Rails.root.join("lib", "stockfish", "fairy_stockfish").to_s
    @queue = SizedQueue.new(2)
    2.times do
      engine = Open3.popen2(@engine_path)
      send_command(engine.first, "setoption name Hash value 1")
      send_command(engine.first, "setoption name UCI_LimitStrength value true")
      @queue << engine
    end
  end

  def send_command(stdin, command)
    stdin.puts command
    stdin.flush
  end

  def best_move(position, go, elo)
    stdin, stdout, wait_thr = @queue.pop
    retries = 0
    begin
      send_command(stdin, "setoption name UCI_Elo value #{elo}")
      send_command(stdin, "position #{position}")
      send_command(stdin, "go #{go}")
      loop do
        line = stdout.gets
        next unless line
        return line.split[1] if line.start_with? "bestmove"
      end
    rescue StandardError
      if retries < 2
        close([stdin, stdout, wait_thr])
        stdin, stdout, wait_thr = Open3.popen2(@engine_path)
        retries += 1
        retry
      else
        raise
      end
    ensure
      stdout.flush
      @queue << [stdin, stdout, wait_thr]
    end
  end

  def cleanup
    close(@queue.pop) until @queue.empty?
  end

  def close(engine)
    begin
      send_command(engine.first, "quit")
    rescue StandardError
      nil
    end
    engine.first(2).map(&:close)
    engine.last.terminate
  end
end
