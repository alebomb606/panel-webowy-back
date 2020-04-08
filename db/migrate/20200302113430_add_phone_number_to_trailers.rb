class AddPhoneNumberToTrailers < ActiveRecord::Migration[5.2]
  def change
    add_column :trailers, :phone_number, :string
  end
end
