require 'device_api/ios/device_model'

describe DeviceAPI::IOS::DeviceModel do
  subject { described_class }
  describe '#deviceModel' do
    it 'loads the CSV only once ' do
      expect(CSV).to receive(:read).once.and_call_original
      subject.devices
    end
  end

  describe '#search' do
    context 'with product ID containing a comma' do
      it 'should return the display name' do
        subject.devices
        expect(subject.search('iPhone10,6')).to eq('iPhone X')
      end
    end

    context 'with product ID without containing a comma' do
      it 'should return the display name' do
        subject.devices
        expect(subject.search('iPhone106')).to eq('iPhone X')
      end
    end

    context 'find extra device info' do
      it 'should return extra device info if its avaliable' do
        subject.devices
        expect(subject.search('iPad51 ', :extra)).to eq('Wi-Fi')
      end
    end
  end
end
