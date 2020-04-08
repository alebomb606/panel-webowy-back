class MovePersonalDataFromLogisticianToPerson < ActiveRecord::Migration[5.2]
  def up
    remove_column :logisticians, :first_name, :string
    remove_column :logisticians, :last_name, :string
    remove_column :logisticians, :phone_number, :string
    remove_column :logisticians, :extra_phone_number, :string
    remove_reference :logisticians, :company
  end

  def down
    add_column :logisticians, :first_name, :string
    add_column :logisticians, :last_name, :string
    add_column :logisticians, :phone_number, :string
    add_column :logisticians, :extra_phone_number, :string
    add_reference :logisticians, :company, foreign_key: true
  end
end
