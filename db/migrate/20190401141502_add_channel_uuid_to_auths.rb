class AddChannelUuidToAuths < ActiveRecord::Migration[5.2]
  def change
    add_column :auths, :channel_uuid, :string
  end
end
