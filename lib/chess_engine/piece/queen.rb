# frozen_string_literal: true

require_relative 'piece'

# Represents queen in Chess
# Responsible for dealing with game logic for queen
class Queen
  include Piece


  def score
    9
  end

  def fen_notation
    white? ? 'Q' : 'q'
  end

  def legal_moves
    dimensions = []
    dimensions += @square.get_squares_in_diagonal(diagonal: :left, direction: :both)
    dimensions += @square.get_squares_in_diagonal(diagonal: :right, direction: :both)
    dimensions += @square.get_squares_in_column(direction: :both)
    dimensions += @square.get_squares_in_row(direction: :both)
    dimensions.reduce(Set.new) do |set, squares|
      set | adjust_captures(squares[..squares.index(&:piece?)])
    end
  end
end
