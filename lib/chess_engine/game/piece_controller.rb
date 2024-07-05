# frozen_string_literal: true

%w[king queen rook bishop knight pawn].each do |file|
  require_relative "../piece/#{file}"
end
require_relative "../player/player"
require_relative "end_game_logic"
require_relative "game_end"

# Represents Pieces in Chess
# Responsible for dealing with game logic for chess moves
class PiecesController
  include EndGameLogic
  attr_reader :captured, :white_player, :black_player, :current_player

  def initialize(board:, white:, black:)
    @board = board
    @last_moved_piece = nil
    @move_list = []
    @game_winner = nil
    @winner_color = nil
    @full_move = 1
    @half_move = 0
    initialize_both_player(white:, black:)
  end

  def board_state
    @board.rows.join("/") + " #{@current_player.color[0]}" +
      " #{castling_rights}" + " #{en_passant_rights}" + " #{@half_move}" +
      " #{@full_move}"
  end

  def castling_rights
    rights = @white_player.castling_rights + @black_player.castling_rights
    return rights.empty? ? "-" : rights
  end

  def en_passant_rights
    unless @last_moved_piece.is_a? Pawn and @last_moved_piece.moves_count == 1 and @move_list.last.is_a? EnPassantMove
      return "-"
    end
    last_move = @move_list.last
    from_square = last_move.from_square
    to_square = last_move.to_square
    puts "FROM_SQUARE #{from_square} - TO_SQUARE #{to_square}"
    en_passant_square =
      from_square.get_squares_in_between(to_square).find { |i| i != to_square }
    return en_passant_square.notation.downcase
  end

  def game_state
    { status: game_status, winner: @game_winner, color: @winner_color }
  end

  def change_last_moved_piece(piece)
    return if piece.nil?

    @last_moved_piece&.last_moved = false
    @last_moved_piece = piece
    @last_moved_piece.last_moved = true
    # Rails.logger.info "Last move #{@last_moved_piece.square.notation}"
    @last_moved_piece.last_moved
  end

  def legal_piece(piece)
    raise IllegalMove, "No piece to move" unless piece
    unless piece.belongs_to? @current_player
      raise IllegalMove, "Piece does not belongs to current player"
    end
  end

  def initialize_both_player(white:, black:)
    @white_player = white
    @black_player = black
    @white_player.assign_opponent @black_player
    @black_player.assign_opponent @white_player
    @current_player = @white_player
  end

  def place_starting_pieces
    place_player_edge_pieces(@white_player)
    place_player_pawns(@white_player)
    place_player_edge_pieces(@black_player)
    place_player_pawns(@black_player)
  end

  def place_player_pawns(player)
    index = player.white? ? -2 : 1
    @board.rows[index].fill(player.pawns)
  end

  def place_player_edge_pieces(player)
    index = player.white? ? -1 : 0
    @board.rows[index].fill(player.back_row)
  end

  def make_move(move, promotion)
    start_square, end_square = get_move_squares(move)
    piece = start_square.piece
    legal_piece(piece)
    move = perform_move(piece, end_square, @current_player)
    add_move_to_list(move)
    @current_player.promote_pawn(piece, promotion) if move.promotional?
    alter_player
  end

  def perform_move(piece, end_square, player)
    move = piece.move_to(end_square)
    check = in_check?(player)
    move.rollback if check
    raise Check if check
    move
  end

  def add_move_to_list(move)
    @move_list << move
    change_last_moved_piece(move.piece)
  end

  def undo_last_move
    return if @move_list.empty?

    last_move = @move_list.pop
    last_move.rollback
    change_last_moved_piece(@move_list.last.piece)
    alter_player
  end

  def get_move_squares(move)
    start_notation = move[...2]
    end_notation = move[2...4]
    start_square = @board.get_square_by_notation(start_notation)
    end_square = @board.get_square_by_notation(end_notation)
    [start_square, end_square]
  end

  def alter_player
    @current_player =
      @current_player.eql?(@white_player) ? @black_player : @white_player
    @full_move += 1 if @current_player.white?
    @half_move += 1
    if @last_moved_piece.is_a? Pawn or @move_list.last.capture_move?
      @half_move = 0
    end
  end

  def opponent_color(color)
    unless %i[white black].include?(color)
      raise ArgumentError, "Invalid Color, It must be in :white or :black"
    end

    color.eql?(:white) ? :black : :white
  end

  def game_status
    if in_check?(@current_player)
      if checkmate?(@current_player) &&
           @game_winner = @current_player.opponent.name
        @winner_color = @current_player.opponent.color
        return :checkmate
      end
    else
      return :stalemate if stalemate?(@current_player)
    end
    :in_progress
  end
end
