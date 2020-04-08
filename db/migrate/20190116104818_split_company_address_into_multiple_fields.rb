class SplitCompanyAddressIntoMultipleFields < ActiveRecord::Migration[5.2]
  def change
    change_table :companies do |t|
      t.remove :address
      t.string :city
      t.string :postal_code
      t.string :street
    end
  end
end
