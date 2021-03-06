require 'csv'
require_relative '../part1/distsampler'

class Sampler
  # max_iters - the maximum number of samples to generate
  # scale - scaling factor
  # goal - the variable assignments we're estimating the probability for
  def initialize max_iters, step, goal
    @max_iters = max_iters
    @step = step
    @goal = goal
  end

  # Perform both types of sampling on the BN with increasing sample sizes
  def run
    iters = 0
    results = { direct: [], rejection: [] }
    while iters <= @max_iters
      samples = []
      iters.times { samples << direct_sample }
      results[:direct] << [iters, approx_inference(samples)]
      results[:rejection] << [iters, rejection_sample(samples)]
      iters += @step
    end
    results
  end

  # Perform approximate inference on the samples:
  # Divide the number of samples that match the specified assignment by the
  # total number of samples.
  def approx_inference samples
    samples.count { |s| s == @goal } / samples.size.to_f
  end

  # Perform rejection sampling on the samples:
  # Divide the number of samples where flu is true, cough is true, and wheezing
  # is false by those where simply cough is true and wheezing is false.
  def rejection_sample samples
    num = samples.count { |s| s[0] && s[5] && !s[6] }
    denom = samples.count { |s| s[5] && !s[6] }
    num / denom.to_f
  end

  # Data must be a 2D array, where each line corresponds to a row in the CSV
  # This writes the data to the specified output file so it can be imported
  # by a spreadsheet program
  def write_csv filename, data
    ::CSV.open(filename, "wb") do |csv|
      data.each do |line|
        csv << line
      end
    end
  end

  def direct_sample
    fl = ::DistSampler.new({ true => 0.08, false => 0.92 }).sample
    sm = ::DistSampler.new({ true => 0.10, false => 0.90 }).sample
    st = ::DistSampler.new({
      true => fl ? 0.60 : 0.08,
      false => fl ? 0.40 : 0.92
    }).sample
    fe = ::DistSampler.new({
      true => fl ? 0.65 : 0.01,
      false => fl ? 0.35 : 0.99
    }).sample
    br = ::DistSampler.new({
      true => br_prob(fl, sm), false => (1 - br_prob(fl, sm))
    }).sample
    co = ::DistSampler.new({
      true => br ? 0.95 : 0.02,
      false => br ? 0.05 : 0.98
    }).sample
    wh = ::DistSampler.new({
      true => br ? 0.92 : 0.01,
      false => br ? 0.08 : 0.99
    }).sample

    [fl, st, fe, br, sm, co, wh]
  end

  private

  # Helper method that returns the conditional probabilities for Bronchitis to
  # avoid having to write them all out in the sampling method
  def br_prob fl, sm
    case [fl, sm]
    when [true, true]
      0.95
    when [true, false]
      0.65
    when [false, true]
      0.70
    when [false, false]
      0.001
    else
      raise "Invalid assignment of parameters"
    end
  end
end
