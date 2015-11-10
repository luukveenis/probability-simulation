#!/usr/bin/env ruby

require_relative 'parser'
require_relative 'analyzer'

def display_results analyzer
  # Get and display the conditional probabilities for each polarity
  [:pos, :neg].each do |p|
    probs = analyzer.cond_probs(p)
    puts "P(Xi | #{p.to_s}) = [#{probs.join(" ")}]"
  end
  result = analyzer.accuracy(analyzer.classify)
  puts "\nClassifier accuracy: " + result[:accuracy].to_s
  puts "\nConfusion matrix:"
  result[:confusion].each do |r|
    puts r.join("\t")
  end
end

if __FILE__ == $0
  parser = Parser.new("./data/txt_sentoken")
  analyzer = Analyzer.new(parser.features)
  display_results(analyzer)
end
