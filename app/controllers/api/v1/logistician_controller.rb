class Api::V1::LogisticianController < Api::BaseController
  deserializable_resource :logistician, only: %i[update update_password]

  def update
    update = ::Api::V1::Logistician::UpdateProfile.new
    update.call(update_params) do |m|
      m.success do |logistician|
        bypass_sign_in(logistician.auth)
        render json: ::LogisticianSerializer.new(logistician, include: %i[person])
      end

      m.failure do |result|
        render json: ::ErrorSerializer.wrap(result[:errors]), status: :unprocessable_entity
      end
    end
  end

  def update_password
    update_password = ::Api::V1::Logistician::UpdatePassword.new
    update_password.call(update_password_params) do |m|
      m.success do |logistician|
        bypass_sign_in(logistician.auth)
        render json: ::LogisticianSerializer.new(logistician)
      end

      m.failure do |result|
        render json: ::ErrorSerializer.wrap(result[:errors]), status: :unprocessable_entity
      end
    end
  end

  def show
    render json: ::LogisticianSerializer.new(current_auth.logistician, include: %i[trailer_access_permissions person])
  end

  private

  def update_params
    params
      .require(:logistician)
      .permit(:first_name, :last_name, :email, :phone_number, :extra_phone_number, :password, :preferred_locale)
      .merge(auth: current_auth)
  end

  def update_password_params
    params
      .require(:logistician)
      .permit(:password, :password_confirmation, :current_password)
      .merge(auth: current_auth)
  end
end
