class AddLocationNameAndRelationsToRouteLogs < ActiveRecord::Migration[5.2]
  def change
    change_table :route_logs do |t|
      t.string :location_name
      t.string :locale
      t.references :trailer_event
      t.references :trailer_media_file
    end
  end
end
