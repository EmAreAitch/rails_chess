# frozen_string_literal: true

# Class to represent individual player in game and all its properties
class Player
  attr_reader :color, :opponent, :pieces, :pieces_list, :name

  def initialize(name, color:)
    @name = name
    @color = color
    @pieces = initialize_pieces
    @pieces_list = pieces.values.flatten(1)
    @opponent = nil
  end

  def initialize_pieces
    {
      king: King.new(color: @color),
      queens: Array.new(1) { Queen.new(color: @color) },
      rooks: Array.new(2) { Rook.new(color: @color) },
      bishops: Array.new(2) { Bishop.new(color: @color) },
      knights: Array.new(2) { Knight.new(color: @color) },
      pawns: Array.new(8) { Pawn.new(color: @color) }
    }
  end

  def assign_opponent(opponent)
    @opponent = opponent
  end

  def white?
    @color.eql?(:white)
  end

  def black?
    @color.eql?(:black)
  end

  def pieces_on_board
    @pieces_list.filter(&:on_board?)
  end

  def legal_moves
    pieces_on_board.reduce(Set.new) { |set, piece| set | piece.legal_moves }
  end

  def king
    @pieces[:king]
  end

  def queens
    @pieces[:queens]
  end

  def pawns
    @pieces[:pawns]
  end

  def rooks
    @pieces[:rooks]
  end

  def bishops
    @pieces[:bishops]
  end

  def knights
    @pieces[:knights]
  end

  def back_row
    [
      rooks[0],
      knights[0],
      bishops[0],
      queens[0],
      king,
      bishops[1],
      knights[1],
      rooks[1]
    ]
  end

  def castling_rights
    return "" if king.moved_before?
    rights = ""
    rights += "K" unless rooks[1].moved_before?
    rights += "Q" unless rooks[0].moved_before?
    return white? ? rights : rights.downcase
  end

  def to_s
    @name
  end

  def captures
    @opponent.pieces_list.reject(&:on_board?)
  end

  def promote_pawn(pawn, promoted_piece)
    temp_pawn = pawns.delete(pawn)
    raise "Invalid promotion" unless temp_pawn
    promoted_piece = to_piece_symbol(promoted_piece)
    square = temp_pawn.square
    new_piece = build_piece(promoted_piece)
    square.put_piece new_piece
    @pieces[promoted_piece] << new_piece
    @pieces_list << new_piece
  end

  def build_piece(promoted_piece_notation)
    {
      queens: Queen.new(color: @color),
      rooks: Rook.new(color: @color),
      bishops: Bishop.new(color: @color),
      knights: Knight.new(color: @color)
    }[
      promoted_piece_notation
    ]
  end

  def to_piece_symbol(promoted_piece)
    { Q: :queens, N: :knights, R: :rooks, B: :bishops }[
      promoted_piece.upcase.to_sym
    ]
  end

  def castling_fen
    return "" if king.moved_before?

    string = ""
    string += (white? ? "K" : "k") unless rooks[1].moved_before?
    string += (white? ? "Q" : "q") unless rooks[0].moved_before?
    string
  end
end
