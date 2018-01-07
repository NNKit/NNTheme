#
# Be sure to run `pod lib lint NNTheme.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'NNTheme'
  s.version          = '0.0.1'
  s.summary          = 'a theme framework.'
  s.homepage         = 'https://github.com/NNKit/NNTheme'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'ws00801526' => '3057600441@qq.com' }
  s.source           = { :git => 'https://github.com/NNKit/NNTheme.git', :tag => s.version.to_s }
  s.ios.deployment_target = '8.0'
  s.source_files = 'NNTheme/Classes/**/*'
  s.public_header_files = 'NNTheme/Classes/**/NNTheme.h', 'NNTheme/Classes/**/NNThemeHelper.h'
  s.private_header_files = 'NNTheme/Classes/**/NNTheme_Private.h'
  s.dependency 'NNCore'
end
