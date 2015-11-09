class Parser
  POSITIVE = :positive
  NEGATIVE = :negative
  KEYWORDS = %w[awful bad boring dull effective enjoyable great hilarious]

  def initialize data_dir
    @data_dir = data_dir
  end

  # Returns the set of feature vectors corresponding to the directory with
  # reviews for the desired polarity
  def features polarity
    # Check for invalid input
    raise "Invalid polarity" unless [POSITIVE, NEGATIVE].include? polarity

    # Figure out which folder to search
    features = []
    dir = polarity == POSITIVE ? "pos" : "neg"
    dir = File.join(@data_dir, dir)

    # Read each file in the folder and compute the feature vector
    Dir.foreach(dir) do |file|
      next if [".", ".."].include? file

      contents = File.open(File.join(dir, file)).read.downcase
      features << KEYWORDS.map { |w| contents.include? w }
    end
    features
  end
end
