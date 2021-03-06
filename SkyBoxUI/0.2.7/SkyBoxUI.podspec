#
# Be sure to run `pod lib lint SkyBoxUI.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'SkyBoxUI'
  s.version          = '0.2.7'
  s.summary          = 'SkyBoxUI UI 插件'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
SkyBoxUI 使用cocoapods 管理的 UI插件
                       DESC

  s.homepage         = 'https://github.com/appleMini/SkyBoxUI'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'appleMini' => 's1298web@163.com' }
  s.source           = { :git => 'https://github.com/appleMini/SkyBoxUI.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '9.0'

  s.source_files = 'SkyBoxUI/Classes/**/*'
  s.source_files = 'SkyBoxUI/Classes/**/**/*.{h,m}'
  
  # s.resource_bundles = {
  #   'SkyBoxUI' => ['SkyBoxUI/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  s.frameworks = "UIKit", "Foundation"
# s.libraries = "iconv", "xml2"
  s.dependency 'AFNetworking', '~> 3.1.0'
  s.dependency 'MJExtension', '~> 3.0.13'
  s.dependency 'SDWebImage', '~> 4.2.2'
  s.dependency 'Masonry', '~> 1.1.0'
  s.dependency 'MBProgressHUD', '~> 1.1.0'

  s.prefix_header_contents = <<-EOS
    #ifdef __OBJC__
        #import "UIResponder+SPCategory.h"
        #import "Commons.h"
        #import "SPColorUtil.h"
        #import <Masonry/Masonry.h>
        #import "MBProgressHUD.h"
    #endif /* __OBJC__*/
  EOS

end
