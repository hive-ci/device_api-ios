module DeviceAPI
  module IOS
    module Plugin
      class Battery
        attr_reader :accurate_level,
                    :external_charge_capable,
                    :fully_charged,
                    :has_battery,
                    :level,
                    :powered,
                    :status

        def initialize(options = {})
          qualifier = options[:qualifier]
          props     = IDevice.get_props(qualifier, :battery)

          @accurate_level          = bool(props[:GasGaugeCapability])
          @external_charge_capable = bool(props[:ExternalChargeCapable])
          @fully_charged           = bool(props[:FullyCharged])
          @has_battery             = bool(props[:HasBattery])
          @level                   = props[:BatteryCurrentCapacity].to_i
          @powered                 = bool(props[:ExternalConnected])
          @status                  = bool(props[:BatteryIsCharging])
        end

        private

        def bool(text)
          text.to_s.casecmp('true').zero?
        end
      end
    end
  end
end
