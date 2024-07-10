require "open3"

class Stockfish
  def initialize(name:)
    @engine_path = Rails.root.join('lib','stockfish','stockfish').to_s
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
    send_command("position #{position}")
    send_command("go #{go}")
    loop do
      line = @stdout.gets
      next unless line
      return line.split[1] if line.start_with? "bestmove"
    end
  end

  def close
    send_command("quit")
    @stdin.close
    @stdout.close
    @stderr.close
  end
end
