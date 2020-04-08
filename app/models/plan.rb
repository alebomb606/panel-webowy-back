class Plan < ApplicationRecord
  include ::FlagShihTzu

  DEFAULT_DATA_TRANSFER_LIMIT = 5
  KINDS = { fundamental: 0, expanded: 1, complete: 2, premium: 3, custom: 4 }.freeze

  FUNDAMENTAL_FEATURES = %w[intelligent_sensors current_position event_log interior_camera telemetry].freeze
  FEATURE_SETS = [
    {
      features: %w[fuel_tanks_sensors back_camera rear_door_opening_sensor basic_loading_control],
      level: KINDS[:expanded]
    },
    {
      features: %w[bottom_left_camera bottom_right_camera advanced_loading_control],
      level: KINDS[:complete]
    },
    {
      features: %w[top_left_camera top_right_camera],
      level: KINDS[:premium]
    }
  ].freeze

  enum kind: KINDS

  belongs_to :trailer
  has_flags 1 => :intelligent_sensors,
            2 => :rear_door_opening_sensor,
            3 => :fuel_tanks_sensors,
            10 => :current_position,
            11 => :event_log,
            12 => :telemetry,
            13 => :basic_loading_control,
            14 => :advanced_loading_control,
            20 => :interior_camera,
            21 => :back_camera,
            22 => :top_left_camera,
            23 => :top_right_camera,
            24 => :bottom_right_camera,
            25 => :bottom_left_camera,
            column: 'features'

  def self.features_for(plan_type)
    return [] unless plan_type.in?(kinds.keys)

    plan_level = kinds[plan_type]
    features   = FUNDAMENTAL_FEATURES

    if plan_type != 'custom'
      FEATURE_SETS.each do |fs|
        features += fs[:features] if plan_level >= fs[:level]
      end
    end

    features
  end

  def self.kind_for(features)
    return 'custom' if features.empty?

    features = features.map(&:to_s).sort
    kinds.keys.each do |kind|
      return kind if features_for(kind).sort == features
    end

    'custom'
  end

  def features_for_select_box
    as_flag_collection('features').map do |feature, state|
      OpenStruct.new(
        value: feature.to_s,
        text: I18n.t("activerecord.attributes.plan.all_features.#{feature}"),
        state: state
      )
    end
  end
end
