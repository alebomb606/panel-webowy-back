class ApplicationPresenter < SimpleDelegator
  def self.wrap(collection)
    collection.map do |element|
      new element
    end
  end
end
