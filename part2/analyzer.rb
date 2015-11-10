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
