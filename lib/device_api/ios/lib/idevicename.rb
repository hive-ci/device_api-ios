# frozen_string_literal: true

# DeviceAPI - an interface to allow for automation of devices
module DeviceAPI
  # iOS component of DeviceAPI
  module IOS
    # Namespace for all methods encapsulating idevicename calls
    class IDeviceName < Execution
      # Returns the device name based on the provided UUID
      # @param device_id uuid of the device
      # @return device name if device is connected
      def self.name(device_id)
        result = execute("idevicename -u #{device_id}")
        raise IDeviceNameError, result.stderr if result.exit != 0
        result.stdout.strip
      end

      # Set new device name based on the provided UUID
      # @param device_id uuid of the device
      # @param name new device name
      # @return new device name
      def self.set_name(device_id, name)
        raise IDeviceNameError, 'No Device name specified' if name.empty?

        result = execute("idevicename -u #{device_id} '#{name}'")
        return IDeviceNameError, result.stderr if result.exit != 0
        result.stdout.strip
      end
    end

    # Error class for the IDeviceName class
    class IDeviceNameError < StandardError
      def initialize(msg)
        super(msg)
      end
    end
  end
end
