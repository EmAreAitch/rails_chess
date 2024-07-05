require_relative "../../lib/chess_engine/chess_engine.rb"
require 'concurrent-ruby'

class GameManager
  include Singleton

  def initialize
    @games = Concurrent::Hash.new
  end

  def start_game(game_id)
    game = @games[game_id]
    game.start_game if game
  end

  def add_player_to_room(game_id, player)
    @games[game_id] = Chess.new unless @games.key? game_id
    @games[game_id].add_player(player)
    game = @games[game_id]
    unless room_has_space?(game_id)
      start_game(game_id)
      ActionCable.server.broadcast "game_#{game_id}",
                                   {
                                     status: :game_started,
                                     **game.players_details
                                   }
    end
  end

  def room_has_space?(game_id)
    @games[game_id]&.space_for_player?
  end

  def flush_game(game_id)
    @games.delete(game_id)
  end

  def make_move(game_id, move_data)
    game = @games[game_id]
    game.make_move(move_data) if game
  end

  def current_player_name(game_id)
    game = @games[game_id]
    game.current_player.name if game
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
end
