# frozen_string_literal: true

require 'spec_helper'
require 'device_api/ios/lib/ideviceprovision'

RSpec.describe DeviceAPI::IOS::IDeviceProvision do
  describe '.list_profiles' do
    it 'returns a list of provision profiles' do
      output = <<-EOF.unindent
        Device has 16 provisioning profiles installed:
        re454f27-0a59-4c84-827f-1561bbd56cfb - Test1
        99ere12d-a612-4654-b356-af3e43544513 - Wildcard Dec
        9db84544-9d51-435f-9c45-6cc454454560 - Development
      EOF

      list_output = {
        're454f27-0a59-4c84-827f-1561bbd56cfb' => 'Test1',
        '99ere12d-a612-4654-b356-af3e43544513' => 'Wildcard Dec',
        '9db84544-9d51-435f-9c45-6cc454454560' => 'Development'
      }

      allow(Open3).to receive(:capture3) { [output, '', STATUS_ZERO] }
      expect(described_class.list_profiles('123456')).to eq(list_output)
    end
  end

  describe '.has_profile?' do
    it 'check provision profile' do

      options = {
        name: 'Development',
        uuid: '9db84544-9d51-435f-9c45-6cc454454560',
        serial: '12345'
      }
      output = <<-EOF.unindent
        Device has 16 provisioning profiles installed:
        re454f27-0a59-4c84-827f-1561bbd56cfb - Test1
        99ere12d-a612-4654-b356-af3e43544513 - Wildcard Dec
        9db84544-9d51-435f-9c45-6cc454454560 - Development
      EOF

      allow(Open3).to receive(:capture3) { [output, '', STATUS_ZERO] }
      expect(described_class.has_profile?(options)).to eq(true)
    end
  end

  describe '.remove_profile' do
    it 'remove provision profile' do
      options = {
        uuid: '9db84544-9d51-435f-9c45-6cc454454560',
        serial: '12345'
      }
      output = <<-EOF.unindent
        Device has 16 provisioning profiles installed:
        re454f27-0a59-4c84-827f-1561bbd56cfb - Test1
        99ere12d-a612-4654-b356-af3e43544513 - Wildcard Dec
      EOF

      allow(Open3).to receive(:capture3) { [output, '', STATUS_ZERO] }
      expect(described_class.remove_profile(options)).to eq(true)
    end
  end
end
