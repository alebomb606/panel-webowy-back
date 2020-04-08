class AddLinkedEventToTrailerEvents < ActiveRecord::Migration[5.2]
  def change
    add_reference :trailer_events, :linked_event, foreign_key: { to_table: :trailer_events }
    add_reference :trailer_events, :logistician, foreign_key: true
  end
end
