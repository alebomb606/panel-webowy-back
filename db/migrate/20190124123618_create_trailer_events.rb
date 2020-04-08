class CreateTrailerEvents < ActiveRecord::Migration[5.2]
  def change
    create_table :trailer_events do |t|
      t.integer :kind
      t.string :triggered_by
      t.datetime :triggered_at
      t.string :uuid
      t.references :trailer
    end

    add_index :trailer_events, :uuid
  end
end
