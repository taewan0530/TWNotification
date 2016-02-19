@version = "0.0.5"
Pod::Spec.new do |s|
  s.name         = 'TWNotification'
  s.version      = @version
  s.summary      = 'ios style notification'
  s.homepage     = 'https://github.com/taewan0530/TWNotification'
  s.license      = { :type => 'MIT', :file => 'LICENSE' }
  s.author       = { 'taewan' => 'taewan0530@daum.net' }
  s.source       = { :git => "https://github.com/taewan0530/TWNotification.git", :tag => @version }
  s.source_files = 'TWNotification/**/*.{swift,xib}'
  
  s.requires_arc = true
  s.ios.deployment_target = '8.0'
end