#!/usr/bin/env ruby

require_relative 'parser'

def display_probs parser
  # Get the feature vectors and count for each
  neg = parser.features Parser::NEGATIVE
  pos = parser.features Parser::POSITIVE
  neg_count = neg.size.to_f
  pos_count = pos.size.to_f

  # Iterate over the feature words and display the corresponding probabilities
  Parser::KEYWORDS.each_with_index do |word, i|
    puts "P(#{word} | neg) = " + (neg.count { |f| f[i] } / neg_count).to_s
  end
  Parser::KEYWORDS.each_with_index do |word, i|
    puts "P(#{word} | pos) = " + (pos.count { |f| f[i] } / pos_count).to_s
  end
end

if __FILE__ == $0
  parser = Parser.new("./data/txt_sentoken")
  display_probs(parser)
end
