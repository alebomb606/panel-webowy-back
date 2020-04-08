require 'rails_helper'

RSpec.describe RouteLog, type: :model do
  describe 'attributes' do
    it 'has proper attributes' do
      expect(subject.attributes).to include 'sent_at', 'longitude', 'latitude', 'created_at', 'updated_at', 'speed', 'timestamp'
    end
  end
end
