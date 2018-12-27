require 'device_api/execution'
require 'json'

# DeviceAPI - an interface to allow for automation of devices
module DeviceAPI
  # iOS component of DeviceAPI
  module IOS
    # Namespace for all methods encapsulating idevice calls
    class CFGDevice < Execution
      # Returns an array of hashes representing connected devices
      # @return (Array) Hash containing serial and device name
      def self.devices
        result = execute_with_timeout_and_retry('cfgutil --format JSON -f get all')

        raise CFGDeviceCommandError, result.stderr if result.exit != 0

        devices = JSON.parse(result.stdout)['Output']
        results = {}

        devices.each do |_key, value|
          results[value['UDID']] = value
        end

        results
      end

      # Returns a Hash containing properties of the specified device using idevice_id.
      # @param device_id uuid of the device
      # @return (Hash) key value pair of properties
      def self.get_props(device_id)
        raise IDeviceCommandError, "Unable to find 'UDID': #{device_id}" unless devices.key?(device_id)

        devices[device_id]
      end

      # Check to see if device has trusted the computer
      # @param device_id uuid of the device
      # @return true if the device returns information to ideviceinfo, otherwise false
      def self.trusted?(device_id)
        get_props(device_id)['isPaired']
      end
    end

    # Exception class to handle exceptions related to IDevice Class
    class CFGDeviceCommandError < StandardError
      def initialize(msg)
        super(msg)
      end
    end
  end
end
