class DistSampler
  # Used to generate random samples from any discrete distribution
  #
  # distribution is a hash where the keys are the values the random variable
  # takes on and the values are the corresponding probabilities
  def initialize distribution
    @distribution = distribution
  end

  # Returns a random sample using the cumulative distribution
  def sample
    rand = Random.rand
    prob_sum = 0

    @distribution.each do |key, value|
      prob_sum += value
      return key if rand <= prob_sum
    end
  end
end
