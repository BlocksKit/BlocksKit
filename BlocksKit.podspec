Pod::Spec.new do |s|
  s.name                  = 'BlocksKit'
  s.version               = '2.0.0'
  s.license               = 'MIT'
  s.summary               = 'The Objective-C block utilities you always wish you had.'
  s.homepage              = 'https://github.com/pandamonia/BlocksKit'
  s.author                = { 'Zachary Waldowski' => 'zwaldowski@gmail.com',
							  'Alexsander Akers'  => 'a2@pandamonia.us' }
  s.source                = { :git => 'https://github.com/pandamonia/BlocksKit.git', :tag => "v#{s.version}" }
  s.requires_arc          = true
  s.osx.deployment_target = '10.7'
  s.ios.deployment_target = '5.0'

  s.default_subspec = 'All'
  s.subspec 'All' do |ss|
  	ss.dependency 'BlocksKit/Core'
  	ss.dependency 'BlocksKit/DynamicDelegate'
  	ss.ios.dependency 'BlocksKit/MessageUI'
  	ss.ios.dependency 'BlocksKit/UIKit'
  end

  s.subspec 'Core' do |ss|
    ss.source_files = 'BlocksKit/BlocksKit.h', 'BlocksKit/Core/*.{h,m}'
  end

  s.subspec 'DynamicDelegate' do |ss|
    ss.source_files = 'BlocksKit/BlocksKit.h', 'BlocksKit/Dynamic Delegate/*.{h,m}', 'BlocksKit/Dynamic Delegate/Foundation/*.{h,m}'
    ss.ios.dependency 'libffi'
    ss.osx.library = 'ffi'
  end

  s.subspec 'MessageUI' do |ss|
  	ss.dependency 'BlocksKit/DynamicDelegate'
  	ss.platform = :ios
  	ss.source_files = 'BlocksKit/BlocksKit+MessageUI.h', 'BlocksKit/MessageUI/*.{h,m}'
  	ss.ios.frameworks = 'MessageUI'
  end

  s.subspec 'UIKit' do |ss|
  	ss.dependency 'BlocksKit/DynamicDelegate'
  	ss.platform = :ios
  	ss.source_files = 'BlocksKit/BlocksKit+UIKit.h', 'BlocksKit/UIKit/*.{h,m}'
  end
end
