require_relative "chess_exception"
require_relative "board/board"
require_relative "game/piece_controller"
require_relative "player/player"

class Chess
  include ChessExceptionModule
  attr_reader :players

  def initialize
    @black_player = nil
    @white_player = nil
    @board = nil
    @piece_controller = nil
    @players = []
  end

  def add_player(player)
    raise GameIsFull if @black_player and @white_player
    if @white_player.nil?
      @white_player = Player.new(player.current_player, color: :white)
      @players << player
    else
      @black_player = Player.new(player.current_player, color: :black)
      @players << player
    end
  end

  def start_game
    raise PlayerMissing unless @white_player and @black_player
    @board = Board.new
    @piece_controller =
      PiecesController.new(
        board: @board,
        white: @white_player,
        black: @black_player
      )
    @piece_controller.place_starting_pieces
  end

  def board_state
    @piece_controller.board_state
  end

  def game_state
    @piece_controller.game_state
  end

  def make_move(move_data)
    raise InvalidNotation unless validate_move(move_data["move"])
    @piece_controller.make_move(move_data["move"], move_data["promotion"])
  end

  def space_for_player?
    @white_player.nil? or @black_player.nil?
  end

  def current_player
    @piece_controller.current_player
  end

  def players_details
    {
      white: @white_player.name,
      black: @black_player.name
    }
  end

  private

  def validate_move(move)
    return false unless move.is_a?(String) and move.length == 4
    move.downcase!
    move
      .chars
      .each_slice(2) do |(col, row)|
        return false unless col.between?("a", "h") and row.between?("1", "8")
      end
    return true
  end
end
