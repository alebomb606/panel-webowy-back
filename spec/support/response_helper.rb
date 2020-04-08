module ResponseHelper
  def parsed_response_body
    JSON.parse(response.body, symbolize_names: true)
  end
end
