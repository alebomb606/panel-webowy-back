class InteractionSerializer < ApplicationSerializer
  attributes :kind

  attribute :triggered_at do |obj|
    obj.triggered_at&.iso8601
  end

  belongs_to :trailer
  belongs_to :logistician
  belongs_to :linked_event,
    record_type: :trailer_event,
    id_method_name: :linked_event_id,
    serializer: ::TrailerEventSerializer
end
