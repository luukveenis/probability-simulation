require_relative 'board'
require_relative 'results'

class Runner
  attr_reader :results

  CHUTES = [[16, 6], [48, 26], [49, 11], [56, 53], [62, 19],
            [64, 60], [87, 24], [93, 73], [95, 75], [98, 78]]
  LADDERS = [[1,38], [4, 14], [9, 31], [21, 42], [28, 84],
             [36, 44], [51, 67], [71, 91], [80, 100]]
  SQUARES = 100

  def initialize runs
    @runs = runs
  end

  # Run the game for 'runs' number of iterations
  def run
    results = []
    @runs.times do
      board = Board.new(SQUARES, CHUTES, LADDERS)

      # Play the game until the goal is reached
      until board.game_over
        board.make_move
      end

      # Store the number of moves it took to finish the game for each run
      results << board.moves
    end
    Results.new(results)
  end
end
