class MasterAdmins::BaseController < ApplicationController
  layout 'master_admin'

  before_action :authenticate_auth!
  before_action :authenticate_admin

  include ::ErrorHelper

  private

  def authenticate_admin
    return render json: { error: 'Access denied' } unless current_auth.master_admin_id?
  end
end
