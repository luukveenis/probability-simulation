#!/usr/bin/env ruby

require_relative 'sampler'

GOAL = [true, true, true, false, false, true, false]

if __FILE__ == $0
  sampler = Sampler.new(100000, 5000, GOAL)
  sampler.write_csv("output.csv", sampler.direct_sampling)
end
