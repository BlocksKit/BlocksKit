Pod::Spec.new do |s|
  s.name     = 'BlocksKit'
  s.version  = '1.8'
  s.license  = 'MIT'
  s.summary  = 'The Objective-C block utilities you always wish you had.'
  s.homepage = 'https://github.com/pandamonia/BlocksKit'
  s.author   = { 'Zachary Waldowski' => 'zwaldowski@gmail.com',
                 'Alexsander Akers' => 'a2@pandamonia.us' }
  s.source   = { :git => 'https://github.com/pandamonia/BlocksKit.git', :branch => 'next' }
  s.requires_arc     = true
  s.osx.source_files = 'BlocksKit/*.{h,m}'
  s.osx.library      = 'ffi'
  s.ios.dependency     'libffi'
  s.ios.frameworks   = 'MessageUI'
  s.ios.source_files = 'BlocksKit/*.{h,m}', 'BlocksKit/UIKit/*.{h,m}', 'BlocksKit/MessageUI/*.{h,m}'
  s.documentation = {
    :html => 'http://pandamonia.github.com/BlocksKit/Documentation/index.html',
    :appledoc => [
      '--project-company', 'Dizzy Technology',
      '--company-id', 'com.dizzytechnology',
      '--no-repeat-first-par',
      '--no-warn-invalid-crossref'
    ]
  }
end
