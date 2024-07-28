class PvpChannel < ApplicationCable::Channel
  def subscribed
    set_room_code
    unless @room_code.present?
      transmit({ status: :error, message: "Room not found" })
      reject
      return
    end
    stream_from "game_#{@room_code}"
    transmit({ status: :room_joined, room: @room_code, color: player_color })
    game_manager.add_player_to_room(@room_code, DRbObject.new(self), @color)
    start_game unless game_manager.room_has_space?(@room_code)
  end

  def receive(data)
    unless current_player?
      transmit(
        {
          status: :failed,
          message: "Not your turn",
          state: game_manager.board_state(@room_code)
        }
      )
      return
    end
    begin
      game_manager.make_move(@room_code, data)
      ActionCable.server.broadcast "game_#{@room_code}", build_board_state
      game_state = build_game_state
      unless game_state[:status] == :in_progress
        sleep 0.2
        ActionCable.server.broadcast "game_#{@room_code}", game_state
      end
    rescue ChessExceptionModule::StandardChessException, ChessException => e
      transmit(
        {
          status: :failed,
          message: e.message,
          state: game_manager.board_state(@room_code)
        }
      )
    end
  end

  def unsubscribed
    if @room_code.present?
      players = game_manager.retrieve_players(@room_code)
      game_manager.flush_game(@room_code)
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

  def resign
    players = game_manager.retrieve_players(@room_code)
    oppo = players.find { |player| player.player_color != @color }
    oppo.transmit_data({ status: "opponent_resign" })
  end

  def transmit_data(data)
    transmit(data)
  end

  def player_color
    if game_manager.room_has_space?(@room_code)
      @color ||= game_manager.players_details(@room_code).key(nil).to_sym
    else
      @color ||= params[:color]&.to_sym || :white
    end
    @color
  end

  def offer_draw
    if game_manager.can_offer_draw?(@room_code)
      ActionCable.server.broadcast "game_#{@room_code}",
                                   { status: :draw_offered, color: @color }
      game_manager.offer_draw(@room_code, from: @color)
    else
      transmit({ status: :draw_cooldown })
    end
  end

  def draw_offer_response(data)
    draw_valid = game_manager.draw_response(@room_code, data, from: @color)
    if draw_valid
      if draw_valid
        ActionCable.server.broadcast "game_#{@room_code}",
                                     { status: :draw_accepted }
      end
    else
      players = game_manager.retrieve_players(@room_code)
      oppo = players.find { |player| player.player_color != @color }
      oppo.transmit_data({ status: :draw_rejected })
    end
  end

  private

  def game_manager
    $GameManager
  end

  def start_game
    game_manager.start_game(@room_code)
    ActionCable.server.broadcast "game_#{@room_code}",
                                 {
                                   status: :game_started,
                                   **game_manager.players_details(@room_code)
                                 }
  end

  def set_room_code
    if params[:room_code]&.match?(/^\d{6}$/) &&
         game_manager.room_has_space?(params[:room_code])
      @room_code = params[:room_code]
    elsif params[:vs_friend]
      @room_code = game_manager.generate_room_code
    elsif params[:room_code].nil?
      @room_code = game_manager.get_room_from_queue
    end
  end

  def build_board_state
    { status: :success, state: game_manager.board_state(@room_code) }
  end

  def build_game_state
    game_manager.game_state(@room_code)
  end

  def current_player?
    game_manager.current_player_name(@room_code).eql? current_player
  end
end
