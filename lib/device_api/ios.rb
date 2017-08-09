# frozen_string_literal: true

require 'yaml'
require 'device_api/ios/device'
require 'device_api/ios/lib/idevice'
require 'device_api/ios/lib/ideviceinstaller'
require 'device_api/ios/lib/idevicedebug'
require 'device_api/ios/lib/ipaddress'
require 'device_api/ios/lib/ideviceprovision'
require 'device_api/ios/lib/idevicename'

# Load plugins
require 'device_api/ios/plugins/battery'
require 'device_api/ios/plugins/disk'

module DeviceAPI
  module IOS
    # Returns an array of connected iOS devices
    def self.devices
      devs = IDevice.devices
      devs.keys.map do |serial|
        DeviceAPI::IOS::Device.new(qualifier: serial,
                                   display: devs[serial],
                                   state: 'ok')
      end
    end

    # Retrieve a Device object by serial ID
    def self.device(qualifier)
      if qualifier.to_s.empty?
        raise DeviceAPI::BadSerialString, 'Serial ID not provided'
      end
      DeviceAPI::IOS::Device.new(qualifier: qualifier, state: 'device')
    end
  end
  # Serial error class
  class BadSerialString < StandardError
    def initialize(msg)
      super(msg)
    end
  end
end
