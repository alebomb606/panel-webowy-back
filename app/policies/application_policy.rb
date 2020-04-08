class ApplicationPolicy
  def self.permitted?(*args)
    return call(*args) if singleton_methods.include?(:call)

    new(*args).call
  end
end
