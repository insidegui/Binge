Pod::Spec.new do |s|
  s.name             = 'BingeUI'
  s.version          = '1.0.0'
  s.summary          = 'UI components for Binge'
  s.license          = 'BSD'
  s.author           = { 'Guilherme Rambo' => 'eu@guilhermerambo.me' }
  s.source           = { :path => '.' }
  s.homepage         = 'https://twitter.com/_inside'
  s.social_media_url = 'https://twitter.com/_inside'
  s.requires_arc     = true
  
  s.dependency 'RxSwift'
  s.dependency 'RxCocoa'
  
  s.osx.deployment_target = '10.11'
  s.ios.deployment_target = '9.3'

  s.source_files = 'BingeUI/*.{swift}'
end
