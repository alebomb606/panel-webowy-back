class AddTokensToTrailers < ActiveRecord::Migration[5.2]
  def change
    add_column :trailers, :banana_pi_token, :string
    add_column :trailers, :channel_uuid, :string
  end
end
