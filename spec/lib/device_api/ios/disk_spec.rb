require 'spec_helper'
require 'device_api/ios'

RSpec.describe DeviceAPI::IOS::Plugin::Disk do
  describe 'Disk info' do
    output = <<-EOF
        AmountDataAvailable: 20268466176
        AmountDataReserved: 209715200
        CalculateDiskUsage: OkilyDokily
        CalendarUsage: 1617920
        CameraUsage: 90726314
        MediaCacheUsage: 20480
        NANDInfo: AAAAAA=
        NotesUsage: 122880
        PhotoUsage: 90730659
        TotalDataAvailable: 20478181376
        TotalDataCapacity: 28379455488
        TotalDiskCapacity: 31698497536
        TotalSystemAvailable: 335544320
        TotalSystemCapacity: 3319042048
        VoicemailUsage: 0
        WebAppCacheUsage: 0
    EOF

    it 'validate disk infomation' do
      allow(Open3).to receive(:capture3) do
        [output, '', STATUS_ZERO]
      end

      disk = DeviceAPI::IOS::Device.create(qualifier: '12345').disk_info
      expect(disk.total_space).to eq('26.43GB')
      expect(disk.available_space).to eq('19.07GB')
      expect(disk.used_space).to eq('7.36GB')
      expect(disk.available).to eq(72)
    end
  end
end
