# frozen_string_literal: true

require_relative 'square'
require_relative 'dimension'

# Represents rows in chess board
# Responsible for tracking pieces in that row of the chess board
class Row
  include Dimension

  def valid_directions
    %i[left right both].freeze
  end

  def to_str
    @squares.reduce('') do |acc, square|
      if square.piece?
        acc + square.piece.fen_notation
      elsif acc[-1]&.match?(/\d/)
        (acc[...-1] || '') + (acc[-1].to_i + 1).to_s
      else
        "#{acc}1"
      end
    end
  end
end
