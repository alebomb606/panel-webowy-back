class TrailerDataUsage::ParseReportWorker
  include Sidekiq::Worker
  sidekiq_options queue: 'critical'

  def perform(*)
    TRAILER_DATA_USAGE_LOGGER.info('Execute: scheduled parse trailer data usage report.')
    TrailerDataUsage::ParseReport.new.call
  end
end
