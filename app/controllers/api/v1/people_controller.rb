class Api::V1::PeopleController < Api::BaseController
  def index
    query = ::Api::V1::People::FilterQuery.new
    query.call(filter_params) do |m|
      m.success do |result|
        paginated = paginate(result)
        render json: ::PersonSerializer.new(paginated)
      end

      m.failure do |result|
        render json: ::ErrorSerializer.wrap(result[:errors]), status: :unprocessable_entity
      end
    end
  end

  private

  def filter_params
    params.permit(filter: %i[keyword]).merge(auth: current_auth)
  end
end
