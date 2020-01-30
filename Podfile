# Check out link below to add dependencies to different project on a workspace.
# https://medium.com/@youvalv/cocoapods-for-an-existing-multi-project-workspace-1fb73f46fede

# When a workspace is already created. This specifies to use that workspace
workspace 'DEUCE'


# Uncomment the next line to define a global platform for your project
 platform :ios, '12.0'

target 'RealTimeAzure' do
  project 'RealTimeAzure/RealTimeAzure.xcodeproj'

  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for RealTimeAzure
  pod 'SignalRSwift'

  target 'RealTimeAzureTests' do
    # Pods for testing
  end

end

# NOTE: You need to add all dependencies from other frameworks/projects on the main 'DEUCEApp' in order to make the application run. Otherwise it'll crash although it compiles correctly.
# https://medium.com/@akfreas/how-to-use-cocoapods-with-your-internal-ios-frameworks-192aa472f64b

target 'DEUCEApp' do
  project 'DEUCEApp/DEUCEApp.xcodeproj'
  
  use_frameworks!

  # Pods for RealTimeAzure
  pod 'SignalRSwift'
  
  target 'DEUCEAppTests' do
    # Pods for testing
  end

end
