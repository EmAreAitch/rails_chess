# require_relative "../../lib/chess_engine/chess.rb"
# require_relative '../services/stockfish'

require 'benchmark'

class BotChannel < ApplicationCable::Channel
  def subscribed
    @difficulty = fetch_difficulty_timeframe
    return unless @difficulty
    @stockfish = Stockfish.new(name: "Botty")
    @chess = Chess.new
    transmit({ status: :room_joined, room: room_code, color: :white })
    start_game
  end

  def receive(data)
    unless current_player?
      transmit({ status: :failed, message: "Not your turn" })
      return
    end
    begin
      perform_move(data)
      update_player
      movetime = rand(@difficulty)
      sleep(1-movetime/1000.0)
      perform_move(get_stockfish_move(movetime))
      update_player
    rescue ChessExceptionModule::StandardChessException, ChessException => e
      transmit({ status: :failed, message: e.message })
    end
  end

  def unsubscribed
    @stockfish.close
  end

  def resign
  end

  def offer_draw
  end

  def draw_offer_response(data)

  end

  private

  def update_player
    board_state = build_board_state
    transmit(board_state)
    game_state = build_game_state
    unless game_state[:status] == :in_progress
      sleep 2
      transmit(game_state)
    end
  end

  def room_code
    {
      easy_bot: '000001',
      normal_bot: '000002',
      hard_bot: '000003',
    }[params[:difficulty].to_sym]
  end

  def perform_move(data)
    @chess.make_move(data)
  end

  def fetch_difficulty_timeframe
    unless params[:difficulty].present?
      transmit({ status: :error })
      reject
      return
    end
    return {
      easy_bot: (50..200),
      normal_bot: (200..500),
      hard_bot: (500..1000)
    }[params[:difficulty].to_sym]
  end

  def get_stockfish_move(movetime)
    move =
      @stockfish.best_move(
        "fen #{@chess.board_state}",
        "movetime #{movetime}"
      )
    return { "move" => move[...4], "promotion" => move[4..] }
  end

  def start_game
    @chess.add_player(self)
    @chess.add_player(@stockfish)
    @chess.start_game
    transmit({ status: :game_started, **@chess.players_details })
  end

  def build_board_state
    { status: :success, state: @chess.board_state }
  end

  def build_game_state
    @chess.game_state
  end

  def current_player?
    @chess.current_player.name.eql? current_player
  end
end
