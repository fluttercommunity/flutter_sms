#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint flutter_sms.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'flutter_sms'
  s.version          = '2.0.0'
  s.summary          = 'A Flutter plugin for Sending SMS on Android and iOS.'
  s.description      = <<-DESC
A Flutter plugin that provides SMS sending functionality for both Android and iOS platforms.
Supports both direct SMS sending and SMS dialog interface.
                       DESC
  s.homepage         = 'https://github.com/fluttercommunity/flutter_sms'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Flutter Community' => 'flutter-community@example.com' }
  s.source           = { :path => '.' }
  s.source_files     = 'Classes/**/*'
  s.public_header_files = 'Classes/**/*.h'
  s.dependency 'Flutter'
  
  # Updated platform requirements
  s.platform = :ios, '15.0'
  s.ios.deployment_target = '15.0'
  
  # Updated architecture support
  s.pod_target_xcconfig = { 
    'DEFINES_MODULE' => 'YES', 
    'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386',
    'SWIFT_VERSION' => '5.0'
  }
  
  # Swift version specification
  s.swift_version = '5.0'
  
  # Add required frameworks
  s.frameworks = 'MessageUI'
  
  # Weak frameworks for optional features
  s.weak_frameworks = 'UserNotifications'
end