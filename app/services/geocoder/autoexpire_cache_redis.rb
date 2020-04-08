class Geocoder::AutoexpireCacheRedis
  def initialize(store, ttl = 86_400)
    @store = store
    @ttl = ttl
  end

  def [](url)
    @store.get(url)
  end

  def []=(url, value)
    @store.set(url, value)
    @store.expire(url, @ttl)
  end

  def keys
    @store.keys
  end

  def del(url)
    @store.del(url)
  end
end
