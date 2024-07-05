# frozen_string_literal: true

# Helper for board dimensions i.e row, column, diagonal
module Dimension
  attr_reader :squares

  def initialize(squares:)
    unless squares.is_a?(Array) && squares.all?(Square)
      raise ArgumentError,
            "#{self.class} takes array of square objects only"
    end

    @squares = squares
  end

  def [](square_index)
    return nil if square_index.is_a?(Integer) && square_index.negative?

    @squares[square_index]
  end

  def push(square)
    raise ArgumentError, 'Object must of Square type' unless square.is_a?(Square)

    @squares.push(square)
  end

  def fill(pieces)
    pieces[0...@squares.length].each_with_index do |piece, index|
      @squares[index].put_piece(piece)
    end
  end

  def to_s
    @squares.map(&:to_s).join
  end

  def valid_directions
    raise NotImplementedError, "#{self.class} has not implemented abstract method '#{__method__}'"
  end

  def get_squares(square, direction:)
    valid_dirs = valid_directions
    raise ArgumentError, ":#{direction} Invalid Direction" unless valid_dirs.include? direction

    return nil unless (square_index = @squares.index(square))

    if direction.eql? valid_dirs[0]
      @squares[...square_index].reverse
    elsif direction.eql? valid_dirs[1]
      @squares[square_index + 1..]
    else
      [@squares[...square_index].reverse, @squares[square_index + 1..]]
    end
  end

  def get_square_by_offset(square, offset, direction:)
    valid_dirs = valid_directions
    raise ArgumentError, ":#{direction} Invalid Direction" unless valid_dirs.include? direction

    return nil unless (square_index = @squares.index(square))

    if direction.eql? valid_dirs[0]
      self[square_index - offset]
    elsif direction.eql? valid_dirs[1]
      self[square_index + offset]
    else
      [self[square_index + offset], self[square_index - offset]]
    end
  end

  def get_squares_in_between(start_square, end_square)
    start_index = @squares.index(start_square)
    end_index = @squares.index(end_square)
    return [] if [start_index, end_index].any?(&:nil?)

    min, max = [start_index, end_index].minmax
    @squares[min + 1..max]
  end

  def get_nearest_occupied_square(square, direction:)
    valid_dirs = valid_directions
    raise ArgumentError, ":#{direction} Invalid Direction" unless valid_dirs.include? direction

    return nil unless (square_index = @squares.index(square))

    if direction.eql? valid_dirs[0]
      find_occupied_square(square_index)
    elsif direction.eql? valid_dirs[1]
      find_occupied_square(square_index, reverse: true)
    else
      [find_occupied_square(square_index), find_occupied_square(square_index, reverse: true)]
    end
  end

  private

  def find_occupied_square(square_index, reverse: false)
    return @squares[square_index + 1..].find(&:piece?) unless reverse == true

    @squares[...square_index].reverse.find(&:piece?)
  end
end
