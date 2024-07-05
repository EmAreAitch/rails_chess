# frozen_string_literal: true

require_relative "../move/standard_move"
#  module for pieces
module Piece
  WHITE_FONT = "\e[38;2;255;255;255m"
  BLACK_FONT = "\e[38;2;0;0;0m"
  BOLD = "\e[1m"

  attr_reader :square, :color, :last_moved, :moves_count

  def initialize(color:)
    @color = color
    @square = nil
    @moves_count = 0
    @last_moved = false
  end

  def belongs_to?(player)
    player.color == @color
  end

  def last_moved=(bool)
    return unless bool.is_a?(TrueClass) || bool.is_a?(FalseClass)

    @last_moved = bool
  end

  def moved_before?
    @moves_count.positive?
  end

  def white?
    @color.eql?(:white)
  end

  def assign_square(square)
    @square = square
  end

  def black?
    @color.eql?(:black)
  end

  def opponent_color
    white? ? :black : :white
  end

  def inspect
    "#<#{self.class}:0x#{(object_id << 1).to_s(16)} @color=#{@color} \
    @moves_count=#{@moves_count}> @last_moved=#{@last_moved}"
  end

  def on_board?
    !@square.nil?
  end

  def move_to(end_square)
    unless legal_moves.include?(end_square)
      raise IllegalMove, "#{self.class} can't be moved there"
    end

    move = StandardMove.new(self, end_square)
    move.perform
    move
  end

  def increase_move_count
    @moves_count += 1
  end

  def decrease_move_count
    @moves_count -= 1 unless @moves_count.zero?
  end

  def enemy?(piece)
    piece&.color.eql?(opponent_color)
  end

  def adjust_captures(squares)
    return squares if squares[-1]&.empty? || enemy?(squares[-1]&.piece)

    squares[...-1]
  end

  def special_moves
    Set.new
  end

  def legal_moves
    raise NotImplementedError,
          "#{self.class} has not implemented abstract method '#{__method__}'"
  end
end
