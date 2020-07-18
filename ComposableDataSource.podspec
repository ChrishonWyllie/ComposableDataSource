#
# Be sure to run `pod lib lint ComposableDataSource.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'ComposableDataSource'
  s.version          = '0.5.9'
  s.summary          = 'A more contained and composable method of creating scrollView datasources'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
  ComposableDataSource was written to assuage to usually annoying task of writing UICollectionView delegate and datasource code. Now, this functionality can be encapsulated in one function
                       DESC

  s.homepage         = 'https://github.com/ChrishonWyllie/ComposableDataSource'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'ChrishonWyllie' => 'chrishon595@yahoo.com' }
  s.source           = { :git => 'https://github.com/ChrishonWyllie/ComposableDataSource.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'
  s.swift_versions   = ['4.0', '4.1', '4.2', '5.0', '5.1']

  s.ios.deployment_target = '11.0'

  s.source_files = 'Classes/**/*'
  
  # s.resource_bundles = {
  #   'ComposableDataSource' => ['ComposableDataSource/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
   s.frameworks = 'UIKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end
