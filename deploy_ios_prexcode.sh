#!/bin/bash

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print section headers
print_header() {
    echo -e "\n${BLUE}=== $1 ===${NC}\n"
}

# Function to print status messages
print_status() {
    echo -e "${YELLOW}$1${NC}"
}

# Function to print success messages
print_success() {
    echo -e "${GREEN}$1${NC}"
}

# Function to print error messages
print_error() {
    echo -e "${RED}$1${NC}"
}

# Function to check command status
check_status() {
    if [ $? -ne 0 ]; then
        print_error "Failed: $1"
        exit 1
    fi
}

# Start deployment
print_header "Starting iOS Pre-Xcode Setup"

# Store the root directory
ROOT_DIR=$(pwd)
print_status "Working directory: $ROOT_DIR"

# Check if we're in the right directory
if [ ! -d "FProjects/BuyBackTools" ]; then
    print_error "Please run this script from the project root directory"
    exit 1
fi

# Navigate to the Flutter project
print_status "Navigating to Flutter project..."
cd FProjects/BuyBackTools
check_status "Failed to navigate to Flutter project directory"

# Clean iOS build artifacts first
print_header "Cleaning iOS Build"
print_status "Cleaning iOS build artifacts..."
rm -rf ios/Pods ios/Podfile.lock ios/.symlinks ios/build ios/Runner.xcworkspace
print_success "iOS build artifacts cleaned"

# Clean Flutter project with timeout
print_header "Cleaning Flutter Project"
print_status "Running flutter clean (with 30s timeout)..."
timeout 30 flutter clean || {
    print_status "Flutter clean timed out, continuing with build..."
}
print_success "Flutter project cleaned"

# Get dependencies
print_header "Getting Dependencies"
print_status "Running flutter pub get..."
flutter pub get
check_status "Failed to get dependencies"

# Check for outdated packages
print_status "Checking for outdated packages..."
flutter pub outdated
print_success "Dependency check complete"

# Install pods
print_header "Installing CocoaPods Dependencies"
print_status "Running pod install..."
cd ios
check_status "Failed to navigate to iOS directory"

pod install
check_status "Failed to install pods"

# Open Xcode
print_header "Opening Xcode"
print_status "Opening Xcode workspace..."
open Runner.xcworkspace
check_status "Failed to open Xcode workspace"

print_success "iOS setup completed successfully!"
print_status "Xcode workspace is now open. You can build and run the app from Xcode." 