#
# Be sure to run `pod lib lint HTN.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'HTN'
  s.version          = '0.1.0'
  s.summary          = 'HTML to Native like swift and objective-c'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
                        HTML to Native like swift and objective-c.
                       DESC

  s.homepage         = 'https://github.com/ming1016/HTN'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'daiming' => 'daiming@didichuxing.com' }
  s.source           = { :git => 'https://github.com/ming1016/HTN.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.osx.deployment_target = '10.10'
  s.requires_arc = true
  s.swift_version = '4.0'
  s.pod_target_xcconfig = { 'SWIFT_VERSION' => '4.0'}

  # s.resource_bundles = {
  #   'HTNSwift' => ['HTNSwift/Assets/*.png']
  # }
  # s.dependency 'Alamofire', '~> 4.7'

  # Core
  s.subspec 'Core' do |core|
    core.source_files = 'Sources/Core/**/*'
  end

  # H5Editor
  s.subspec 'H5Editor' do |h5Editor|
    h5Editor.source_files = 'Sources/H5Editor/**/*'
    h5Editor.dependency 'HTN/Core'
  end
end