class CreateWarningNotifications < ActiveRecord::Migration[5.2]
  def change
    create_table :warning_notifications do |t|
      t.datetime   :sent_at
      t.integer    :kind
      t.string     :contact_information
      t.references :trailer_sensor_reading, foreign_key: true
    end
  end
end
