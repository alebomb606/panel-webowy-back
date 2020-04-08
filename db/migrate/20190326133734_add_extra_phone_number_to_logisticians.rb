class AddExtraPhoneNumberToLogisticians < ActiveRecord::Migration[5.2]
  def change
    add_column :logisticians, :extra_phone_number, :string
  end
end
