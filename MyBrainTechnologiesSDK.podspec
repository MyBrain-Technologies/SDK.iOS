Pod::Spec.new do |s|
 s.name = 'MyBrainTechnologiesSDK'
 s.version = '0.0.1'
 s.license = { :type => "MIT", :file => "LICENSE" }
 s.summary = 'Swift iOS SDK for MyBrainTechnologies Headphones'
 s.homepage = 'http://www.melomind.com'
 s.authors = { "Baptiste Rasschaert" => "baptiste.rasschaert@gmail.com" }
 s.source = { :git => "~/Sites/MyBrainTechnologiesSDK/.git", :tag => "v"+s.version.to_s }
 s.source_files = "Sources", "Sources/**/*.{h,m,swift}"
 s.framework = "Foundation", "CoreBluetooth"
 s.platforms     = { :ios => "8.0" }

end
