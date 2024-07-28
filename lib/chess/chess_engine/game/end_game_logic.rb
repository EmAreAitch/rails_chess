# frozen_string_literal: true

# Module for end game logic methods
module EndGameLogic
  def pieces_threatening_king(player)
    opponent = player.opponent
    king_square = player.king.square
    player_pieces = opponent.pieces_on_board
    player_pieces.filter { |piece| piece.legal_moves.include? king_square }
  end

  def in_check?(player)
    return true unless player.king.on_board?

    %i[column row right_diagonal left_diagonal l_shape].any? do |dimension|
      player.king.threats?(dimension:)
    end
  end

  def causes_check?(piece, end_square, player)
    move = piece.move_to(end_square)
    check = in_check?(player)
    move.rollback
    check
  end

  def checkmate?(player)
    !can_move_from_check?(player) && !can_block_check?(player)
  end

  def stalemate?(player)
    player.pieces_on_board.all? do |piece|
      piece.legal_moves.all? { |move| causes_check?(piece, move, player) }
    end
  end

  def can_move_from_check?(player)
    player.king.legal_moves.any? do |square|
      !causes_check?(player.king, square, player)
    end
  end

  def can_block_check?(player)
    pieces = pieces_threatening_king(player)
    return false unless pieces.length == 1

    squares_in_between =
      if pieces[0].is_a? Knight
        [pieces[0].square]
      else
        player.king.square.get_squares_in_between(pieces[0].square)
      end
    any_piece_blocks_threat?(player, squares_in_between)
  end

  def any_piece_blocks_threat?(player, squares_in_between)
    player.pieces_on_board.any? do |piece|
      next if piece.is_a? King

      common_squares = piece.legal_moves & squares_in_between
      common_squares.any? { |square| !causes_check?(piece, square, player) }
    end
  end
end
