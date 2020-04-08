class AddArchivedAtToCompanies < ActiveRecord::Migration[5.2]
  def change
    change_table :companies do |t|
      t.datetime :archived_at, default: nil
    end
  end
end
