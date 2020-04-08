class RangePercentageCalculator
  def self.call(value, range)
    (((value - range.min) * 100.0) / (range.max - range.min)).round(2)
  end
end
