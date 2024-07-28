require_relative "./chess_engine/chess_engine.rb"
require "concurrent-ruby"

class GameManager
  include Singleton

  def initialize
    @games = Concurrent::Map.new
    @room_queue = Queue.new
    return nil
  end

  def start_game(game_id)
    game = @games[game_id]
    game.start_game if game
    return nil
  end

  def add_player_to_room(game_id, player, color)
    @games.compute_if_absent(game_id) { Chess.new }
    @games[game_id].add_player(player, color)
    return nil
  end

  def get_room_from_queue
    code =
      begin
        @room_queue.pop(true)
      rescue StandardError
        nil
      end
    code = generate_room_code if code.nil?
    @room_queue << code unless @games.key? code
    return code
  end

  def players_details(game_id)
    @games[game_id]&.players_details
  end

  def room_has_space?(game_id)
    @games[game_id]&.space_for_player?
  end

  def flush_game(game_id)
    @games.delete(game_id)
    return nil
  end

  def make_move(game_id, move_data)
    game = @games[game_id]
    game&.make_move(move_data) if game
    return nil
  end

  def current_player_name(game_id)
    game = @games[game_id]
    game&.current_player.name if game
  end

  def game_state(game_id)
    @games[game_id]&.game_state
  end

  def board_state(game_id)
    @games[game_id]&.board_state
  end

  def retrieve_players(game_id)
    @games[game_id]&.players || []
  end

  def offer_draw(game_id, from:)
    @games[game_id]&.offer_draw(from)
    return nil
  end

  def draw_response(game_id, data, from:)
    @games[game_id]&.draw_response(data, from)
  end

  def can_offer_draw?(game_id)
    @games[game_id]&.can_offer_draw?
  end

  def generate_room_code
    loop do
      num = SecureRandom.random_number(100_000...100_000_0).to_s
      return num unless @games.key? num
    end
  end
end
