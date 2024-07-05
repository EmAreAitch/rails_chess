# frozen_string_literal: true

require_relative 'piece'

# Represents knight in Chess
# Responsible for dealing with game logic for knight
class Knight
  include Piece

  def score
    3
  end

  def fen_notation
    white? ? 'N' : 'n'
  end

  def legal_moves
    v_hops = @square.get_squares_in_column(direction: :both, offset: 2)
    h_hops = @square.get_squares_in_row(direction: :both, offset: 2)
    turns = v_hops.reduce([]) { |l, square| l + [*square&.get_squares_in_row(direction: :both, offset: 1)] }
    turns += h_hops.reduce([]) { |l, square| l + [*square&.get_squares_in_column(direction: :both, offset: 1)] }
    turns.compact.reduce(Set.new) do |set, square|
      set | adjust_captures([square])
    end
  end
end
