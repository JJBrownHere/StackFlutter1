#!/bin/bash

# Create flavor-specific xcconfig files
cat > Flutter/Development.xcconfig << EOL
#include "Debug.xcconfig"
FLUTTER_FLAVOR=development
PRODUCT_BUNDLE_IDENTIFIER=com.example.stacks.dev
DISPLAY_NAME=Stacks Dev
EOL

cat > Flutter/Production.xcconfig << EOL
#include "Release.xcconfig"
FLUTTER_FLAVOR=production
PRODUCT_BUNDLE_IDENTIFIER=com.example.stacks
DISPLAY_NAME=Stacks
EOL

# Create schemes using xcodebuild
echo "Creating development scheme..."
xcodebuild -scheme Runner -configuration Debug-development -workspace Runner.xcworkspace -derivedDataPath build/ios
xcodebuild -scheme Runner -configuration Release-development -workspace Runner.xcworkspace -derivedDataPath build/ios

echo "Creating production scheme..."
xcodebuild -scheme Runner -configuration Debug-production -workspace Runner.xcworkspace -derivedDataPath build/ios
xcodebuild -scheme Runner -configuration Release-production -workspace Runner.xcworkspace -derivedDataPath build/ios

# Update Xcode project configurations
/usr/libexec/PlistBuddy -c "Add :buildConfigurations:Debug-development dict" Runner.xcodeproj/project.pbxproj
/usr/libexec/PlistBuddy -c "Add :buildConfigurations:Debug-production dict" Runner.xcodeproj/project.pbxproj
/usr/libexec/PlistBuddy -c "Add :buildConfigurations:Release-development dict" Runner.xcodeproj/project.pbxproj
/usr/libexec/PlistBuddy -c "Add :buildConfigurations:Release-production dict" Runner.xcodeproj/project.pbxproj
/usr/libexec/PlistBuddy -c "Add :buildConfigurations:Profile-development dict" Runner.xcodeproj/project.pbxproj
/usr/libexec/PlistBuddy -c "Add :buildConfigurations:Profile-production dict" Runner.xcodeproj/project.pbxproj

# Create shared schemes
mkdir -p Runner.xcodeproj/xcshareddata/xcschemes/

# Create development scheme
cat > Runner.xcodeproj/xcshareddata/xcschemes/development.xcscheme << EOL
<?xml version="1.0" encoding="UTF-8"?>
<Scheme LastUpgradeVersion="1500" version="1.7">
   <BuildAction parallelizeBuildables="YES" buildImplicitDependencies="YES">
      <BuildActionEntries>
         <BuildActionEntry buildForTesting="YES" buildForRunning="YES" buildForProfiling="YES" buildForArchiving="YES" buildForAnalyzing="YES">
            <BuildableReference BuildableIdentifier="primary" BlueprintIdentifier="97C146ED1CF9000F007C117D" BuildableName="Runner.app" BlueprintName="Runner" ReferencedContainer="container:Runner.xcodeproj"/>
         </BuildActionEntry>
      </BuildActionEntries>
   </BuildAction>
   <TestAction buildConfiguration="Debug-development" selectedDebuggerIdentifier="Xcode.DebuggerFoundation.Debugger.LLDB" selectedLauncherIdentifier="Xcode.DebuggerFoundation.Launcher.LLDB" shouldUseLaunchSchemeArgsEnv="YES">
      <Testables></Testables>
   </TestAction>
   <LaunchAction buildConfiguration="Debug-development" selectedDebuggerIdentifier="Xcode.DebuggerFoundation.Debugger.LLDB" selectedLauncherIdentifier="Xcode.DebuggerFoundation.Launcher.LLDB" launchStyle="0" useCustomWorkingDirectory="NO" ignoresPersistentStateOnLaunch="NO" debugDocumentVersioning="YES" debugServiceExtension="internal" allowLocationSimulation="YES">
      <BuildableProductRunnable runnableDebuggingMode="0">
         <BuildableReference BuildableIdentifier="primary" BlueprintIdentifier="97C146ED1CF9000F007C117D" BuildableName="Runner.app" BlueprintName="Runner" ReferencedContainer="container:Runner.xcodeproj"/>
      </BuildableProductRunnable>
   </LaunchAction>
   <ProfileAction buildConfiguration="Profile-development" shouldUseLaunchSchemeArgsEnv="YES" savedToolIdentifier="" useCustomWorkingDirectory="NO" debugDocumentVersioning="YES">
      <BuildableProductRunnable runnableDebuggingMode="0">
         <BuildableReference BuildableIdentifier="primary" BlueprintIdentifier="97C146ED1CF9000F007C117D" BuildableName="Runner.app" BlueprintName="Runner" ReferencedContainer="container:Runner.xcodeproj"/>
      </BuildableProductRunnable>
   </ProfileAction>
   <AnalyzeAction buildConfiguration="Debug-development"/>
   <ArchiveAction buildConfiguration="Release-development" revealArchiveInOrganizer="YES"/>
</Scheme>
EOL

# Create production scheme
cat > Runner.xcodeproj/xcshareddata/xcschemes/production.xcscheme << EOL
<?xml version="1.0" encoding="UTF-8"?>
<Scheme LastUpgradeVersion="1500" version="1.7">
   <BuildAction parallelizeBuildables="YES" buildImplicitDependencies="YES">
      <BuildActionEntries>
         <BuildActionEntry buildForTesting="YES" buildForRunning="YES" buildForProfiling="YES" buildForArchiving="YES" buildForAnalyzing="YES">
            <BuildableReference BuildableIdentifier="primary" BlueprintIdentifier="97C146ED1CF9000F007C117D" BuildableName="Runner.app" BlueprintName="Runner" ReferencedContainer="container:Runner.xcodeproj"/>
         </BuildActionEntry>
      </BuildActionEntries>
   </BuildAction>
   <TestAction buildConfiguration="Debug-production" selectedDebuggerIdentifier="Xcode.DebuggerFoundation.Debugger.LLDB" selectedLauncherIdentifier="Xcode.DebuggerFoundation.Launcher.LLDB" shouldUseLaunchSchemeArgsEnv="YES">
      <Testables></Testables>
   </TestAction>
   <LaunchAction buildConfiguration="Debug-production" selectedDebuggerIdentifier="Xcode.DebuggerFoundation.Debugger.LLDB" selectedLauncherIdentifier="Xcode.DebuggerFoundation.Launcher.LLDB" launchStyle="0" useCustomWorkingDirectory="NO" ignoresPersistentStateOnLaunch="NO" debugDocumentVersioning="YES" debugServiceExtension="internal" allowLocationSimulation="YES">
      <BuildableProductRunnable runnableDebuggingMode="0">
         <BuildableReference BuildableIdentifier="primary" BlueprintIdentifier="97C146ED1CF9000F007C117D" BuildableName="Runner.app" BlueprintName="Runner" ReferencedContainer="container:Runner.xcodeproj"/>
      </BuildableProductRunnable>
   </LaunchAction>
   <ProfileAction buildConfiguration="Profile-production" shouldUseLaunchSchemeArgsEnv="YES" savedToolIdentifier="" useCustomWorkingDirectory="NO" debugDocumentVersioning="YES">
      <BuildableProductRunnable runnableDebuggingMode="0">
         <BuildableReference BuildableIdentifier="primary" BlueprintIdentifier="97C146ED1CF9000F007C117D" BuildableName="Runner.app" BlueprintName="Runner" ReferencedContainer="container:Runner.xcodeproj"/>
      </BuildableProductRunnable>
   </ProfileAction>
   <AnalyzeAction buildConfiguration="Debug-production"/>
   <ArchiveAction buildConfiguration="Release-production" revealArchiveInOrganizer="YES"/>
</Scheme>
EOL

# Run pod install to update configurations
pod install

echo "Flavor configurations and schemes have been set up. You can now use:"
echo "flutter run --flavor development"
echo "flutter run --flavor production" 