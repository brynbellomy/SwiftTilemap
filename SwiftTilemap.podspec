

Pod::Spec.new do |s|
  s.name = 'SwiftTilemap'
  s.version = '0.0.1'
  s.license = 'WTFPL'
  s.summary = 'SpriteKit node behavior toolkit'
  s.authors = { 'bryn austin bellomy' => 'bryn.bellomy@gmail.com' }

  s.ios.deployment_target = '8.0'
  s.osx.deployment_target = '10.10'
  s.source_files = "Classes/**/*.{swift}"

  s.dependency 'LlamaKit'

  s.dependency 'Funky', '0.1.2'
  s.dependency 'SwiftyJSON'
  s.dependency 'SwiftLogger'
  s.dependency 'SwiftConfig'
  s.dependency 'BrynSwift'
  s.dependency 'JSTilemap'

  s.frameworks = ['SpriteKit']

  # s.homepage = 'https://github.com/Alamofire/Alamofire'
  # s.social_media_url = 'http://twitter.com/mattt'
  # s.source = { :git => 'https://github.com/brynbellomy/SwiftTilemap.git', :tag => '0.0.1' }
end