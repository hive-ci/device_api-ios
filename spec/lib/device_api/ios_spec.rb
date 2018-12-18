# frozen_string_literal: true

require 'spec_helper'
require 'device_api/ios'

RSpec.describe DeviceAPI::IOS do
  describe '.devices' do
    it 'detects devices attached to device' do
      output = <<-EOF.unindent
        12345678
        23451234
      EOF

      first_device = <<-EOF
        ActivationState: Activated
        ActivationStateAcknowledged: true
        BasebandActivationTicketVersion: V2
        BasebandCertId: 2
      EOF

      second_device = 'ERROR: Could not connect to lockdownd, error code -2'

      allow(Open3).to receive(:capture3).with('idevice_id -l')
                                        .and_return([output, '', STATUS_ZERO])

      allow(Open3).to receive(:capture3).with('ideviceinfo -u 12345678')
                                        .and_return([first_device, '', STATUS_ZERO])

      allow(Open3).to receive(:capture3).with('ideviceinfo -u 23451234')
                                        .and_return([second_device, '', STATUS_TWO_FIVE_FIVE])

      devices = described_class.devices

      expect(devices.length).to eq(2)
      expect(devices.map(&:serial)).to match_array(%w[12345678 23451234])
      expect(devices.map(&:trusted?)).to match_array([true, false])
    end

    it 'detects an empty list of devices' do
      allow(Open3).to receive(:capture3).with('idevice_id -l').and_return(['', '', STATUS_ZERO])

      expect(described_class.devices).to match([])
    end
  end

  describe '.device' do
    it 'empty serial ID' do
      expect { described_class.device('') }.to raise_error(DeviceAPI::BadSerialString, 'Serial ID not provided')
    end
  end
end
