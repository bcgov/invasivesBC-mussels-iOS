# Uncomment the next line to define a global platform for your project
platform :ios, '11.0'

# This is used to allow the CI build to work. The pod(s) are
# signed with the credentials / profile provided and xcodebuild
# is not happy with this. If you Pods are check in to SCM, and not
# updated by the CI build process then you may not need this.
post_install do |installer|
    installer.pods_project.targets.each do |target|
        target.build_configurations.each do |config|
            config.build_settings['EXPANDED_CODE_SIGN_IDENTITY'] = "-"
            config.build_settings['EXPANDED_CODE_SIGN_IDENTITY_NAME'] = "-"
            config.build_settings['CODE_SIGNING_REQUIRED'] = "NO"
            config.build_settings['CODE_SIGNING_ALLOWED'] = "NO"
        end
    end
end

target 'ipad' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for ipad
  # Networking
  pod 'Alamofire'
  # Storage
  pod 'Realm'
  pod 'RealmSwift'
  # Animations
  pod 'lottie-ios'
  # Keybord manager
  pod 'IQKeyboardManagerSwift'
  # Reachability
  pod 'ReachabilitySwift'
  # Keycloack login
  pod 'SingleSignOn', :git => 'https://github.com/bcgov/mobile-authentication-ios.git', :tag => 'v1.0.6'
  # Extensions
  pod 'Extended'
  # Custom Modal
  pod 'Modal'
  # Datepicker
  pod 'DatePicker'
  # JSON handler
  pod 'SwiftyJSON'
  # add pods for desired Firebase products
  # https://firebase.google.com/docs/ios/setup#available-pods
  pod 'Firebase/Analytics'
  pod 'Fabric'
  pod 'Crashlytics'
  target 'ipadTests' do
    inherit! :search_paths
    # Pods for testing
  end

end
