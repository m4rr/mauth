platform :ios, '8.3'
use_frameworks!
inhibit_all_warnings!

target 'mauth' do
  pod 'PKHUD', '~> 4.0'
  pod 'PSOperations', '~> 3.0'
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |configuration|
      # these libs work now only with Swift3.2 in Xcode9
      if ['PKHUD', 'PSOperations'].include? target.name
        configuration.build_settings['SWIFT_VERSION'] = "3.2"
      end
    end
  end
end
