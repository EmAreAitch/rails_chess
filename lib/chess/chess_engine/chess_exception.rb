module ChessExceptionModule
  class StandardChessException < StandardError
  end

  class GameIsFull < StandardChessException
    def initialize
      super("Game is full")
    end
  end

  class PlayerMissing < StandardChessException
    def initialize
      super("Game needs two players to start")
    end
  end

  class InvalidNotation < StandardChessException
    def initialize
      super("Move notation is not valid")
    end
  end

  class AlreadyStarted < StandardChessException
    def initialize
      super("Game has already started")
    end
  end
end
