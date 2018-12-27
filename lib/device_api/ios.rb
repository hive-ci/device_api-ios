# frozen_string_literal: true

require 'yaml'
require 'device_api/ios/device'
require 'device_api/ios/lib/cfgutil'
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
    def self.device_list_properties
      @device_list_properties ||= {}
    end

    # Returns an array of connected iOS devices
    def self.devices
      @device_list_properties = CFGDevice.devices

      @device_list_properties.keys.map do |serial|
        DeviceAPI::IOS::Device.new(
          qualifier: serial,
          display: @device_list_properties[serial],
          state: 'ok',
          trusted: @device_list_properties[serial]['isPaired'],
          props: @device_list_properties[serial]
        )
      end
    end

    # Retrieve a Device object by serial ID
    def self.device(qualifier)
      @device_list_properties = CFGDevice.devices

      if qualifier.to_s.empty? || !@device_list_properties.key?(qualifier)
        raise DeviceAPI::BadSerialString, 'Serial ID not provided'
      end

      DeviceAPI::IOS::Device.new(
        qualifier: qualifier,
        state: 'device',
        props: @device_list_properties[qualifier]
      )
    end
  end
  # Serial error class
  class BadSerialString < StandardError
    def initialize(msg)
      super(msg)
    end
  end
end
