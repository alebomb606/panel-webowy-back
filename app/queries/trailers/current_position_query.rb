class Trailers::CurrentPositionQuery
  def self.call(trailer)
    trailer.route_logs.order(sent_at: :desc).first
  end
end
