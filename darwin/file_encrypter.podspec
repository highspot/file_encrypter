#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#
Pod::Spec.new do |s|
  s.name             = 'file_encrypter'
  s.version          = '0.0.1'
  s.summary          = 'iOS and macOS implementation of the file_encrypter plugin.'
  s.description      = <<-DESC
Wraps CommonCrypto, providing fast encrypt and decrypt functionality.
                       DESC
  s.homepage         = 'https://acmesoftware.com'
  s.license          = { :type => 'BSD', :file => '../LICENSE' }
  s.author           = { 'Acme Software LLC' => 'dev@acmesoftware.com' }
  s.source           = { :path => '.' }
  s.source_files = 'file_encrypter/Sources/file_encrypter/**/*.swift'
  s.ios.dependency 'Flutter'
  s.osx.dependency 'FlutterMacOS'
  s.ios.deployment_target = '12.0'
  s.osx.deployment_target = '10.14'
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES' }
  s.swift_version = '5.0'
  s.resource_bundles = {'file_encrypter_privacy' => ['file_encrypter/Sources/file_encrypter/Resources/PrivacyInfo.xcprivacy']}
end
