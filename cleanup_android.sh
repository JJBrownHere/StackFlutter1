#!/bin/bash

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}=== Starting Android Cleanup ===${NC}"

# Store the original directory
ORIGINAL_DIR=$(pwd)

# Function to show progress
show_progress() {
    echo -e "\033[1;34m$1\033[0m"
}

# Function to handle process termination
handle_exit() {
    show_progress "\nCleaning up processes..."
    pkill -f gradle
    pkill -f flutter
    exit 1
}

# Set up trap for process termination
trap handle_exit SIGINT SIGTERM

# Function to safely remove a directory with multiple attempts
safe_remove_dir() {
    local dir=$1
    if [ -d "$dir" ]; then
        show_progress "Attempting to remove $dir..."
        
        # First attempt: Normal removal
        rm -rf "$dir" 2>/dev/null
        
        # Second attempt: Stop Gradle daemon and try again
        if [ -d "$dir" ]; then
            show_progress "Stopping Gradle daemon and retrying..."
            ./gradlew --stop
            rm -rf "$dir" 2>/dev/null
        fi
        
        # Third attempt: Fix permissions and try again
        if [ -d "$dir" ]; then
            show_progress "Fixing permissions and retrying..."
            chmod -R 777 "$dir"
            rm -rf "$dir" 2>/dev/null
        fi
        
        # Fourth attempt: Force removal with sudo if needed
        if [ -d "$dir" ]; then
            show_progress "Attempting force removal..."
            sudo rm -rf "$dir" 2>/dev/null
        fi
        
        # Final verification
        if [ -d "$dir" ]; then
            show_progress "Warning: Could not remove $dir"
            ls -la "$dir"
            return 1
        else
            show_progress "Successfully removed $dir"
            return 0
        fi
    fi
    return 0
}

# Change to Flutter project directory
cd FProjects/BuyBackTools || {
    show_progress "Error: Could not change to Flutter project directory"
    exit 1
}

# Verify we're in the correct directory
if [ ! -f "lib/main.dart" ]; then
    show_progress "Error: lib/main.dart not found. Please run this script from the project root."
    exit 1
fi

show_progress "Starting cleanup process..."
show_progress "Working directory: $(pwd)"

# Kill any running Flutter or Gradle processes
show_progress "Stopping any running Flutter or Gradle processes..."
pkill -f gradle
pkill -f flutter

# Clean Flutter
show_progress "Cleaning Flutter..."
flutter clean --verbose

# Clean specific directories
show_progress "Cleaning build directories..."
safe_remove_dir "build"
safe_remove_dir ".dart_tool"
safe_remove_dir "android/.gradle"
safe_remove_dir "android/build"
safe_remove_dir "android/app/build"
safe_remove_dir "build/app_links"
safe_remove_dir "build/url_launcher_android"

# Clean Gradle
show_progress "Cleaning Gradle..."
cd android
./gradlew clean --info --stacktrace
cd ..

# Special handling for .gradle directory
if [ -d "android/.gradle" ]; then
    show_progress "Performing special cleanup for .gradle directory..."
    cd android
    ./gradlew --stop
    cd ..
    chmod -R 777 android/.gradle
    sudo rm -rf android/.gradle
fi

# Verify cleanup
show_progress "\nVerifying cleanup..."
for dir in "build" ".dart_tool" "android/.gradle" "android/build" "android/app/build" "build/app_links" "build/url_launcher_android"; do
    if [ -d "$dir" ]; then
        show_progress "Directory still exists: $dir"
        show_progress "Contents:"
        ls -la "$dir"
        show_progress "Warning: The following directories could not be cleaned:"
        show_progress "$dir"
        show_progress "You may need to manually remove these directories"
    fi
done

show_progress "\n=== Cleanup Complete ==="

# Return to original directory
cd "$ORIGINAL_DIR"

echo -e "\n${GREEN}=== Cleanup Complete ===${NC}" 