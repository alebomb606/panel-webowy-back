require 'rails_helper'

RSpec.describe TrailerCamera, type: :model do
  describe 'attributes' do
    it { expect(subject.attributes.keys).to match_array [
      'id',
      'trailer_id',
      'camera_type',
      'installed_at',
      'updated_at'
      ] }
  end
end
