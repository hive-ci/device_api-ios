require 'csv'
module DeviceAPI
  module IOS
    module DeviceModel
      def self.search(device_model, type = nil)
        key_type = type || :name
        key      = device_model.strip.tr(',', '')

        if models.key?(key)
          models[key][key_type]
        elsif key_type == :name
          device_model
        end
      end

      def self.devices
        return @devices unless @device_list.nil?
        @csv_file = File.expand_path('devices/devcies.csv', File.dirname(__FILE__))
        @devices  = CSV.read(@csv_file)
      end

      def self.models
        return @models unless @models.nil?
        @models = {}
        devices.shift
        devices.each do |(device_type, product_name, extra, id)|
          @models[device_type] = { device_type: device_type,
                                   name: product_name,
                                   extra: extra,
                                   id: id }
        end
        @models
      end
    end
  end
end
