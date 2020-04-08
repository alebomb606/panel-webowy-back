class AddPreferredLocaleToLogistician < ActiveRecord::Migration[5.2]
  def change
    add_column :logisticians, :preferred_locale, :integer, :default => 0, :null => false
  end
end
