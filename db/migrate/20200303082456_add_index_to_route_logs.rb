class AddIndexToRouteLogs < ActiveRecord::Migration[5.2]
  def change
    add_index :route_logs, :sent_at, order: {sent_at: :desc}
  end
end
