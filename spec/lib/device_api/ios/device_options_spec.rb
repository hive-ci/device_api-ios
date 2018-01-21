# frozen_string_literal: true

require 'spec_helper'
require 'device_api/ios'
require 'device_api/ios/lib/idevicediagnostics'
require 'device_api/ios/lib/idevicescreenshot'
require 'device_api/ios/lib/idevicename'
require 'device_api/ios/device_model'

RSpec.describe DeviceAPI::IOS::Device do
  let(:device) { DeviceAPI::IOS.device('123456') }

  describe '.model' do
    it 'Returns model name' do
      allow(Open3).to receive(:capture3) { ["ProductType: iPad6,4\n", '', STATUS_ZERO] }
      expect(device.model).to eq('iPad Pro 9.7 inch')
    end

    it 'returns the correct result when a device is trusted' do
      output = <<-EOF
        ActivationState: Activated
        ActivationStateAcknowledged: true
      EOF

      allow(Open3).to receive(:capture3) { [output, '', STATUS_ZERO] }
      expect(device.trusted?).to eq(true)
    end

    it 'returns the correct result when a device is not trusted' do
      expect(device.trusted?).to eq(false)
    end

    it 'is device password protected' do
      output = <<-EOF
        PasswordProtected: true
      EOF

      allow(Open3).to receive(:capture3) { [output, '', STATUS_ZERO] }
      expect(device.password_protected?).to eq(true)
    end

    it 'returns device state' do
      expect(device.status).to eq(:ok)
    end

    it 'reboot device' do
      output = 'Restarting device.'

      allow(Open3).to receive(:capture3) { [output, '', STATUS_ZERO] }

      expect(device.reboot).to eq('Restarting device.')
    end

    it 'reboot device error' do
      allow(Open3).to receive(:capture3) { ['', 'Error', STATUS_ONE] }

      expect { device.reboot }.to raise_error(
        DeviceAPI::IOS::IDeviceDiagnosticsError, 'Error'
      )
    end

    it 'turn off display' do
      output = 'Putting device into deep sleep mode.'

      allow(Open3).to receive(:capture3) { [output, '', STATUS_ZERO] }

      expect(device.display_off).to eq('Putting device into deep sleep mode.')
    end

    it 'turn off device' do
      output = 'Shutting down device.'

      allow(Open3).to receive(:capture3) { [output, '', STATUS_ZERO] }

      expect(device.shutdown).to eq('Shutting down device.')
    end

    it 'returns the device name' do
      output = <<-EOF
        Test Device
      EOF

      allow(Open3).to receive(:capture3) { [output, '', STATUS_ZERO] }

      expect(device.name).to eq('Test Device')
    end

    it 'set device name' do
      output = <<-EOF
        device name set to 'New iOS Device'
      EOF

      allow(Open3).to receive(:capture3) { [output, '', STATUS_ZERO] }

      expect(device.set_device_name('New iOS Device')).to include('New iOS Device')
    end

    it 'set device name error' do
      expect { DeviceAPI::IOS::IDeviceName.set_name('123456', '') }.to raise_error(
        DeviceAPI::IOS::IDeviceNameError, 'No Device name specified'
      )
    end

    it 'screenshot' do
      options = {
        device_id: '12345',
        filename: 'new_image.png'
      }

      output = <<-EOF.unindent
        Screenshot saved to '#{options[:filename]}'
      EOF

      allow(Open3).to receive(:capture3) { [output, '', STATUS_ZERO] }
      expect(device.screenshot(options)).to eq(output)
    end

    it 'fail taking screenshot' do
      options = {
        device_id: '12345 -k',
        filename: 'new_image.png'
      }

      allow(Open3).to receive(:capture3) { ['', '', STATUS_ONE] }
      expect { device.screenshot(options) }.to raise_error(
        DeviceAPI::IOS::IDeviceScreenshotError
      )
    end
  end

  describe 'device info' do
    before do
      output = <<-EOF
        ProductName: iPhone OS
        ProductType: iPad6,4
        ProductVersion: 9.3
        DeviceClass: iPad
        CPUArchitecture: arm64
        DeviceColor: #e4e7e8
        Uses24HourClock: false
        TimeZone: Europe/London
        TimeIntervalSince1970: 1501661426.879714
      EOF

      allow(Open3).to receive(:capture3) { [output, '', STATUS_ZERO] }
    end

    let(:device) { DeviceAPI::IOS.device('123456') }

    it 'returns the device version' do
      expect(device.version).to eq('9.3')
    end

    it 'return the device classification' do
      expect(device.device_class).to eq('iPad')
    end

    it 'return the device type' do
      expect(device.type).to eq(:tablet)
    end

    it 'return the device architecture' do
      expect(device.architecture).to eq('arm64')
    end

    it 'return the device colour' do
      expect(device.device_colour).to eq('#e4e7e8')
    end

    it '24hr clock' do
      expect(device.clock_24_hour?).to eq(false)
    end

    it 'timezone' do
      expect(device.timezone).to eq('Europe/London')
    end

    it 'current time' do
      expect(device.time).to eq('2017-08-02 09:10:26 +0100')
    end
  end
end
