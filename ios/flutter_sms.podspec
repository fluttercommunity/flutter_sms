#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint flutter_sms.podspec' to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'flutter_sms'
  s.version          = '1.1.0'
  s.summary          = 'A Flutter plugin for Sending SMS on Android and iOS.'
  s.description      = <<-DESC
A new flutter plugin project.
                       DESC
  s.homepage         = 'https://github.com/fluttercommunity/flutter_sms'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Rody Davis' => 'rody.davis.jr@gmail.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.public_header_files = 'Classes/**/*.h'
  s.dependency 'Flutter'
  s.platform = :ios, '8.0'

  # Flutter.framework does not contain a i386 slice. Only x86_64 simulators are supported.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'VALID_ARCHS[sdk=iphonesimulator*]' => 'x86_64' }
end
