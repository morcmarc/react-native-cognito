Pod::Spec.new do |s|
  s.name         = "react-native-cognito"
  s.version      = "1.3.1-alpha"
  s.summary      = "AWS Cognito integration module for React Native"
  s.requires_arc = true
  s.author       = { 'Marcell Jusztin' => 'hello@morcmarc.com' }
  s.license      = 'MIT'
  s.homepage     = 'https://github.com/morcmarc/react-native-cognito'
  s.source       = { :git => "https://github.com/morcmarc/react-native-cognito.git" }
  s.platform     = :ios, "7.0"
  s.dependency 'React'

  s.subspec 'RCTCognito' do |ss|
    ss.source_files     = "RCTCognito/*.{h,m}"
  end

  s.subspec 'RCTCognitoProj' do |ss|
    ss.dependency         'react-native-cognito/RCTCognito'
    ss.source_files     = "*.{h,m}"
    ss.preserve_paths   = "*.js"
  end
end