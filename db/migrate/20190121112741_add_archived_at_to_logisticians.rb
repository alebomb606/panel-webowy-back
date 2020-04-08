class AddArchivedAtToLogisticians < ActiveRecord::Migration[5.2]
  def change
    change_table :logisticians do |t|
      t.datetime :archived_at, default: nil
    end
  end
end
