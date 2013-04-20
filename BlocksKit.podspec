Pod::Spec.new do |s|
  s.name                  = 'BlocksKit'
  s.version               = '1.8.2'
  s.license               = 'MIT'
  s.summary               = 'The Objective-C block utilities you always wish you had.'
  s.homepage              = 'https://github.com/pandamonia/BlocksKit'
  s.author                = { 'Zachary Waldowski' => 'zwaldowski@gmail.com',
                              'Alexsander Akers' => 'a2@pandamonia.us' }
  s.source                = { :git => 'https://github.com/pandamonia/BlocksKit.git', :tag => "v#{s.version}" }
  s.requires_arc          = true
  s.osx.source_files      = 'BlocksKit/*.{h,m}'
  s.osx.library           = 'ffi'
  s.osx.deployment_target = '10.7'
  s.ios.dependency          'libffi'
  s.ios.frameworks        = 'MessageUI'
  s.ios.source_files      = 'BlocksKit/*.{h,m}', 'BlocksKit/UIKit/*.{h,m}', 'BlocksKit/MessageUI/*.{h,m}'
  s.ios.deployment_target = '5.0'
  s.documentation         = {
    :html => 'http://pandamonia.github.com/BlocksKit/Documentation/index.html',
    :appledoc => [
      '--project-company', 'Pandamonia LLC',
      '--company-id', 'us.pandamonia',
      '--no-repeat-first-par',
      '--no-warn-invalid-crossref'
    ]
  }
end
