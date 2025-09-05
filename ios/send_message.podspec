#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint send_message.podspec' to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'send_message'
  s.version          = '1.0.1'
  s.summary          = 'A Flutter plugin to Send SMS and MMS on iOS and Android.'
  s.description      = <<-DESC
A Flutter plugin to Send SMS and MMS on iOS and Android. If iMessage is enabled it will send as iMessage on iOS. This plugin must be tested on a real device on iOS.
                       DESC
  s.homepage         = 'https://github.com/DabhiNavaghan/send_message'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Navaghan Dabhi' => '@DabhiNavaghan' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.public_header_files = 'Classes/**/*.h'
  s.dependency 'Flutter'
  s.platform = :ios, '13.0'

  # Flutter.framework does not contain a i386 slice. Only x86_64 simulators are supported.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'VALID_ARCHS[sdk=iphonesimulator*]' => 'x86_64' }
end
