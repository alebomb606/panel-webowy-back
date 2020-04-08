class RemoveChannelUuidFromAuths < ActiveRecord::Migration[5.2]
  def change
    remove_column :auths, :channel_uuid, :string
  end
end
