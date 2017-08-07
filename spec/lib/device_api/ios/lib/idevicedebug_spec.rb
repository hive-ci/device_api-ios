require 'spec_helper'
require 'device_api/ios/lib/idevicedebug'

RSpec.describe DeviceAPI::IOS::IDeviceDebug do
  describe '.run' do
    it 'idevicedebug error' do
      allow(Open3).to receive(:capture3) { ['', 'provision profile error', STATUS_ONE] }

      expect { described_class.run(serial: '12345', bundle_id: 'com.hive.player') }.to raise_error(
        DeviceAPI::IOS::IDeviceDebugError, 'provision profile error'
      )
    end
  end

  describe '.has_profile?' do
    it 'text' do
    end
  end
end
