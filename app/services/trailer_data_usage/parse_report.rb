class TrailerDataUsage::ParseReport
  def initialize
    @report = fetch_report
  end

  def call
    return unless @report
    return unless current_report?

    parse_report unless already_sync?
  end

  private

  def fetch_report
    report = File.read(Rails.application.secrets.data_usage_report_path)
    JSON.parse(report)
  rescue Errno::ENOENT, JSON::ParserError => e
    TRAILER_DATA_USAGE_LOGGER.error("Error when parsing. Type: #{e.class}")
    nil
  end

  def current_report?
    @report['date'] == Time.current.strftime('%Y-%m-%d')
  end

  def already_sync?
    TrailerDataUsageSync.first.last_sync_at.strftime('%Y-%m-%d') == Time.current.strftime('%Y-%m-%d')
  end

  def parse_report
    counter = 0
    @report['entries'].each do |entry|
      trailer = ::Trailer.find_by(phone_number: "+#{entry.first}")
      next unless trailer

      counter += 1
      trailer.update(data_usage: build_data_usage_hash(entry.second))
    end
    update_last_sync_info(counter)
  end

  def build_data_usage_hash(entry)
    { rest_percent: entry['rest_percent'], rest_percentUE: entry['rest_percentUE'], updated_at: @report['date'] }
  end

  def update_last_sync_info(counter)
    TRAILER_DATA_USAGE_LOGGER.info("Report was parsed (#{@report['date']}, updated records: #{counter}).")
    TrailerDataUsageSync.first.update(last_sync_at: Time.current, updated_trailers: counter)
  end
end
