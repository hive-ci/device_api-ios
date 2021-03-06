require 'device_api/device'
require 'device_api/ios/device'
require 'device_api/ios/lib/cfgutil'
require 'device_api/ios/lib/idevice'
require 'device_api/ios/lib/idevicename'
require 'device_api/ios/lib/idevicescreenshot'
require 'device_api/ios/lib/idevicediagnostics'
require 'device_api/ios/device_model'

# DeviceAPI - an interface to allow for automation of devices
module DeviceAPI
  # iOS component of DeviceAPI
  module IOS
    # Namespace for the Device object.
    class Device < DeviceAPI::Device
      attr_accessor :qualifier
      def self.create(options = {})
        new(options)
      end

      def initialize(options = {})
        @qualifier = options[:qualifier]
        @serial    = options[:serial] || options[:qualifier]
        @props     = options[:props]
        @state     = options[:state]
        @trusted   = options[:trusted]
      end

      # Mapping of device status - used to provide a consistent status across platforms
      # @return (String) common status string
      def status
        {
          'device' => :ok,
          'no device' => :dead,
          'offline' => :offline
        }[@state]
      end

      # Look up device name - i.e. Bob's iPhone
      # @return (String) iOS device name
      def name
        get_prop('name')
        # IDeviceName.name(serial)
      end

      def ecid
        get_prop('ECID')
      end

      # Set device name
      # @param (String) new device name
      # @return (String) device name
      def set_device_name(name)
        IDeviceName.set_name(serial, name)
      end

      # Look up device model using the 'iPad4,7' to 'iPad mini 3'
      # @return (String) human readable model and version (where applicable)
      def model
        DeviceModel.search(get_prop('deviceType'), :name)
        # DeviceModel.search(get_prop(:ProductType), :name)
      end

      # Returns the devices iOS version number - i.e. 8.2
      # @return (String) iOS version number
      def version
        get_prop('firmwareVersion')
        # get_prop(:ProductVersion)
      end

      # Return the device class - i.e. iPad, iPhone, etc
      # @return (String) iOS device class
      def device_class
        get_prop('deviceClass')
        # get_prop(:DeviceClass)
      end

      # Return the device platform
      # @return (String) platform type
      def architecture
        get_prop(:CPUArchitecture) # not avaliable in cfgutil
      end

      # Return the device colour
      # @return (String) hex colour value
      def device_colour
        get_prop('enclosureColor')
        # get_prop(:DeviceColor)
      end

      # Capture screenshot on device
      def screenshot(args = {})
        args[:device_id] = serial
        IDeviceScreenshot.capture(args)
      end

      # Has the 'Trust this device' dialog been accepted?
      # @return (Boolean) true if the device is trusted, otherwise false
      def trusted?
        get_prop('isPaired')
        # IDevice.trusted?(serial)
      end

      # Check if the device is supervised
      # @return (Boolean) true if the device is supervised
      def supervised?
        get_prop('isSupervised')
      end

      # Check if the device is password protected
      # @return (Boolean) true if the device is password protected
      def password_protected?
        get_prop('passcodeProtected')
        # get_prop(:PasswordProtected) == 'true'
      end

      # Get the IP Address from the device
      # @return [String] IP Address of current device
      def ip_address
        IPAddress.address(serial)
      end

      # Get the Wifi Mac address for the current device
      # @return [String] Mac address of current device
      def wifi_mac_address
        get_prop('wifiAddress')
        # get_prop(:WiFiAddress)
      end

      # Install a specified IPA
      # @param [String] ipa string containing path to the IPA to install
      # @return [Boolean, Exception] true when the IPA installed successfully, otherwise an error is raised
      def install(ipa)
        raise StandardError, 'No IPA or app specified.', caller if ipa.empty?

        res = install_ipa(ipa)

        raise StandardError, res, caller unless res

        true
      end

      # Uninstall a specified package
      # @param [String] package_name string containing name of package to uninstall
      # @return [Boolean, Exception] true when the package is uninstalled successfully, otherwise an error is raised
      def uninstall(package_name)
        res = uninstall_package(package_name)

        raise StandardError, res, caller unless res

        true
      end

      # Return whether or not the device is a tablet or mobile
      # @return [Symbol] :tablet or :mobile depending on device_class
      def type
        device_class.casecmp('ipad').zero? ? :tablet : :mobile
      end

      def list_installed_packages
        CFGDevice.list_installed_packages(serial)
      end

      # Reboot the device
      def reboot
        IDeviceDiagnostics.reboot(serial)
      end

      def display_off
        IDeviceDiagnostics.turn_off_display(serial)
      end

      def shutdown
        IDeviceDiagnostics.shutdown(serial)
      end

      # Time

      def clock_24_hour?
        get_prop(:Uses24HourClock) == 'true'
      end

      def timezone
        get_prop(:TimeZone)
      end

      def time
        Time.at(get_prop(:TimeIntervalSince1970).to_f).to_s
      end

      # Network

      # Get the IMEI number of the device
      # @return (String) IMEI number of current device
      def imei
        get_prop('IMEI')
        # get_prop(:InternationalMobileEquipmentIdentity)
      end

      def mobileNetwork
        get_prop(:CFBundleIdentifier)[10..-1]
      end

      # Get mobile bumber
      # @return (String) mobile number
      def mobileNumber
        get_prop(:PhoneNumber).delete(' ')
      end

      # Get country code
      # @return (String) country code
      def countryCode
        get_prop(:PhoneNumber)[1..3].strip
      end

      # Check if device supports telephone
      # @return (Boolean) is telephone supported
      def telephone_supported?
        get_prop(:TelephonyCapability) == 'true'
      end

      # Check if sim card is supported
      # @return (Boolean) simcard supported
      def simcard_supported?
        get_prop(:SIMStatus) == 'kCTSIMSupportSIMStatusReady'
      end

      # Check if sim card is available
      # @return (Boolean) simcard available
      def simcard_available?
        get_prop(:SIMTrayStatus) != 'kCTSIMSupportSIMTrayInsertedNoSIM'
      end

      # Battery

      def charging?
        get_prop('batteryIsCharging')
      end

      def battery_info
        get_prop('batteryCurrentCapacity')
        # DeviceAPI::IOS::Plugin::Battery.new(qualifier: qualifier)
      end

      # Disk
      def disk_info
        get_prop('freeDiskSpace')
        # DeviceAPI::IOS::Plugin::Disk.new(qualifier: qualifier)
      end

      private

      def get_prop(key)
        @props = CFGDevice.get_props(serial) if !@props || !@props[key]
        @props[key]
      end

      def install_ipa(ipa)
        CFGDevice.install_ipa(
          ipa: ipa,
          serial: serial
        )
      end

      def uninstall_package(package_name)
        CFGDevice.uninstall_package(
          package: package_name,
          serial: serial
        )
      end
    end
  end
end
