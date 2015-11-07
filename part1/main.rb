#!/usr/bin/env ruby

require_relative 'runner'

if __FILE__ == $0
  results = Runner.new(1000).run
  puts results.to_s
end
