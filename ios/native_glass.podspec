#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint native_glass.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'native_glass'
  s.version          = '0.0.1'
  s.summary          = 'Native glass UI components for Flutter.'
  s.description      = <<-DESC
Native glass UI components for Flutter.
                       DESC
  s.homepage         = 'http://example.com'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'native_glass' => 'native_glass@example.com' }
  s.source           = { :path => '.' }
  s.source_files = 'native_glass/Sources/native_glass/**/*'
  s.dependency 'Flutter'
  s.platform = :ios, '13.0'

  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.swift_version = '5.0'
end
