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

      # Installs a given IPA to the specified device
      # @param [Hash] options options for installing the app
      # @option options [String] :ipa path to the IPA to install
      # @option options [String] :serial serial of the target device
      # @return [Boolean] true if successful, otherwise false
      def self.install_ipa(options = {})
        options[:action] = :install
        change_package(options)
      end

      # Uninstalls a specified package from a device
      # @param [Hash] options options for uninstalling the app
      # @option options [String] :package bundle ID of the package to be uninstalled
      # @option options [String] :serial serial of the target device
      # @return [Boolean] true if successful, otherwise false
      def self.uninstall_package(options = {})
        options[:action] = :uninstall
        change_package(options)
      end

      def self.fetch_ecid(serial)
        get_props(serial)['ECID']
      end

      # Lists packages installed on the specified device
      # @param [String] serial serial of the target device
      # @return [Hash] hash containing installed packages
      def self.list_installed_packages(serial)
        list_of_packages = get_props(serial)['installedApps']

        packages = {}

        list_of_packages.each do |item|
          packages[item['itunesName']] = {
            package_name: item['bundleIdentifier'],
            itunes_name: item['itunesName'],
            display_name: item['displayName'],
            version: item['bundleVersion']
          }
        end
        packages
      end

      def self.change_package(options = {})
        package = options[:package]
        ipa     = options[:ipa]
        serial  = fetch_ecid(options[:serial])
        action  = options[:action]

        command = nil
        if action == :install
          command = "cfgutil -e #{serial} install-app '#{ipa}'"
        elsif action == :uninstall
          command = "cfgutil -e #{serial} remove-app '#{package}'"
        end

        raise CFGDeviceCommandError, 'No action specified' if command.nil?

        result = execute(command)

        raise CFGDeviceCommandError, result.stderr if result.exit != 0

        lines = result.stdout.split("\n").map { |line| line.delete('-').strip }

        return true if lines.last.match('succeeded')

        false
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
