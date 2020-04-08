class CreatePlans < ActiveRecord::Migration[5.2]
  def change
    create_table :plans do |t|
      t.integer :kind, default: 0
      t.integer :features, null: false, default: 0

      t.timestamps
    end

    add_reference :plans, :trailer, foreign_key: true
  end
end
