require 'spec_helper'
require 'device_api/ios/idevice'

RSpec.describe DeviceAPI::IOS::IDevice do
  describe '.devices' do
    it 'detects devices attached to device' do
      allow(Open3).to receive(:capture3).with('idevice_id -l').and_return(["12345678\n23451234\n", '', STATUS_ZERO])
      allow(Open3).to receive(:capture3).with('ideviceinfo -u 12345678 -k DeviceName').and_return(["Device-1\n", '', STATUS_ZERO])
      allow(Open3).to receive(:capture3).with('ideviceinfo -u 23451234 -k DeviceName').and_return(["Device-2\n", '', STATUS_ZERO])

      expect(DeviceAPI::IOS::IDevice.devices).to match(
        '12345678' => 'Device-1',
        '23451234' => 'Device-2'
      )
    end

    it 'detects an empty list of devices' do
      allow(Open3).to receive(:capture3).with('idevice_id -l').and_return(['', '', STATUS_ZERO])

      expect(DeviceAPI::IOS::IDevice.devices).to match({})
    end
  end

  describe '#trusted?' do
    trusted = "ideviceinfo -u '00000001'"

    it 'reports a connected device as trusted' do
      output = <<-EOF
        ActivationState: Activated
        ActivationStateAcknowledged: true
        BasebandActivationTicketVersion: V2
        BasebandCertId: 2
      EOF

      allow(Open3).to receive(:capture3).with(trusted).and_return([output, '', STATUS_ZERO])
      expect(DeviceAPI::IOS::IDevice.trusted?('00000001')).to be_truthy
    end

    it 'reports a connected device as not trusted' do
      error = "ERROR: Could not connect to lockdownd, error code -19\n"
      allow(Open3).to receive(:capture3).with(trusted).and_return(['', error, STATUS_TWO_FIVE_FIVE])
      expect(DeviceAPI::IOS::IDevice.trusted?('00000001')).to be_falsey
    end

    it 'reports a not connected device as not trusted' do
      output = <<-EOF
        Usage: ideviceinfo [OPTIONS]
        Show information about a connected device.

          -d, --debug   enable communication debugging
      EOF
      # So apparently calling ideviceinfo with an unknown id results in a success
      allow(Open3).to receive(:capture3).with(trusted).and_return([output, '', STATUS_ZERO])
      expect(DeviceAPI::IOS::IDevice.trusted?('00000001')).to be_falsey
    end

    it 'reports a success with no output as not trusted' do
      # This is unlikely but can occur
      # Possibly due to a race condition
      allow(Open3).to receive(:capture3).with(trusted).and_return(['', '', STATUS_ZERO])
      expect(DeviceAPI::IOS::IDevice.trusted?('00000001')).to be_falsey
    end
  end
end
