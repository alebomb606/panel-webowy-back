FactoryBot.define do
  factory :trailer_camera do
    camera_type { ::TrailerCamera.camera_types.keys.sample }
  end
end
