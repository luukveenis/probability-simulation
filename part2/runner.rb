#!/usr/bin/env ruby

require_relative 'parser'
require_relative 'analyzer'

def display_probs analyzer
  # Get and display the conditional probabilities for each polarity
  [:pos, :neg].each do |p|
    probs = analyzer.cond_probs(p)
    puts "P(Xi | #{p.to_s}) = [#{probs.join(" ")}]"
  end
end

if __FILE__ == $0
  parser = Parser.new("./data/txt_sentoken")
  analyzer = Analyzer.new(parser.features)
  display_probs(analyzer)
end
