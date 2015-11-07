class Results
  # This class is used to store the results of running the Chutes and Ladders
  # game for the desired number of iterations.
  #
  # It provides mechanisms to easily analyze the data, such as finding the
  # average number of moves to complete the game, the standard deviation of the
  # data, and histrograms to see frequencies of each result.

  def initialize results
    @results = results
  end

  # Compute the average number of moves to complete the game
  def avg
    @results.reduce(:+).to_f / @results.size
  end

  # Compute the standard deviation of the results
  def std_dev
    mean = avg
    deviations = @results.map { |r| (r - mean) ** 2 }
    variance = deviations.reduce(:+) / deviations.size
    Math.sqrt(variance)
  end

  # Computes the frequencies of each result for the number of moves it took
  # to complete the game
  def histogram
    @results.reduce(Hash.new(0)) do |hash, result|
      hash[result] += 1
      hash
    end.sort
  end

  # Returns a string displaying the average, standard deviation, and histogram
  # This can be easily printed to be displayed in the terminal
  def to_s
    s = "# Iterations\t\tAverage\t\tStd. Dev.\n"
    s += "#{@results.size}\t\t\t#{avg}\t\t#{std_dev}\n\n"
    s += histogram.map { |k, v| k.to_s + "\t" + ("=" * v) }.join("\n")
  end
end
