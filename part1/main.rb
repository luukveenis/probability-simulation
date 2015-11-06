#!/usr/bin/env ruby

require_relative 'runner'

if __FILE__ == $0
  results = Runner.new(100).run
  histo = results.inject(Hash.new(0)) { |hash, result| hash[result] += 1; hash }
  histo.sort.each do |k, v|
    puts k.to_s + "\t" + ("=" * v)
  end
end
