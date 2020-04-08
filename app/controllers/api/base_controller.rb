class Api::BaseController < ActionController::Base
  include ::DeviseTokenAuth::Concerns::SetUserByToken
  include ::Rails::Pagination
  include ::Api::LinkHelper

  rescue_from JSONAPI::Parser::InvalidDocument, with: :invalid_document_error

  skip_before_action :verify_authenticity_token
  before_action :set_locale
  before_action :authenticate_auth!
  before_action :set_headers
  before_action :check_content_header
  before_action :check_accept_header

  private

  def set_locale
    return if request.env['HTTP_ACCEPT_LANGUAGE'].nil?

    logger.debug "* Accept-Language: #{request.env['HTTP_ACCEPT_LANGUAGE']}"
    I18n.locale = extract_locale_from_accept_language_header
  rescue I18n::InvalidLocale
    logger.debug "* Locale #{extract_locale_from_accept_language_header} not supported."
    logger.debug "* Falling back to #{I18n.default_locale}."
    I18n.locale = I18n.default_locale
  ensure
    logger.debug "* Locale set to '#{I18n.locale}'"
  end

  def extract_locale_from_accept_language_header
    request.env['HTTP_ACCEPT_LANGUAGE'].scan(/^[a-z]{2}/).first.to_sym
  end

  def set_headers
    response.headers['Content-Type'] = 'application/vnd.api+json'
  end

  def check_content_header
    head :unsupported_media_type if
      request.headers['Content-Type'] != 'application/vnd.api+json' && !request.get?
  end

  def check_accept_header
    head :not_acceptable if
      request.headers['Accept'] != 'application/vnd.api+json'
  end

  def invalid_document_error(exception)
    render json: { errors: [{ detail: exception.message }] }, status: :bad_request
  end
end
