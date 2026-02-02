Pod::Spec.new do |s|
  s.name             = 'flutter_network_diagnostics'
  s.version          = '0.0.1'
  s.summary          = 'Network diagnostics for Flutter'
  s.description      = <<-DESC
Network diagnostics plugin for Flutter applications.
                       DESC
  s.homepage         = 'http://example.com'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Your Company' => 'email@example.com' }
  s.source           = { :path => '.' }
  s.source_files     = 'Classes/**/*'
  s.public_header_files = 'Classes/**/*.h'
  s.dependency 'Flutter'
  s.platform = :ios, '13.0'

  s.pod_target_xcconfig = { 
    'DEFINES_MODULE' => 'YES', 
    'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386',
    'HEADER_SEARCH_PATHS' => '$(SDKROOT)/usr/include'
  }
  
  s.swift_version = '5.0'
  s.libraries = 'resolv'
end