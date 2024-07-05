# frozen_string_literal: true

# Represents individual chess moves
class StandardMove
  attr_reader :piece, :capture, :from_square, :to_square

  def initialize(piece, to_square)
    unless piece.is_a?(Piece) && to_square.is_a?(Square)
      raise "No piece to move"
    end

    @piece = piece
    @to_square = to_square
    @from_square = piece.square
    @capture = @to_square.piece
    @performable = true
  end

  def capture_move?
    !@capture.nil?
  end

  def perform
    return unless @performable

    @to_square.put_piece @piece
    @piece.increase_move_count
    @performable = false
  end

  def rollback
    return if @performable

    @from_square.put_piece @piece
    @to_square.put_piece @capture
    @piece.decrease_move_count
    @performable = true
  end

  def promotional?
    return false unless piece.is_a? Pawn
    if piece.white? and @from_square.notation[1] == "7" and
         @to_square.notation[1] == "8"
      return true
    end
    if piece.black? and @from_square.notation[1] == "2" and
         @to_square.notation[1] == "1"
      return true
    end
    return false
  end
end
