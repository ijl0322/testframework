Pod::Spec.new do |s|

  # 1
  s.platform = :ios
  s.ios.deployment_target = '8.0'
  s.name = "ls-ios-sdk"
  s.summary = "Littlstar SDK"
  s.requires_arc = true

  # 2
  s.version = "0.1.0"

  # 3
  s.license = { :type => "MIT", :file => "LICENSE" }

  # 4 - Replace with your name and e-mail address
  s.author = { "littlstar" => "support@littlstar.com" }

  # For example,
  # s.author = { "Joshua Greene" => "jrg.developer@gmail.com" }


  # 5 - Replace this URL with your own Github page's URL (from the address bar)
  s.homepage = "https://github.com/littlstar/ls-ios-sdk"

  # For example,
  # s.homepage = "https://github.com/JRG-Developer/RWPickFlavor"


  # 6 - Replace this URL with your own Git URL from "Quick Setup"
  s.source = { :path => "/Users/isabellee/Downloads/ls-ios-sdk-hd-UI"}

  # For example,
  # s.source = { :git => "https://github.com/JRG-Developer/RWPickFlavor.git", :tag => "#{s.version}"}

  s.framework = "UIKit"
  s.dependency 'lottie-ios', '2.1.3'

  # 8
  s.source_files = "ls-ios-sdk/**/*.{swift}"

  # 9
  s.resources = "ls-ios-sdk/**/*.{png,jpeg,jpg,storyboard,xib}"
end