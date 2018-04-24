#
# Be sure to run `pod lib lint SkyBoxUI.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'SkyBoxUI'
  s.version          = '0.3.67'
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
  s.requires_arc = true

  s.source_files = 'SkyBoxUI/Classes/**/*'
  s.source_files = 'SkyBoxUI/Classes/**/**/*.{h,m,mm}'

  s.resource_bundles = {
    'SkyBoxUI' => ['SkyBoxUI/Assets/*.{png,pdf,mp4}', 'SkyBoxUI/Assets/**/*.{png,pdf}', 'SkyBoxUI/Assets/**/*.ttf', 'SkyBoxUI/Classes/**/**/*.{storyboard,xib}']
  }

#s.user_target_xcconfig =   {'OTHER_LDFLAGS' => ['-lObjC','-all_load'], 'HEADER_SEARCH_PATHS' => ['${PODS_ROOT}/Headers/Private', '${PODS_ROOT}/Headers/Public']}
#s.resource_bundles = {
#'SkyBoxUI' => ['SkyBoxUI/Assets/*.png']
#'SkyBoxUI' => ['SkyBoxUI/Classes/**/*.xib']
#}

  # s.public_header_files = 'Pod/Classes/**/*.h'
  s.frameworks = "UIKit", "Foundation", "AVFoundation"
# s.libraries = "iconv", "xml2"
  s.libraries = "sqlite3.0", "xml2"

  s.xcconfig = { 'HEADER_SEARCH_PATHS' => '/usr/include/libxml2' }

    s.dependency 'AFNetworking', '~> 3.1.0'
    s.dependency 'MJExtension', '~> 3.0.13'
    s.dependency 'SDWebImage', '~> 4.2.2'
    s.dependency 'Masonry', '~> 1.1.0'
    s.dependency 'MBProgressHUD', '~> 1.0.0'
    s.dependency 'MBProgressHUD+Add', '~> 0.0.2'
    s.dependency 'FMDB', '~> 2.7.2'
    s.dependency 'MMDrawerController', '~> 0.6.0'
    s.dependency 'YHPDFImageLoader', '~> 1.0.0'
    s.dependency 'KissXML', '~> 5.2.0'

  s.pod_target_xcconfig = { 'SWIFT_VERSION' => '4.0' }

  s.prefix_header_contents = <<-EOS
    #ifdef __OBJC__
        #import "SPHighlightedButton.h"
        #import "SPDLANManager.h"
        #import "SPAirScreenManager.h"
        #import "SPDataManager.h"
        #import "UIColor+SPImage.h"
        #import "SPNavigationBar.h"
        #import "SPSwitchBar.h"
        #import "SPDeviceUtil.h"
        #import "UIResponder+SPCategory.h"
        #import "SPSingle.h"
        #import "Commons.h"
        #import "JRTTFTool.h"
        #import "SPColorUtil.h"
        #import <Masonry/Masonry.h>
        #import "MBProgressHUD.h"
        #import "SPBaseViewController.h"
        #import "ServiceCall.h"
        #import <MJExtension/MJExtension.h>
        #import <AFNetworking/AFNetworking.h>
    #endif /* __OBJC__*/
  EOS

end
