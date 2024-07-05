require_relative '../lib/chess_engine/chess_engine'

RSpec.describe Chess do           #
  subject(:engine) {described_class.new}
  describe '#add_game' do
    context 'when adding player to game' do
      it 'adds them to the game' do
        engine.add_player("John")
        white = engine.instance_variable_get('@white_player')
        engine.add_player("Doe")
        black = engine.instance_variable_get('@black_player')
        expect(white.name).to eq "John"
        expect(black.name).to eq "Doe"
      end
    end
    context 'when adding player to a full game' do
      it 'raises error' do
        engine.add_player("John")
        engine.add_player("Doe")
        expect{engine.add_player("Foo")}.to raise_error(ChessExceptionModule::GameIsFull)
      end
    end
  end
  describe '#start_game' do
    context 'when any of the player is missing' do
      it 'raises error' do
        expect{engine.start_game}.to raise_error(ChessExceptionModule::PlayerMissing)
        engine.add_player("John")
        expect{engine.start_game}.to raise_error(ChessExceptionModule::PlayerMissing)
      end
    end
    context 'when both players are present' do
      it 'initializes board and pieces controller and place starting pieces' do
        engine.add_player("John")
        engine.add_player("Doe")
        engine.start_game
        board = engine.instance_variable_get('@board')
        pieces_controller = engine.instance_variable_get('@piece_controller')
        expect(board.is_a?(Board)).to be true
        expect(pieces_controller.is_a?(PiecesController)).to be true
        expect(engine.game_state).to eq 'rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR'
      end
    end


  end
  describe '#make_move' do
  before do
    engine.add_player("John")
    engine.add_player("Doe")
    engine.start_game
  end
    context 'when move is "g2g4"' do
      it 'moves the piece' do
        engine.make_move('g2g4')
        expect(engine.game_state).to eq 'rnbqkbnr/pppppppp/8/8/6P1/8/PPPPPP1P/RNBQKBNR'
      end
    end
    context 'when move is "g2g5"' do
      it 'moves the piece' do
        expect{engine.make_move('g2g5')}.to raise_error IllegalMove
        expect(engine.game_state).to eq 'rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR'
      end
    end
  end
end
