require 'spec_helper'
require 'device_api/ios/ideviceinstaller'

RSpec.describe DeviceAPI::IOS::IDeviceInstaller do
  describe '.list_installed_packages' do
    it 'returns a list of installed apps' do
      output = <<-EOF
Total: 2 apps
uk.co.bbc.titan.IPAddress - IPAddress 1
uk.co.bbc.iplayer - BBC iPlayer 4.10.0.196
EOF
      allow(Open3).to receive(:capture3) do
        [output, '', STATUS_ZERO]
      end
      apps = DeviceAPI::IOS::IDeviceInstaller.list_installed_packages('123456')
      expect(apps.count).to eq(2)
    end
  end

  describe '.install_ipa' do
    it 'installs an app' do
      output = <<-EOF
Installing 'uk.co.mediaat.iplayer'
 - CreatingStagingDirectory (5%)
 - ExtractingPackage (15%)
 - InspectingPackage (20%)
 - TakingInstallLock (20%)
 - PreflightingApplication (30%)
 - InstallingEmbeddedProfile (30%)
 - VerifyingApplication (40%)
 - CreatingContainer (50%)
 - InstallingApplication (60%)
 - PostflightingApplication (70%)
 - SandboxingApplication (80%)
 - GeneratingApplicationMap (90%)
 - Complete
EOF
      allow(Open3).to receive(:capture3) do
        [output, '', STATUS_ZERO]
      end
      result = DeviceAPI::IOS::IDeviceInstaller.install_ipa(serial: '123456', ipa: 'iplayer.ipa')
      expect(result).to eq(true)
    end
  end

  describe '.uninstall_app' do
    it 'uninstalls an app' do
      output = <<-EOF
Uninstalling 'uk.co.bbc.iplayer'
 - RemovingApplication (50%)
 - GeneratingApplicationMap (90%)
 - Complete
EOF
      allow(Open3).to receive(:capture3) do
        [output, '', STATUS_ZERO]
      end
      result = DeviceAPI::IOS::IDeviceInstaller.uninstall_package(package: 'uk.co.bbc.iplayer', serial: '123456')
      expect(result).to eq(true)
    end

    it 'fails to remove an app that is not installed' do
      output = <<-EOF
Uninstalling 'uk.co.bbc.iplaye'
 - RemovingApplication (50%)
 - GeneratingApplicationMap (90%)
 - Error occurred: APIInternalError
EOF
      allow(Open3).to receive(:capture3) do
        [output, '', STATUS_ZERO]
      end
      result = DeviceAPI::IOS::IDeviceInstaller.uninstall_package(package: 'uk.co.bbc.iplaye', serial: '123456')
      expect(result).to eq(false)
    end
  end

  describe '.package_installed?' do
    before(:each) do
      output = <<-EOF
Total: 2 apps
uk.co.bbc.titan.IPAddress - IPAddress 1
uk.co.bbc.iplayer - BBC iPlayer 4.10.0.196
EOF
      allow(Open3).to receive(:capture3) do
        [output, '', STATUS_ZERO]
      end
    end

    it 'identifies when a package is installed' do
      result = DeviceAPI::IOS::IDeviceInstaller.package_installed?(package: 'uk.co.bbc.iplayer', serial: '123456')
      expect(result).to eq(true)
    end

    it 'identifies when a package is not installed' do
      result = DeviceAPI::IOS::IDeviceInstaller.package_installed?(package: 'uk.co.bbc.sport', serial: '123456')
      expect(result).to eq(false)
    end
  end
end
