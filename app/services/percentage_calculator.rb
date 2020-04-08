class PercentageCalculator
  def self.call(value, max_value)
    ((value / max_value) * 100.0).round(2)
  end
end
