# frozen_string_literal: true

require_relative 'piece'
require_relative '../move/castling_move'

# Represents king in Chess
# Responsible for dealing with game logic for king
class King
  include Piece

  def legal_moves
    standard_legal_moves | castling_moves
  end

  def standard_legal_moves
    dimensions = []
    dimensions += @square.get_squares_in_diagonal(diagonal: :left, direction: :both, offset: 1)
    dimensions += @square.get_squares_in_diagonal(diagonal: :right, direction: :both, offset: 1)
    dimensions += @square.get_squares_in_column(direction: :both, offset: 1)
    dimensions += @square.get_squares_in_row(direction: :both, offset: 1)
    dimensions.compact.reduce(Set.new) do |set, squares|
      set | adjust_captures([squares])
    end
  end

  def castling_moves
    return [] if moved_before?

    side_squares = square.get_squares_in_row(direction: :both).filter do |squares|
      piece = squares[-1]&.piece
      piece.is_a?(Rook) and piece.color == color and !piece.moved_before?
    end
    temp_square = square
    set = valid_castling_squares(side_squares)
    temp_square.put_piece self
    set
  end

  def threats?(dimension:)
    threats = find_threats(dimension:)
    threats.reject! { |piece| (piece.is_a?(Pawn) or piece.is_a?(King)) and !next_to_each_other?(piece) }
    case dimension
    when :column, :row
      straight_attack?(threats)
    when :left_diagonal, :right_diagonal
      diagonal_attack?(threats)
    when :l_shape
      knight_attack?(threats)
    end
  end

  def score
    0
  end

  def fen_notation
    white? ? 'K' : 'k'
  end

  def move_to(end_square)
    if standard_legal_moves.include?(end_square)
      move = StandardMove.new(self, end_square)
    elsif !end_square.nil? && castling_moves.include?(end_square)
      move = CastlingMove.new(self, end_square)
    else
      raise IllegalMove, "#{self.class} can't be moved there"
    end

    move.perform
    move
  end

  private

  def valid_castling_squares(side_squares)
    side_squares.each_with_object(Set.new) do |squares, set|
      next unless squares[...-1].all?(&:empty?)

      no_threats = squares[...2].none? do |square|
        square.put_piece self
        %i[column row right_diagonal left_diagonal l_shape].any? { |dimension| threats?(dimension:) }
      end
      set << squares[1] if no_threats
    end
  end

  def l_shape_square
    v_hops = @square.get_squares_in_column(direction: :both, offset: 2)
    h_hops = @square.get_squares_in_row(direction: :both, offset: 2)
    turns = v_hops.reduce([]) { |l, square| l + [*square&.get_squares_in_row(direction: :both, offset: 1)] }
    turns += h_hops.reduce([]) { |l, square| l + [*square&.get_squares_in_column(direction: :both, offset: 1)] }
    turns
  end

  def find_threats(dimension:)
    squares = if dimension.eql? :l_shape
                l_shape_square
              else
                square.get_nearest_occupied_square(dimension:, direction: :both)
              end

    squares.compact.map(&:piece).filter { |piece| piece&.color == opponent_color }
  end

  def next_to_each_other?(piece)
    piece.square.get_squares_in_between(@square).length == 1
  end

  def straight_attack?(threats)
    threats.any? { |threat| threat.is_a?(Rook) || threat.is_a?(Queen) || threat.is_a?(King) }
  end

  def diagonal_attack?(threats)
    threats.any? { |threat| threat.is_a?(Bishop) || threat.is_a?(Queen) || threat.is_a?(Pawn) || threat.is_a?(King) }
  end

  def knight_attack?(threats)
    threats.any?(Knight)
  end
end
