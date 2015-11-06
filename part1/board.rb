require_relative 'distsampler'

class Board
  # This version of Chutes and Ladders doesn't assume anything about the state
  # of the board. It takes 3 parameters that specify the current board:
  #
  # Squares - The total number of squares on the board
  # Chutes - List of pairs indicating start and end positions of chutes
  # Ladders - List of pairs indicating start and end positions of ladders
  attr_reader :game_over, :moves

  def initialize squares, chutes, ladders
    @squares = squares
    @chutes = chutes
    @ladders = ladders
    @player_position = 1
    @game_over = false
    @moves = 0
    @sampler = DistSampler.new(die_distribution)
  end

  # Roll the die and advance the player position
  def make_move
    roll = @sampler.sample
    @player_position = new_position(roll)
    @moves += 1

    # Update winning state if the player has finished the game
    @game_over = @player_position >= @squares
  end

  # Compute the player's new position given the current roll, taking into
  # account the locations of chutes and ladders
  def new_position roll
    new_pos = @player_position + roll

    # Find out if a chute or ladder starts in the current space
    chute = @chutes.find { |c| c[0] == new_pos }
    ladder = @ladders.find { |l| l[0] == new_pos }

    # Move along the chute/ladder if one exists in the current space
    new_pos = chute[1] unless chute.nil?
    new_pos = ladder[1] unless ladder.nil?

    new_pos
  end

  private

  # Returns the discrete distribution representing a die roll
  def die_distribution
    (1..6).each_with_object(Hash.new(0)) { |i, hash| hash[i] = 1 / 6.0 }
  end
end
