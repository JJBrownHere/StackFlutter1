#!/bin/bash

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Store the original directory and project directory
ORIGINAL_DIR=$(pwd)
PROJECT_DIR="$ORIGINAL_DIR/FProjects/BuyBackTools"

# Function to show progress
show_progress() {
    local current=$1
    local total=$2
    local percentage=$((current * 100 / total))
    printf "\r${YELLOW}Progress: %d%%${NC}" "$percentage"
}

# Function to show spinner with elapsed time and warnings
spinner() {
    local pid=$1
    local delay=0.1
    local spinstr='|/-\'
    local start_time=$(date +%s)
    local warning_shown=false
    
    while kill -0 $pid 2>/dev/null; do
        local temp=${spinstr#?}
        local elapsed=$(( $(date +%s) - start_time ))
        
        # Show warning after 60 seconds
        if [ $elapsed -gt 60 ] && [ "$warning_shown" = false ]; then
            echo -e "\n${YELLOW}Operation taking longer than usual... This is normal for first builds${NC}"
            warning_shown=true
        fi
        
        printf "\r${YELLOW}[%c] Running... (%ds)${NC}" "$spinstr" "$elapsed"
        local spinstr=$temp${spinstr%"$temp"}
        sleep $delay
    done
    printf "\r"
}

# Function to handle process termination
handle_termination() {
    local pid=$1
    local spinner_pid=$2
    local timeout=$3
    local operation=$4
    
    # Wait for process with timeout
    timeout $timeout tail --pid=$pid -f /dev/null > /dev/null 2>&1
    local status=$?
    
    if [ $status -eq 124 ]; then
        kill $pid 2>/dev/null
        kill $spinner_pid 2>/dev/null
        echo -e "\n${RED}${operation} timed out after ${timeout}s${NC}"
        return 1
    fi
    
    wait $pid
    local exit_code=$?
    kill $spinner_pid 2>/dev/null
    
    if [ $exit_code -ne 0 ]; then
        echo -e "\n${RED}${operation} failed with exit code ${exit_code}${NC}"
        return 1
    fi
    
    return 0
}

# Function to force remove directories
force_remove_dir() {
    local dir=$1
    if [ -d "$dir" ]; then
        echo -e "${YELLOW}Force removing $dir...${NC}"
        find "$dir" -type f -exec chmod 644 {} \;
        find "$dir" -type d -exec chmod 755 {} \;
        rm -rf "$dir" 2>/dev/null || true
    fi
}

# Function to verify Google Sign-In configuration
verify_google_config() {
    echo -e "\n${YELLOW}Verifying Google Sign-In configuration...${NC}"
    
    # Check for google-services.json
    if [ ! -f "$PROJECT_DIR/android/app/google-services.json" ]; then
        echo -e "${RED}Error: google-services.json not found in android/app/ directory${NC}"
        return 1
    fi
    
    # Check for required dependencies in build.gradle
    if ! grep -q "com.google.gms:google-services" "$PROJECT_DIR/android/build.gradle"; then
        echo -e "${RED}Error: Google Services plugin not found in project build.gradle${NC}"
        return 1
    fi
    
    if ! grep -q "com.google.android.gms:play-services-auth" "$PROJECT_DIR/android/app/build.gradle"; then
        echo -e "${RED}Error: Play Services Auth dependency not found in app build.gradle${NC}"
        return 1
    fi
    
    return 0
}

echo -e "${GREEN}=== Starting Android Deployment ===${NC}"

# Verify we're in the correct directory
if [ ! -f "$PROJECT_DIR/lib/main.dart" ]; then
    echo -e "${RED}Error: lib/main.dart not found in $PROJECT_DIR${NC}"
    exit 1
fi

echo -e "${GREEN}Working directory: $PROJECT_DIR${NC}"

# Verify Google Sign-In configuration
if ! verify_google_config; then
    echo -e "${RED}Google Sign-In configuration verification failed${NC}"
    exit 1
fi

# Thorough cleanup of Android build files
echo -e "\n${YELLOW}Performing thorough cleanup...${NC}"

# Clean Flutter
echo -e "${YELLOW}Cleaning Flutter...${NC}"
(cd "$PROJECT_DIR" && flutter clean)

# Force remove problematic directories
echo -e "${YELLOW}Force removing build directories...${NC}"
rm -rf "$PROJECT_DIR/build"
rm -rf "$PROJECT_DIR/.dart_tool"
rm -rf "$PROJECT_DIR/android/.gradle"
rm -rf "$PROJECT_DIR/android/build"
rm -rf "$PROJECT_DIR/android/app/build"
rm -rf "$PROJECT_DIR/build/app_links"
rm -rf "$PROJECT_DIR/build/url_launcher_android"

# Clean Gradle
echo -e "\n${YELLOW}Cleaning Gradle...${NC}"
(cd "$PROJECT_DIR/android" && ./gradlew clean --info --stacktrace)

show_progress 1 4

# Get dependencies
echo -e "\n${YELLOW}Getting dependencies...${NC}"
(cd "$PROJECT_DIR" && flutter pub get)

show_progress 2 4

# Build APK
echo -e "\n${YELLOW}Building APK...${NC}"
(cd "$PROJECT_DIR" && flutter build apk --release)

show_progress 3 4

# Check for connected device
DEVICE=$(cd "$PROJECT_DIR" && flutter devices | grep -o "RFCRA18GTEZ" || echo "")
if [ -z "$DEVICE" ]; then
    echo -e "${RED}No compatible device found${NC}"
    exit 1
fi

# Install and run
echo -e "\n${YELLOW}Installing and running...${NC}"
(cd "$PROJECT_DIR" && flutter run -d RFCRA18GTEZ)

show_progress 4 4

echo -e "\n${GREEN}Deployment complete!${NC}"
echo -e "${YELLOW}Testing Google login...${NC}"
echo -e "${YELLOW}Please verify the app opens and Google login works on your device.${NC}" 