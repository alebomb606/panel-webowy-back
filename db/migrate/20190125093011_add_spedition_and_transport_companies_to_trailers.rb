class AddSpeditionAndTransportCompaniesToTrailers < ActiveRecord::Migration[5.2]
  def change
    add_column :trailers, :spedition_company, :string
    add_column :trailers, :transport_company, :string
  end
end
