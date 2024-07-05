# frozen_string_literal: true

class ChessException < StandardError
end

class GameEnd < ChessException
end

class IllegalMove < ChessException
  def initialize(msg = 'Move is not possible')
    super(msg)
  end
end

class IllegalPiece < ChessException
  def initialize(msg = 'Move is not possible')
    super(msg)
  end
end

class Check < IllegalMove
  def initialize(msg = 'Player is in check')
    super(msg)
  end
end

class Checkmate < GameEnd
  def initialize
    super('Checkmate')
  end
end

class Stalemate < GameEnd
  def initialize
    super('Stalemate')
  end
end
