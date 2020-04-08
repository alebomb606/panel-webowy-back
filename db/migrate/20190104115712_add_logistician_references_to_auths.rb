class AddLogisticianReferencesToAuths < ActiveRecord::Migration[5.2]
  def change
    add_reference :auths, :logistician, index: true
  end
end
