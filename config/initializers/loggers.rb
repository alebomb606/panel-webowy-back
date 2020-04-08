UPLOAD_LOGGER ||= Logger.new(Rails.root.join('log', 'media_upload.log'))
BANANA_LOGGER ||= Logger.new(Rails.root.join('log', 'banana.log'))
TRAILER_DATA_USAGE_LOGGER ||= Logger.new(Rails.root.join('log', 'trailer_data_usage.log'))
MEDIA_CONTINUOUS_REQUEST_LOGGER ||= Logger.new(Rails.root.join('log', 'media_continuous_request_logger.log'))
