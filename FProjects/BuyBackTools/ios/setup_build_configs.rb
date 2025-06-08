#!/usr/bin/env ruby
require 'xcodeproj'

# Open the Xcode project
project_path = 'Runner.xcodeproj'
project = Xcodeproj::Project.open(project_path)

# Get the main target
target = project.targets.first

# Base configurations to duplicate
base_configs = {
  'Debug' => :debug,
  'Release' => :release,
  'Profile' => :release
}

# Create configurations for each flavor
['development', 'production'].each do |flavor|
  base_configs.each do |base_name, build_type|
    config_name = "#{base_name}-#{flavor}"
    
    # Skip if configuration already exists
    next if project.build_configurations.any? { |config| config.name == config_name }
    
    # Find the base configuration
    base_config = project.build_configurations.find { |config| config.name == base_name }
    next unless base_config
    
    # Create new configuration
    new_config = project.add_build_configuration(config_name, build_type)
    new_config.base_configuration_reference = base_config.base_configuration_reference
    
    # Copy build settings
    new_config.build_settings.merge!(base_config.build_settings)
    
    # Add flavor-specific settings
    new_config.build_settings['PRODUCT_BUNDLE_IDENTIFIER'] = flavor == 'development' ? 
      'com.example.stacks.dev' : 'com.example.stacks'
    new_config.build_settings['FLUTTER_FLAVOR'] = flavor
    new_config.build_settings['INFOPLIST_FILE'] = '$(SRCROOT)/Runner/Info.plist'
    new_config.build_settings['GENERATE_INFOPLIST_FILE'] = 'NO'
    
    # Add settings to handle resource fork issues
    new_config.build_settings['OTHER_CODE_SIGN_FLAGS'] = '--deep'
    new_config.build_settings['CODE_SIGN_ALLOW_ENTITLEMENTS_MODIFICATION'] = 'YES'
  end
end

# Update all configurations in the project
project.build_configurations.each do |config|
  config.build_settings['INFOPLIST_FILE'] = '$(SRCROOT)/Runner/Info.plist'
  config.build_settings['GENERATE_INFOPLIST_FILE'] = 'NO'
  config.build_settings['OTHER_CODE_SIGN_FLAGS'] = '--deep'
  config.build_settings['CODE_SIGN_ALLOW_ENTITLEMENTS_MODIFICATION'] = 'YES'
end

# Update target build configurations
target.build_configurations.each do |config|
  # Ensure Info.plist is set for all configurations
  config.build_settings['INFOPLIST_FILE'] = '$(SRCROOT)/Runner/Info.plist'
  config.build_settings['GENERATE_INFOPLIST_FILE'] = 'NO'
  config.build_settings['OTHER_CODE_SIGN_FLAGS'] = '--deep'
  config.build_settings['CODE_SIGN_ALLOW_ENTITLEMENTS_MODIFICATION'] = 'YES'
  
  if config.name.include?('development')
    config.build_settings['PRODUCT_BUNDLE_IDENTIFIER'] = 'com.example.stacks.dev'
    config.build_settings['FLUTTER_FLAVOR'] = 'development'
  elsif config.name.include?('production')
    config.build_settings['PRODUCT_BUNDLE_IDENTIFIER'] = 'com.example.stacks'
    config.build_settings['FLUTTER_FLAVOR'] = 'production'
  end
end

# Save the project
project.save

puts "Build configurations have been updated successfully!"
