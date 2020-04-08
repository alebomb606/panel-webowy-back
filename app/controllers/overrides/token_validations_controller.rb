class Overrides::TokenValidationsController < DeviseTokenAuth::TokenValidationsController
  def render_validate_token_error
    render json: ::ErrorSerializer.unauthorized, status: :unauthorized
  end
end
