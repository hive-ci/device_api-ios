# frozen_string_literal: true

# DeviceAPI - an interface to allow for automation of devices
module DeviceAPI
  # iOS component of DeviceAPI
  module IOS
    # Namespace for all methods encapsulating idevice calls
    class IDeviceDebug < Execution
      # idevicedebug doesn't return until the app you are attempting to run
      # exits. By passing in a timeout value we can limit how long we wait
      # before terminating the debug session
      # @param [Hash] options options for debug running
      # @option options [String] :serial serial of the device run
      # @option options [String] :bundle_id ID of the app to run
      # @option options [Integer] :timeout Number of seconds before the debug session should be killed
      # @return [Hash] Returns the stdout of the debug session
      def self.run(options = {})
        serial    = options[:serial]
        bundle_id = options[:bundle_id]
        timeout   = options[:timeout] || 10

        timeout_command = "doalarm () { perl -e 'alarm shift; exec @ARGV' \"$@\"; }; doalarm #{timeout}"

        result = execute("#{timeout_command} idevicedebug -u #{serial} -d run #{bundle_id}")

        raise IDeviceDebugError, result.stderr unless [0, 255, 142].include?(result.exit)

        result.stdout.split("\n").map(&:strip)
      end
    end

    # Error class for the IDeviceDebug class
    class IDeviceDebugError < StandardError
      def initialize(msg)
        super(msg)
      end
    end
  end
end
