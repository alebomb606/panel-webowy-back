ApiPagination.configure do |config|
  config.paginator = :kaminari
  config.total_header = 'X-Total'
  config.per_page_header = 'X-Per-Page'
  config.page_header = 'X-Page'
  config.response_formats = %i[jsonapi]

  config.page_param do |params|
    if params[:page].is_a? ActionController::Parameters
      params[:page][:number]
    else
      params[:page]
    end
  end

  config.per_page_param do |params|
    if params[:page].is_a? ActionController::Parameters
      params[:page][:size]
    else
      params[:per_page]
    end
  end
end
