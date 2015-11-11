class Parser
  KEYWORDS = %w[awful bad boring dull effective enjoyable great hilarious]

  def initialize data_dir
    @data_dir = data_dir
  end

  # Returns a hash containing the sets of feature vectors for both the
  # positive and negative review directories
  def features
    result = Hash.new([])

    # Read boh polarity directories
    [:pos, :neg].each do |polarity|
      dir = File.join(@data_dir, polarity.to_s)
      feats = []

      # Read each file in the folder and compute the feature vector
      Dir.foreach(dir) do |file|
        next if [".", ".."].include? file

        contents = File.open(File.join(dir, file)).read.downcase
        feats << KEYWORDS.map { |w| contents.include? w }
      end
      result[polarity] = feats
    end
    result
  end
end
