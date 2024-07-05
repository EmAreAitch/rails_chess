# frozen_string_literal: true

# Represents individual chess moves
class CastlingMove
  attr_reader :piece, :capture

  def initialize(piece, to_square)
    unless piece.is_a?(Piece) && to_square.is_a?(Square)
      raise "No piece to move"
    end

    @to_square = to_square
    @from_square = piece.square
    @rook = @from_square.get_squares_in_row(direction: move_direction)[-1].piece
    raise "No rook on the side" unless @rook.is_a?(Rook)

    @rook_square = @rook.square
    @piece = piece
    @performable = true
  end

  def capture_move?
    false
  end

  def move_direction
    column = @to_square.notation[0]
    return :left if column.eql?("C")

    :right if column.eql?("G")
  end

  def to_rook_square
    @from_square.get_squares_in_row(direction: move_direction, offset: 1)
  end

  def perform
    return unless @performable

    @to_square.put_piece @piece
    @piece.increase_move_count
    to_rook_square.put_piece @rook
    @rook.increase_move_count
    @performable = false
  end

  def rollback
    return if @performable

    @from_square.put_piece @piece
    @piece.decrease_move_count
    @rook_square.put_piece @rook
    @rook.decrease_move_count
    @performable = true
  end

  def promotional?
    false
  end
end
