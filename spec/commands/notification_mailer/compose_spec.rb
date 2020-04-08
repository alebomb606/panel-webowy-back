require 'rails_helper'

RSpec.describe NotificationMailer::Compose do
  subject do
    described_class.new.call(params) do |m|
      m.success { |notification| notification }
      m.failure { |res| res }
    end
  end

  describe '#call' do
    context 'with invalid params' do
      let(:params) { { email_priority: 'wrong_priority' } }
      let(:errors) { subject[:errors] }

      it 'returns errors' do
        expect(errors).to include(:body, :email_priority, :event_date, :lang, :receiver_email, :subject, :user_company, :user_name)
        expect(errors[:email_priority]).to include(I18n.t('errors.included_in?.arg.default', list: ::EmailNotification::EMAIL_PRIORITIES.keys.join(', ')))
      end
    end

    context 'with valid params' do
      let(:params) {
        {
          body: Faker::Lorem.paragraph,
          email_priority: ['high', 'normal', 'low'].sample,
          event_date: Time.current,
          lang: 'en',
          receiver_email: Faker::Internet.unique.email,
          subject: Faker::Job.title,
          user_company: Faker::Company.name,
          user_name: Faker::Name.first_name
        }
      }

      it 'create notification' do
        expect { subject }.to change { EmailNotification.count }.by(1)
      end

      it 'sends email' do
        allow(::NotificationMailer).to receive(:notification_mail).and_call_original
      end
    end
  end
end
