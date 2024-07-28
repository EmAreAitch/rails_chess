# frozen_string_literal: true

require_relative 'piece'
require_relative '../move/en_passant_move'

# Represents pawn in Chess
# Responsible for dealing with game logic for pawn
class Pawn
  include Piece

  def move_direction(opposite: false)
    return white? ? :above : :below unless opposite

    white? ? :below : :above
  end

  def score
    1
  end

  def distance
    moved_before? ? 1 : 2
  end

  def fen_notation
    white? ? 'P' : 'p'
  end

  def standard_legal_moves
    direction = move_direction
    front_squares = Set.new
    front_squares |= @square.get_squares_in_column(direction:)[...distance].take_while(&:empty?)
    diagonals = [@square.get_squares_in_diagonal(diagonal: :left, direction:, offset: 1),
                 @square.get_squares_in_diagonal(diagonal: :right, direction:, offset: 1)]
    front_squares | diagonals.compact.filter { |square| square.piece&.color.eql? opponent_color }
  end

  def en_passant_square
    direction = move_direction
    opp_direction = move_direction(opposite: true)
    diagonals = [@square.get_squares_in_diagonal(diagonal: :left, direction:, offset: 1),
                 @square.get_squares_in_diagonal(diagonal: :right, direction:, offset: 1)]
    diagonals.find do |diagonal|
      piece = diagonal&.get_squares_in_column(direction: opp_direction, offset: 1)&.piece
      piece and piece.moves_count == 1 and piece.last_moved and enemy?(piece)
    end
  end

  def legal_moves
    standard_legal_moves | [*en_passant_square]
  end

  def move_to(end_square)
    if standard_legal_moves.include?(end_square)
      move = StandardMove.new(self, end_square)
    elsif !end_square.nil? && (en_passant_square == (end_square))
      move = EnPassantMove.new(self, end_square)
    else
      raise IllegalMove, "#{self.class} can't be moved there"
    end

    move.perform
    move
  end
end
