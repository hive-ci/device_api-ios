# frozen_string_literal: true

require 'spec_helper'
require 'device_api/ios'

RSpec.describe DeviceAPI::IOS::Plugin::Battery do
  describe 'Battery info' do
    before do
      output = <<-EOF
        BatteryCurrentCapacity: 70
        BatteryIsCharging: true
        ExternalChargeCapable: true
        ExternalConnected: true
        FullyCharged: false
        GasGaugeCapability: true
        HasBattery: true
      EOF

      allow(Open3).to receive(:capture3) { [output, '', STATUS_ZERO] }
    end

    it 'validate battery infomation' do
      battery = DeviceAPI::IOS::Device.create(qualifier: '12345').battery_info

      expect(battery.level).to eq(70)
      expect(battery.status).to eq(true)
      expect(battery.external_charge_capable).to eq(true)
      expect(battery.fully_charged).to eq(false)
      expect(battery.accurate_level).to eq(true)
      expect(battery.has_battery).to eq(true)
      expect(battery.powered).to eq(true)
    end
  end
end
