class AddHqtimezoneToCompanies < ActiveRecord::Migration[5.2]
  def change
    add_column :companies, :tz, :integer
  end
end
