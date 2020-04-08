class CreateMasterAdmins < ActiveRecord::Migration[5.2]
  def change
    create_table :master_admins do |t|
      t.string :first_name
      t.string :last_name
      t.string :phone_number
    end
  end
end
