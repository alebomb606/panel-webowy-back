class Auth::EntityBroadcaster
  def initialize(entities:, auth:, serializer:, options: {})
    @entities    = entities.is_a?(Array) ? entities : [entities]
    @auth        = auth
    @serializer  = serializer
    @options     = options.merge(is_collection: true).merge(params: { auth: auth })
  end

  def call
    return if @entities.empty?

    ActionCable.server.broadcast("auths_#{@auth.id}", serialized_entities)
  end

  private

  def serialized_entities
    @serializer.new(@entities, @options)
  end
end
