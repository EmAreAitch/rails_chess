# frozen_string_literal: true

require_relative 'piece'

# Represents Bishop in Chess
# Responsible for dealing with game logic for bishop
class Bishop
  include Piece

  def score
    3
  end

  def fen_notation
    white? ? 'B' : 'b'
  end

  def legal_moves
    dimensions = []
    dimensions += @square.get_squares_in_diagonal(diagonal: :left, direction: :both)
    dimensions += @square.get_squares_in_diagonal(diagonal: :right, direction: :both)
    dimensions.reduce(Set.new) do |set, squares|
      set | adjust_captures(squares[..squares.index(&:piece?)])
    end
  end
end
