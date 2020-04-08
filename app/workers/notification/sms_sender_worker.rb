class Notification::SmsSenderWorker
  include Sidekiq::Worker

  def perform(to, body)
    ::Notification::SmsSender.new.call(to: to, body: body)
  end
end
