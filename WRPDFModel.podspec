#
# Be sure to run `pod lib lint WRPDFModel.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'WRPDFModel'
  s.version          = '0.0.1'
  s.summary          = '解析并获取PDF模型.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = "解析PDF数据，并将解析的数据作为模型"

  s.homepage         = 'https://github.com/GodFighter/WRPDFModel'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'GodFighter' => '{xianghui_ios@163.com}' }
  s.source           = { :git => 'https://github.com/GodFighter/WRPDFModel.git', :tag => s.version.to_s }
  s.social_media_url = 'http://weibo.com/huigedang/home?wvr=5&lf=reg'

  s.ios.deployment_target = '9.0'

  s.source_files = 'WRPDFModel/Classes/*.swift'
  
  # s.resource_bundles = {
  #   'WRPDFModel' => ['WRPDFModel/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end
