class CreateLogisticians < ActiveRecord::Migration[5.2]
  def change
    create_table :logisticians do |t|
      t.string :first_name
      t.string :last_name
      t.string :phone_number
      t.belongs_to :company, foreign_key: true

      t.timestamps
    end
  end
end
