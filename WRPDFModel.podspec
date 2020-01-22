#
# Be sure to run `pod lib lint WRPDFModel.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'WRPDFModel'
  s.version          = '1.0.0'
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
  
  s.subspec 'ContentParser' do |ss|
      ss.source_files = 'WRPDFModel/Classes/ContentParser/*.swift'
      ss.subspec 'result' do |ss|
          ss.source_files = 'WRPDFModel/Classes/ContentParser/result/*.swift'
      end

      ss.subspec 'pdf' do |ss|
          ss.source_files = 'WRPDFModel/Classes/ContentParser/pdf/*.swift'
          
          ss.subspec 'Container Types' do |sss|
              sss.source_files = 'WRPDFModel/Classes/ContentParser/pdf/Container Types/*.swift'
          end
          
          ss.subspec 'extensions' do |sss|
              sss.source_files = 'WRPDFModel/Classes/ContentParser/pdf/extensions/*.swift'
          end

          ss.subspec 'fonts' do |sss|
              sss.source_files = 'WRPDFModel/Classes/ContentParser/pdf/fonts/*.swift'
              sss.subspec 'CompositeFonts' do |ssss|
                  ssss.source_files = 'WRPDFModel/Classes/ContentParser/pdf/fonts/CompositeFonts/*.swift'
              end

              sss.subspec 'SimpleFonts' do |ssss|
                  ssss.source_files = 'WRPDFModel/Classes/ContentParser/pdf/fonts/SimpleFonts/*.swift'
                  ssss.subspec 'TrueTypeFontFile' do |sssss|
                      sssss.source_files = 'WRPDFModel/Classes/ContentParser/pdf/fonts/SimpleFonts/TrueTypeFontFile/*.swift'
                  end
              end
          end
      end
  end

  # s.resource_bundles = {
  #   'WRPDFModel' => ['WRPDFModel/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end
