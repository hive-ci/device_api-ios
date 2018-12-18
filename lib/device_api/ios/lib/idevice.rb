require 'device_api/execution'

# DeviceAPI - an interface to allow for automation of devices
module DeviceAPI
  # iOS component of DeviceAPI
  module IOS
    # Namespace for all methods encapsulating idevice calls
    class IDevice < Execution
      # Returns an array of hashes representing connected devices
      # @return (Array) Hash containing serial and device name
      def self.devices
        result = execute_with_timeout_and_retry('idevice_id -l')

        raise IDeviceCommandError, result.stderr if result.exit != 0

        lines   = result.stdout.split("\n")
        results = {}

        lines.each do |ln|
          if /[0-9a-zA-Z].*/.match(ln)
            results[ln] = execute_with_timeout_and_retry("ideviceinfo -u #{ln}").stdout.strip
          end
        end
        results
      end

      # Check to see if device has trusted the computer
      # @param device_id uuid of the device
      # @return true if the device returns information to ideviceinfo, otherwise false
      def self.trusted?(device_id)
        result = execute("ideviceinfo -u #{device_id}")

        lines = result.stdout.split("\n")
        result.exit.zero? && !lines.empty? && !lines[0].match('Usage')
      end

      # Returns a Hash containing properties of the specified device using idevice_id.
      # @param device_id uuid of the device
      # @return (Hash) key value pair of properties
      def self.get_props(device_id, type = nil)
        type_info = deviceinfo_type(type)
        result = execute("ideviceinfo -u #{device_id} #{type_info}")

        raise IDeviceCommandError, result.stderr if result.exit != 0

        result = result.stdout
        props  = {}
        unless result.start_with?('Usage:')
          prop_list = result.split("\n")
          prop_list.each do |line|
            line.scan(/(.*): (.*)/).map do |(key, value)|
              props[key.strip.to_sym] = value.strip
            end
          end
        end

        props
      end

      private

      def self.deviceinfo_type(app)
        return if app.nil?

        app_type = case app
                   when :apps
                     'com.apple.mobile.iTunes'
                   when :battery
                     'com.apple.mobile.battery'
                   when :developer
                     'developerdomain'
                   when :disk
                     'com.apple.disk_usage.factory'
                   when :icloud
                     'com.apple.mobile.data_sync'
                   when :mobile
                     'com.apple.mobile.internal'
                   when :restriction
                     'com.apple.mobile.restriction'
                   when :software_behavior
                     'com.apple.mobile.software_behavior'
                   when :sync_data
                     'com.apple.mobile.sync_data_class'
                   when :wireless
                     'com.apple.mobile.wireless_lockdown'
        end
        " -q #{app_type}"
      end
    end

    # Exception class to handle exceptions related to IDevice Class
    class IDeviceCommandError < StandardError
      def initialize(msg)
        super(msg)
      end
    end
  end
end
