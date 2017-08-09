require 'spec_helper'
require 'device_api/ios/device'

RSpec.describe DeviceAPI::IOS::Device do
  describe '.create' do
    it 'creates an instance of DeviceAPI::IOS::Device' do
      expect(described_class.create(qualifier: '12345')).to be_a DeviceAPI::IOS::Device
    end

    it 'sets the serial to be the qualifier' do
      expect(described_class.create(qualifier: '12345').serial).to eq('12345')
    end

    it 'uses serial to override the qualifer if it is set' do
      expect(described_class.create(qualifier: '12345', serial: '98765').serial).to eq('98765')
    end

    it 'sets the qualifier' do
      expect(described_class.create(qualifier: '12345').qualifier).to eq '12345'
    end

    it 'does not override the qualifier with the serial' do
      expect(described_class.create(qualifier: '12345', serial: '98765').qualifier).to eq '12345'
    end
  end
end
