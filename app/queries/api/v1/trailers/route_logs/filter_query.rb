class Api::V1::Trailers::RouteLogs::FilterQuery < AppCommand
  include Dry::Monads::Do.for(:call)
  include Dry::Matcher.for(:call, with: Matcher)

  Schema = Dry::Validation.Params(::AppSchema) do
    required(:trailer_id).filled(:int?)
    required(:auth).filled

    optional(:filter).schema do
      optional(:date_from).filled(:date_time?)
      optional(:date_to).filled(:date_time?)

      rule(from_before_to?: %i[date_from date_to]) do |date_from, date_to|
        date_from.filled? & date_to.filled? > date_from.lteq?(date_to)
      end
    end
  end

  def call(params)
    attributes = yield validate(params.to_h)
    permission = yield find_permission(attributes)
    trailer    = yield verify_trailer_permission(permission)
    filter     = attributes[:filter] || {}
    Success(filtered_logs(trailer, filter))
  end

  private

  def validate(params)
    validation = Schema.call(params)
    return Failure(errors: validation.errors) if validation.failure?

    Success(validation.output)
  end

  def verify_trailer_permission(permission)
    return Failure(what: :no_permission) unless permission.route_access?

    Success(permission.trailer)
  end

  def find_permission(attributes)
    ::Api::V1::Trailers::AccessPermissions::FetchQuery.new.call(
      attributes[:auth],
      attributes[:trailer_id]
    )
  end

  REF_POINTS = 20_000

  def direct_sql(trailer, filter)
    index = trailer.route_logs.where(sent_at: date_range(filter)).count

    <<-SQL.strip_heredoc
          SELECT * FROM
            (SELECT *, row_number() OVER (ORDER BY sent_at DESC)
            FROM route_logs
            WHERE trailer_id = #{trailer.id}
              AND latitude != 0 AND longitude != 0
              AND sent_at BETWEEN timestamptz '#{date_range(filter).first}'
                  AND timestamptz '#{date_range(filter).last}') RAW_LOGS
         WHERE (RAW_LOGS.row_number - 1) % (#{index} / #{REF_POINTS} + 1) = 0;
    SQL
  end

  def filtered_logs(trailer, filter)
    raw_logs = trailer.route_logs.find_by_sql(direct_sql(trailer, filter))

    if raw_logs.length > 5000
      previouspoints = [raw_logs[0], raw_logs[1]]
      miss = 0
      processed_log = []

      raw_logs.each do |point|
        dx1 = previouspoints[0].latitude - previouspoints[1].latitude
        dy1 = previouspoints[0].longitude - previouspoints[1].longitude
        dx2 = previouspoints[1].latitude - point.latitude
        dy2 = previouspoints[1].longitude - point.longitude

        angle1 = Math.atan(dx1 / dy1)
        angle2 = Math.atan(dx2 / dy2)

        if ((angle1 - angle2).abs > 0.04) || miss > 10
          previouspoints[0] = previouspoints[1]
          previouspoints[1] = point
          processed_log.push point
          miss = 0
        else miss += 1
        end
      end
      processed_log
    else
      raw_logs
    end
  end

  def date_range(filter)
    from = filter[:date_from] || 7.days.ago
    to   = filter[:date_to]   || Time.current

    from..to
  end
end
