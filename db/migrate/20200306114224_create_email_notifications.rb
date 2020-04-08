class CreateEmailNotifications < ActiveRecord::Migration[5.1]
  def change
    create_table :email_notifications do |t|

      t.string :lang
      t.string :receiver_email
      t.integer :email_priority

      t.string :user_name
      t.string :user_company
      t.string :subject
      t.text :body
      t.datetime :event_date

      t.timestamps
    end
  end
end
