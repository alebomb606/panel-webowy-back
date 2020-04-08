class AddMasterAdminToAuths < ActiveRecord::Migration[5.2]
  def change
    add_reference :auths, :master_admin, index: true
  end
end
