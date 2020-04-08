module RequestHelper
  def set_jsonapi_headers
    request.headers.merge!(
      'Content-Type' => 'application/vnd.api+json',
      'Accept'       => 'application/vnd.api+json'
    )
  end

  def set_auth_headers(auth)
    sign_in(auth)
    request.headers.merge!(auth.create_new_auth_token)
  end
end
