require "benchmark"

class BotChannel < ApplicationCable::Channel
  def subscribed
    @difficulty = fetch_difficulty_timeframe
    return unless @difficulty
    @stockfish = Stockfish.instance
    @chess = Chess.new
    transmit({ status: :room_joined, room: room_code, color: get_player_color })
    start_game
    if get_player_color == "black"
      sleep 0.5
      perform_bot_move
      update_player
    end
  end

  def receive(data)
    unless current_player?
      transmit(
        { status: :failed, message: "Not your turn", state: @chess.board_state }
      )
      return
    end
    begin
      perform_move(data)
      update_player
      if game_in_progress?
        perform_bot_move
        update_player
      end
    rescue ChessExceptionModule::StandardChessException, ChessException => e
      transmit(
        { status: :failed, message: e.message, state: @chess.board_state }
      )
    end
  end

  def resign
  end

  def offer_draw
  end

  def draw_offer_response(data)
  end

  private

  def get_player_color
    return :white unless params[:color]
    params[:color]
  end

  def perform_bot_move
    delay_time = 0.5.seconds.from_now
    perform_move(get_stockfish_move)
    sleep(delay_time - Time.now) if (delay_time - Time.now).positive?
  end

  def update_player
    board_state = build_board_state
    transmit(board_state)
    game_state = build_game_state
    unless game_state[:status] == :in_progress
      sleep 0.2
      transmit(game_state)
    end
  end

  def room_code
    { easy_bot: "000001", normal_bot: "000002", hard_bot: "000003" }[
      params[:difficulty].to_sym
    ]
  end

  def perform_move(data)
    @chess.make_move(data)
  end

  def fetch_difficulty_timeframe
    unless params[:difficulty].present?
      transmit({ status: :error, message: "Difficulty not found" })
      reject
      return
    end
    return(
      { easy_bot: 800, normal_bot: 1200, hard_bot: 1600 }[
        params[:difficulty].to_sym
      ]
    )
  end

  def get_stockfish_move()
    begin
      move =
        @stockfish.best_move(
          "fen #{@chess.board_state}",
          "movetime 500",
          @difficulty
        )
      return { "move" => move[...4], "promotion" => move[4..] }
    rescue StandardError
      transmit({ status: :room_destroyed, message: "Server Error!!" })
    end
  end

  def start_game
    player_obj = Struct.new(:current_player).new("Botty")
    color = get_player_color.to_sym
    @chess.add_player(self, color)
    @chess.add_player(player_obj, color == :white ? :black : :white)
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

  def game_in_progress?
    @chess.game_state[:status] == :in_progress
  end
end
