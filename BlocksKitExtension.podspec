Pod::Spec.new do |s|
  s.name                  = 'BlocksKitExtension'
  s.version               = '2.2.6'
  s.license               = 'MIT'
  s.summary               = 'The Objective-C block utilities you always wish you had.'
  s.homepage              = 'https://zwaldowski.github.io/BlocksKit'
  s.author                = { 'Zachary Waldowski' => 'zach@waldowski.me',
                              'Alexsander Akers'  => 'a2@pnd.mn' }
  s.source                = { :git => 'https://github.com/zwaldowski/BlocksKit.git', :tag => "v#{s.version}" }
  s.requires_arc          = true
  s.osx.deployment_target = '10.8'
  s.ios.deployment_target = '6.0'
  s.watchos.deployment_target = '2.0'

  s.default_subspec = 'All'
  s.subspec 'All' do |ss|
    ss.dependency 'BlocksKit/Core'
    ss.dependency 'BlocksKit/DynamicDelegate'
    ss.ios.dependency 'BlocksKit/MessageUI'
    ss.ios.dependency 'BlocksKit/QuickLook'
    ss.ios.dependency 'BlocksKit/UIKit'
  end

  s.subspec 'All_AppExtension' do |ss|
    ss.dependency 'BlocksKit/Core'
    ss.dependency 'BlocksKit/DynamicDelegate'
    ss.ios.dependency 'BlocksKit/MessageUI'
    ss.ios.dependency 'BlocksKit/QuickLook'
    ss.ios.dependency 'BlocksKit/UIKit_AppExtension'
  end

  s.subspec 'Core' do |ss|
    ss.source_files = 'BlocksKit/BlocksKit.h', "BlocksKit/BKDefines.h", 'BlocksKit/Core/*.{h,m}'
  end

  s.subspec 'DynamicDelegate' do |ss|
    ss.source_files = 'BlocksKit/DynamicDelegate/*.{h,m}', 'BlocksKit/DynamicDelegate/Foundation/*.{h,m}'
  end

  s.subspec 'MessageUI' do |ss|
    ss.dependency 'BlocksKit/Core'
    ss.dependency 'BlocksKit/DynamicDelegate'
    ss.platform = :ios
    ss.source_files = 'BlocksKit/BlocksKit+MessageUI.h', 'BlocksKit/MessageUI/*.{h,m}'
    ss.ios.frameworks = 'MessageUI'
  end

  s.subspec 'QuickLook' do |ss|
    ss.dependency 'BlocksKit/Core'
    ss.dependency 'BlocksKit/DynamicDelegate'
    ss.platform = :ios
    ss.source_files = 'BlocksKit/BlocksKit+QuickLook.h', 'BlocksKit/QuickLook/*.{h,m}'
    ss.ios.frameworks = 'QuickLook'
  end

  s.subspec 'UIKit' do |ss|
    ss.dependency 'BlocksKit/Core'
    ss.dependency 'BlocksKit/DynamicDelegate'
    ss.platform = :ios
    ss.source_files = 'BlocksKit/BlocksKit+UIKit.h', 'BlocksKit/UIKit/*.{h,m}'
    ss.exclude_files = 'BlocksKit/UIKit/UIWebView+BlocksKit.{h,m}'
  end

  s.subspec 'UIKit_AppExtension' do |ss|
    ss.dependency 'BlocksKit/Core'
    ss.dependency 'BlocksKit/DynamicDelegate'
    ss.platform = :ios
    ss.source_files = 'BlocksKit/BlocksKit+UIKit_AppExtension.h', 'BlocksKit/UIKit/*.{h,m}'
    ss.exclude_files = 'BlocksKit/UIKit/UIActionSheet+BlocksKit.{h,m}', 'BlocksKit/UIKit/UIAlertView+BlocksKit.{h,m}','BlocksKit/UIKit/UIWebView+BlocksKit.{h,m}'
  end

end
