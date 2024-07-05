class PvpChannel < ApplicationCable::Channel
  def subscribed
    set_room_code
    unless @room_code.present?
      transmit({ status: :error })
      reject
      return
    end
    stream_from "game_#{@room_code}"
    transmit({ status: :room_joined, room: @room_code, color: player_color() })
    GameManager.instance.add_player_to_room(@room_code, self)
  end

  def receive(data)
    unless current_player?
      transmit({ status: :failed, message: "Not your turn" })
      return
    end
    begin
      GameManager.instance.make_move(@room_code, data)
      ActionCable.server.broadcast "game_#{@room_code}", build_board_state
      game_state = build_game_state
      unless game_state[:status] == :in_progress
        ActionCable.server.broadcast "game_#{@room_code}", game_state
      end
    rescue ChessExceptionModule::StandardChessException, ChessException => e
      transmit({ status: :failed, message: e.message })
    end
  end

  def unsubscribed
    if @room_code.present?
      players = GameManager.instance.retrieve_players(@room_code)
      GameManager.instance.flush_game(@room_code)
      players.each do |player|
        player.transmit_data(
          {
            status: :room_destroyed,
            message: "#{current_player} left the game"
          }
        )
      end
    end
    stop_stream_from "game_#{@room_code}"
  end

  def transmit_data(data)
    transmit(data)
  end

  private

  def player_color
    GameManager.instance.room_has_space?(@room_code) ? :black : :white
  end

  def set_room_code
    if params[:room_code].present?
      if params[:room_code].match?(/^\d{6}$/) &&
        GameManager.instance.room_has_space?(params[:room_code])
        @room_code = params[:room_code]
      end
    else
      @room_code = generate_room_code
    end
  end

  def generate_room_code
    SecureRandom.random_number(100_000...100_000_0).to_s
  end

  def build_board_state
    { status: :success, state: GameManager.instance.board_state(@room_code) }
  end

  def build_game_state
    GameManager.instance.game_state(@room_code)
  end

  def current_player?
    GameManager.instance.current_player_name(@room_code).eql? current_player
  end
end
