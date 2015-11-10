require_relative 'parser'

class Analyzer
  def initialize features
    @features = features
  end

  # Returns an array containing the conditional probabilities for each
  # keyword, given the review polarity
  def cond_probs polarity
    raise "Invalid polarity" unless [:pos, :neg].include? polarity

    # Divide the number of reviews each word occurs in by the total number of
    # reviews for that polarity
    count = @features[polarity].count.to_f
    (0..7).map { |i| @features[polarity].count { |f| f[i] } / count }
  end
end
