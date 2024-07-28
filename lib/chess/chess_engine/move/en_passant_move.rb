# frozen_string_literal: true

# Represents individual chess moves
class EnPassantMove
  attr_reader :piece, :capture

  def initialize(piece, to_square)
    unless piece.is_a?(Piece) && to_square.is_a?(Square)
      raise "No piece to move"
    end

    opp_direction = piece.move_direction(opposite: true)
    @capture =
      to_square.get_squares_in_column(
        direction: opp_direction,
        offset: 1
      )&.piece
    raise "Invalid Enpassant" unless @capture

    @capture_square = @capture.square
    @piece = piece
    @to_square = to_square
    @from_square = piece.square
    @performable = true
  end

  def capture_move?
    true
  end

  def promotional?
    false
  end

  def perform
    return unless @performable

    @to_square.put_piece @piece
    @capture_square.remove_piece
    @piece.increase_move_count
    @performable = false
  end

  def rollback
    return if @performable

    @from_square.put_piece @piece
    @capture_square.put_piece @capture
    @piece.decrease_move_count
    @performable = true
  end
end
