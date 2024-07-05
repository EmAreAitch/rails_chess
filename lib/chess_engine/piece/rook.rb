# frozen_string_literal: true

require_relative 'piece'

# Represents rook in Chess
# Responsible for dealing with game logic for rook
class Rook
  include Piece

  def score
    5
  end

  def fen_notation
    white? ? 'R' : 'r'
  end

  def legal_moves
    dimensions = []
    dimensions += @square.get_squares_in_column(direction: :both)
    dimensions += @square.get_squares_in_row(direction: :both)
    dimensions.reduce(Set.new) do |set, squares|
      set | adjust_captures(squares[..squares.index(&:piece?)])
    end
  end
end
