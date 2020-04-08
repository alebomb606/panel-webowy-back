class DeviseTokenAuthCreateAuths < ActiveRecord::Migration[5.2]
  def change
    add_column :auths, :provider, :string, null: false, default: 'email'
    add_column :auths, :uid, :string, null: false, default: ''
    add_column :auths, :tokens, :json
    add_index :auths, [:uid, :provider], unique: true
  end
end
