# frozen_string_literal: true

# Represents individual squares in chess board
# Responsible for tracking piece in that square of the chess board
class Square
  attr_reader :row, :column, :diagonal, :color, :piece, :notation

  VALID_DIAGONAL = %i[left right].freeze
  VALID_DIMENSION = %i[column row left_diagonal right_diagonal].freeze
  WHITE_BACKGROUND = "\e[48;2;230;200;160m"
  BLACK_BACKGROUND = "\e[48;2;181;136;99m"
  RESET_BACKGROUND = "\e[0m"
  def initialize(options:)
    @row = options[:row]
    @column = options[:column]
    @diagonal = options[:diagonal]
    @piece = options[:piece]
    @color = options[:color]
    @notation = options[:notation]
  end

  def put_piece(piece)
    return unless piece

    @piece&.assign_square(nil)
    piece.square&.remove_piece
    @piece = piece
    @piece.assign_square(self)
  end

  def inspect
    "#<#{self.class}:0x#{(object_id << 1).to_s(16)} @piece=#{@piece.inspect}, @color=#{@color}, @notation=#{@notation}>"
  end

  def piece?
    !@piece.nil?
  end

  def empty?
    !piece?
  end

  def piece_color?(color:)
    @piece&.color.eql?(color)
  end

  def remove_piece
    return nil unless piece?

    @piece&.assign_square(nil)
    temp_piece = @piece
    @piece = nil
    temp_piece
  end

  def get_squares_in_column(direction:, offset: nil)
    return @column.get_square_by_offset(self, offset, direction:) if offset

    @column.get_squares(self, direction:)
  end

  def get_squares_in_row(direction:, offset: nil)
    return @row.get_square_by_offset(self, offset, direction:) if offset

    @row.get_squares(self, direction:)
  end

  def get_nearest_occupied_square(dimension:, direction:)
    unless VALID_DIMENSION.include? dimension
      raise ArgumentError, ":#{dimension} Invalid dimension"
    end

    case dimension
    when :column
      @column.get_nearest_occupied_square(self, direction:)
    when :row
      @row.get_nearest_occupied_square(self, direction:)
    else
      diagonal = dimension.to_s.split("_").first.to_sym
      @diagonal[diagonal].get_nearest_occupied_square(self, direction:)
    end
  end

  def get_squares_in_diagonal(diagonal:, direction:, offset: nil)
    unless VALID_DIAGONAL.include? diagonal
      raise ArgumentError, ":#{diagonal} Invalid Diagonal"
    end
    if offset
      return @diagonal[diagonal].get_square_by_offset(self, offset, direction:)
    end

    @diagonal[diagonal].get_squares(self, direction:)
  end

  def get_squares_in_between(square)
    common_dimension = nil
    dimensions = [@column, @row] + @diagonal.values
    dimensions.each do |dimension|
      if dimension.squares.include? square
        common_dimension = dimension
        break
      end
    end
    common_dimension&.get_squares_in_between(self, square) || []
  end
end
