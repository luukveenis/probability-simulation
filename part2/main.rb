#!/usr/bin/env ruby

require_relative 'sampler'

GOAL = [true, true, true, false, false, true, false]

if __FILE__ == $0
  sampler = Sampler.new(100000, 5000, GOAL)
  results = sampler.run
  sampler.write_csv("direct_sampling.csv", results[:direct])
  sampler.write_csv("rejection_sampling.csv", results[:rejection])
end
