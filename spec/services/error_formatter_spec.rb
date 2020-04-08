require 'rails_helper'

RSpec.describe ErrorFormatter do
  subject { described_class.new(errors, options).call }

  describe '#call' do
    let(:errors) {
      {
        model_attributes: {
          email: ["is missing", "is not unique"],
          nip: ["is missing", "is not valid"],

          nested_model_attributes_1: {
            first_name: ["is missing", "includes invalid characters"],
            last_name: ["is missing"],

            nested_model_attributes_2: {
              phone_number: "is missing",
              postal_code: ["is missing"],
            }
          },

          longitude: ["is missing", "has wrong format"],
          filter: {
            names: {
              0=> [
                "is missing"
              ],
              1=>[
                "includes invalid characters",
                "has wrong format"
              ]
            }
          }
        },
        latitude: "is missing"
      }
    }

    let(:options) { { error_per_key: false } }

    context 'with multiple-level deep nested errors' do
      it 'returns formatted errors' do
        expect(subject).to match_array(
          [
            { message: "is missing", attribute: :email, formatted_attribute: I18n.t('errors.attributes.email') },
            { message: "is not unique", attribute: :email, formatted_attribute: I18n.t('errors.attributes.email') },
            { message: "is missing", attribute: :nip, formatted_attribute: I18n.t('errors.attributes.nip') },
            { message: "is not valid", attribute: :nip, formatted_attribute: I18n.t('errors.attributes.nip') },
            { message: "is missing", attribute: :first_name, formatted_attribute: I18n.t('errors.attributes.first_name') },
            { message: "includes invalid characters", attribute: :first_name, formatted_attribute: I18n.t('errors.attributes.first_name') },
            { message: "is missing", attribute: :last_name, formatted_attribute: I18n.t('errors.attributes.last_name') },
            { message: "is missing", attribute: :phone_number, formatted_attribute: I18n.t('errors.attributes.phone_number') },
            { message: "is missing", attribute: :postal_code, formatted_attribute: I18n.t('errors.attributes.postal_code') },
            { message: "is missing", attribute: :longitude, formatted_attribute: I18n.t('errors.attributes.longitude') },
            { message: "has wrong format", attribute: :longitude, formatted_attribute: I18n.t('errors.attributes.longitude') },
            # { message: "is missing", attribute: :speed, formatted_attribute: I18n.t('errors.attributes.speed') },
            # { message: "has wrong format", attribute: :speed, formatted_attribute: I18n.t('errors.attributes.speed') },
            { message: "is missing", attribute: :latitude, formatted_attribute: I18n.t('errors.attributes.latitude') },
            { message: "is missing", attribute: "names.0", formatted_attribute: 'Names.0' },
            { message: "includes invalid characters", attribute: "names.1", formatted_attribute: 'Names.1' },
            { message: "has wrong format", attribute: "names.1", formatted_attribute: 'Names.1' }
         ]
        )
      end
    end

    context 'with single error per key' do
      let(:options) { { error_per_key: true } }

      it 'returns formatted errors' do
        expect(subject).to match_array(
          [
            { message: "is missing", attribute: :email, formatted_attribute: I18n.t('errors.attributes.email') },
            { message: "is missing", attribute: :nip, formatted_attribute: I18n.t('errors.attributes.nip') },
            { message: "is missing", attribute: :first_name, formatted_attribute: I18n.t('errors.attributes.first_name') },
            { message: "is missing", attribute: :last_name, formatted_attribute: I18n.t('errors.attributes.last_name') },
            { message: "is missing", attribute: :phone_number, formatted_attribute: I18n.t('errors.attributes.phone_number') },
            { message: "is missing", attribute: :postal_code, formatted_attribute: I18n.t('errors.attributes.postal_code') },
            { message: "is missing", attribute: :longitude, formatted_attribute: I18n.t('errors.attributes.longitude') },
            { message: "is missing", attribute: :latitude, formatted_attribute: I18n.t('errors.attributes.latitude') },
            # { message: "is missing", attribute: :speed, formatted_attribute: I18n.t('errors.attributes.speed') },
            { message: "is missing", attribute: "names.0", formatted_attribute: 'Names.0' },
            { message: "includes invalid characters", attribute: "names.1", formatted_attribute: 'Names.1' }
          ]
        )
      end
    end
  end
end
