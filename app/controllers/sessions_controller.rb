class SessionsController < Devise::SessionsController
  def create
    return super unless request.format.html?

    resource = Auth.find_by(email: params.dig(:auth, :email))

    if master_admin?(resource)
      set_flash_message!(:notice, :signed_in)
      sign_in(resource_name, resource)
      yield resource if block_given?
      respond_with resource, location: after_sign_in_path_for(resource)
    else
      throw(:warden)
    end
  end

  private

  def master_admin?(resource)
    resource&.valid_password?(params.dig(:auth, :password)) && resource&.master_admin?
  end
end
