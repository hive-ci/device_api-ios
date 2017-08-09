# frozen_string_literal: true

# DeviceAPI - an interface to allow for automation of devices
module DeviceAPI
  # iOS component of DeviceAPI
  module IOS
    # Namespace for all methods encapsulating idevicename calls
    class IDeviceDiagnostics < Execution
      # Reboot the device
      def self.reboot(device_id)
        result = execute("idevicediagnostics restart -u #{device_id}")

        raise IDeviceDiagnosticsError, result.stderr if result.exit != 0
        result.stdout
      end

      def self.turn_off_display(device_id)
        result = execute("idevicediagnostics sleep -u #{device_id}")

        raise IDeviceDiagnosticsError, result.stderr if result.exit != 0
        result.stdout
      end

      def self.shutdown(device_id)
        result = execute("idevicediagnostics shutdown -u #{device_id}")

        raise IDeviceDiagnosticsError, result.stderr if result.exit != 0
        result.stdout
      end
    end

    # Error class for IDeviceDiagnostics class
    class IDeviceDiagnosticsError < StandardError
      def initialize(msg)
        super(msg)
      end
    end
  end
end
