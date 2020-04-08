class Overrides::SessionsController < DeviseTokenAuth::SessionsController
  def render_create_success
    render json: ::AuthSerializer.new(@resource, include: %i[logistician logistician.trailer_access_permissions])
  end

  def render_destroy_error
    render json: ::ErrorSerializer.not_found('Auth'), status: :not_found
  end

  def render_create_error_bad_credentials
    render json: ::ErrorSerializer.bad_credentials, status: :unauthorized
  end

  def render_destroy_success
    head :ok
  end
end
