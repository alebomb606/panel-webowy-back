class CreatePeople < ActiveRecord::Migration[5.2]
  def change
    create_table :people do |t|
      t.references :personifiable, polymorphic: true
      t.string :first_name
      t.string :last_name
      t.string :phone_number
      t.string :extra_phone_number
      t.string :email
      t.belongs_to :company, foreign_key: true

      t.timestamps
    end
  end
end
