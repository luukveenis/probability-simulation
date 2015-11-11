require_relative 'parser'
require_relative '../part1/distsampler'

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

  # Generate random reviews consisting only of the keywords provided by using
  # the computed probabilities to generate new feature vectors
  def generate_reviews
    pos_probs = cond_probs(:pos)
    neg_probs = cond_probs(:neg)
    reviews = { pos: [], neg: [] }

    5.times do
      reviews[:pos] << generate_feature_vector(pos_probs)
      reviews[:neg] << generate_feature_vector(neg_probs)
    end
    reviews[:pos].map! { |f| convert(f) }
    reviews[:neg].map! { |f| convert(f) }
    reviews
  end

  # Converts a feature vector into a readable "review" by transforming each
  # entry into the corresponding keyword it represents
  def convert feature
    Parser::KEYWORDS.each_with_index.map do |keyword, i|
      feature[i] ? keyword : nil
    end.compact.join(" ")
  end

  # Generate a random feature vector using the provided probabilities
  def generate_feature_vector probs
    (0..7).map do |i|
      ::DistSampler.new({ true => probs[i], false => (1 - probs[i]) }).sample
    end
  end

  # Add class labels using the Naive Bayes classifier method, using the entire
  # data set as test data
  def classify
    pos_probs = cond_probs(:pos)
    neg_probs = cond_probs(:neg)

    # Label the reviews in each polarity folder
    pos_labels = @features[:pos].map { |f| label(f, pos_probs, neg_probs) }
    neg_labels = @features[:neg].map { |f| label(f, pos_probs, neg_probs) }

    { pos_labels: pos_labels, neg_labels: neg_labels }
  end

  # Perform cross-fold validation as described in the README bundled with the
  # data used for this analysis
  def cross_fold_validation
    result = { pos_labels: [], neg_labels: [] }
    (0..9).each do |i|
      # Get the test data
      pos_test = @features[:pos].slice(i*100, 100)
      neg_test = @features[:neg].slice(i*100, 100)

      # Get the training data
      pos_training = @features[:pos].take(i*100) + @features[:pos].drop(i*100 + 100)
      neg_training = @features[:neg].take(i*100) + @features[:neg].drop(i*100 + 100)

      # Compute the conditional probabilities
      pos_probs = (0..7).map { |j| pos_training.count { |f| f[j] } / pos_training.count.to_f }
      neg_probs = (0..7).map { |j| neg_training.count { |f| f[j] } / neg_training.count.to_f }

      # Label the test data
      result[:pos_labels] += pos_test.map { |f| label(f, pos_probs, neg_probs) }
      result[:neg_labels] += neg_test.map { |f| label(f, pos_probs, neg_probs) }
    end
    result
  end

  # Compute the accuracy of the given labeling with respect to the known
  # classification of the reviews
  def accuracy labels
    pos_size = labels[:pos_labels].size
    neg_size = labels[:neg_labels].size
    pos_count = labels[:pos_labels].count { |l| l == :pos }
    neg_count = labels[:neg_labels].count { |l| l == :neg }

    # Compute the accuracies of the labeling
    pos_accuracy = pos_count / pos_size.to_f
    neg_accuracy = neg_count / neg_size.to_f
    accuracy = (pos_count + neg_count) / (pos_size + neg_size).to_f

    # Return a hash containing the results:
    # - the overall classification accuracy
    # - the confusion matrix for the results
    {
      accuracy: accuracy,
      confusion: [[pos_accuracy, (1 - pos_accuracy)],
                  [(1 - neg_accuracy), neg_accuracy]]
    }
  end

  # Compute the class-conditional probability given the probabilities for
  # each polarity and return the class label for the more likely case
  def label vector, pos_probs, neg_probs
    pos = vector.zip(pos_probs).reduce(1) do |acc, pair|
      pair[0] ? acc * pair[1] : acc * (1 - pair[1])
    end
    neg = vector.zip(neg_probs).reduce(1) do |acc, pair|
      pair[0] ? acc * pair[1] : acc * (1 - pair[1])
    end
    pos >= neg ? :pos : :neg
  end
end
