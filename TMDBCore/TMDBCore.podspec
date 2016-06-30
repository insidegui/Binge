Pod::Spec.new do |s|
  s.name             = 'TMDBCore'
  s.version          = '1.0.0'
  s.summary          = 'API Client for The Movies Database'
  s.license          = 'BSD'
  s.author           = { 'Guilherme Rambo' => 'eu@guilhermerambo.me' }
  s.source           = { :path => '.' }
  s.homepage         = 'https://twitter.com/_inside'
  s.social_media_url = 'https://twitter.com/_inside'
  s.requires_arc     = true
  
  s.dependency 'SwiftyJSON'
  s.dependency 'Alamofire', '~> 3.4'
  
  s.osx.deployment_target = '10.11'
  s.ios.deployment_target = '9.3'

  s.source_files = 'TMDBCore/*.{swift}'
end
