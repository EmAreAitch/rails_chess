# frozen_string_literal: true

require_relative 'square'
require_relative 'dimension'
# Represents columns in chess board
# Responsible for tracking pieces in that column of the chess board
class Column
  include Dimension

  def valid_directions
    %i[above below both].freeze
  end
end
