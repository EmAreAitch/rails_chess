# frozen_string_literal: true

require_relative 'square'
require_relative 'dimension'

# Represents diagonals in chess board
# Responsible for tracking pieces in that diagonal of the chess board
class Diagonal
  include Dimension

  def valid_directions
    %i[above below both].freeze
  end
end
