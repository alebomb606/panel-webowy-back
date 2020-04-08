class Api::V1::SensorSettingsController < Api::BaseController
  deserializable_resource :sensor_setting, only: :update

  def update
    apply = ::Api::V1::TrailerSensorSetting::Apply.new
    apply.call(apply_params) do |m|
      m.success do |setting|
        render json: ::TrailerSensorSettingSerializer.new(setting, include: %i[sensor])
      end

      m.failure(:no_permission) do
        head :forbidden
      end

      m.failure(:trailer_not_found) do
        head :forbidden
      end

      m.failure(:setting_not_found) do
        render json: ::ErrorSerializer.not_found('TrailerSensorSetting'), status: :not_found
      end

      m.failure do |result|
        render json: ::ErrorSerializer.wrap(result[:errors]), status: :unprocessable_entity
      end
    end
  end

  private

  def apply_params
    params
      .require(:sensor_setting)
      .permit(
        :id,
        :alarm_primary_value, :alarm_secondary_value,
        :warning_primary_value, :warning_secondary_value,
        :send_email, :send_sms,
        email_addresses: [], phone_numbers: []
      ).merge(auth: current_auth)
  end
end
