#!/usr/bin/env ruby
require 'xcodeproj'

project_path = 'Runner.xcodeproj'
project = Xcodeproj::Project.open(project_path)

# Get the main target
target = project.targets.first

# Create schemes directory if it doesn't exist
schemes_dir = "#{project_path}/xcshareddata/xcschemes"
Dir.mkdir("#{project_path}/xcshareddata") unless Dir.exist?("#{project_path}/xcshareddata")
Dir.mkdir(schemes_dir) unless Dir.exist?(schemes_dir)

# Create schemes for each flavor
['development', 'production'].each do |flavor|
  scheme_path = "#{schemes_dir}/Runner-#{flavor}.xcscheme"
  
  # Create scheme content
  scheme_content = %{<?xml version="1.0" encoding="UTF-8"?>
<Scheme LastUpgradeVersion="1500" version="1.7">
   <BuildAction parallelizeBuildables="YES" buildImplicitDependencies="YES">
      <BuildActionEntries>
         <BuildActionEntry buildForTesting="YES" buildForRunning="YES" buildForProfiling="YES" buildForArchiving="YES" buildForAnalyzing="YES">
            <BuildableReference BuildableIdentifier="primary" BlueprintIdentifier="#{target.uuid}" BuildableName="Runner.app" BlueprintName="#{target.name}" ReferencedContainer="container:#{project_path}"/>
         </BuildActionEntry>
      </BuildActionEntries>
   </BuildAction>
   <TestAction buildConfiguration="Debug-#{flavor}" selectedDebuggerIdentifier="Xcode.DebuggerFoundation.Debugger.LLDB" selectedLauncherIdentifier="Xcode.DebuggerFoundation.Launcher.LLDB" shouldUseLaunchSchemeArgsEnv="YES">
      <Testables></Testables>
   </TestAction>
   <LaunchAction buildConfiguration="Debug-#{flavor}" selectedDebuggerIdentifier="Xcode.DebuggerFoundation.Debugger.LLDB" selectedLauncherIdentifier="Xcode.DebuggerFoundation.Launcher.LLDB" launchStyle="0" useCustomWorkingDirectory="NO" ignoresPersistentStateOnLaunch="NO" debugDocumentVersioning="YES" debugServiceExtension="internal" allowLocationSimulation="YES">
      <BuildableProductRunnable runnableDebuggingMode="0">
         <BuildableReference BuildableIdentifier="primary" BlueprintIdentifier="#{target.uuid}" BuildableName="Runner.app" BlueprintName="#{target.name}" ReferencedContainer="container:#{project_path}"/>
      </BuildableProductRunnable>
   </LaunchAction>
   <ProfileAction buildConfiguration="Profile-#{flavor}" shouldUseLaunchSchemeArgsEnv="YES" savedToolIdentifier="" useCustomWorkingDirectory="NO" debugDocumentVersioning="YES">
      <BuildableProductRunnable runnableDebuggingMode="0">
         <BuildableReference BuildableIdentifier="primary" BlueprintIdentifier="#{target.uuid}" BuildableName="Runner.app" BlueprintName="#{target.name}" ReferencedContainer="container:#{project_path}"/>
      </BuildableProductRunnable>
   </ProfileAction>
   <AnalyzeAction buildConfiguration="Debug-#{flavor}"/>
   <ArchiveAction buildConfiguration="Release-#{flavor}" revealArchiveInOrganizer="YES"/>
</Scheme>}
  
  # Write scheme to file
  File.write(scheme_path, scheme_content)
end

puts "Schemes have been created successfully!" 