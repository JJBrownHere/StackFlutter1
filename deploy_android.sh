#!/bin/bash

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Store the original directory
ORIGINAL_DIR=$(pwd)

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

echo -e "${GREEN}=== Starting Android Deployment kewlwerkJJ===${NC}"

# Verify project structure
echo -e "\n${YELLOW}Verifying project structure...${NC}"
if [ ! -d "FProjects/BuyBackTools" ]; then
    echo -e "${RED}Error: FProjects/BuyBackTools directory not found${NC}"
    echo -e "${YELLOW}Current directory: $(pwd)${NC}"
    echo -e "${YELLOW}Expected structure:${NC}"
    echo "  FProjects/"
    echo "    └── BuyBackTools/"
    echo "        ├── android/"
    echo "        ├── lib/"
    echo "        └── pubspec.yaml"
    exit 1
fi

# Navigate to Flutter project
echo -e "\n${YELLOW}Navigating to Flutter project...${NC}"
cd FProjects/BuyBackTools || { 
    echo -e "${RED}Failed to navigate to project directory${NC}"
    echo -e "${YELLOW}Current directory: $(pwd)${NC}"
    exit 1
}

# Verify we're in the right place
if [ ! -f "pubspec.yaml" ]; then
    echo -e "${RED}Error: pubspec.yaml not found in $(pwd)${NC}"
    echo -e "${YELLOW}Please ensure you're running the script from the project root${NC}"
    exit 1
fi

# Check for connected devices
echo -e "\n${YELLOW}Checking for connected devices...${NC}"
DEVICE=$(flutter devices | grep -o "RFCRA18GTEZ" || echo "")
if [ -z "$DEVICE" ]; then
    echo -e "${RED}No compatible device found${NC}"
    exit 1
fi
echo -e "${GREEN}Device found: $DEVICE${NC}"

# Clean Android project only
echo -e "\n${YELLOW}=== Cleaning Android Project ===${NC}"
echo "Running Android clean..."
cd android && ./gradlew clean > /dev/null 2>&1 & CLEAN_PID=$!
spinner $CLEAN_PID &
SPINNER_PID=$!

if ! handle_termination $CLEAN_PID $SPINNER_PID 120 "Clean operation"; then
    echo -e "${YELLOW}Attempting to force clean...${NC}"
    rm -rf build/ .gradle/
    ./gradlew clean --info
    cd "$ORIGINAL_DIR"
    exit 1
fi

cd "$ORIGINAL_DIR/FProjects/BuyBackTools"
show_progress 1 4

# Get dependencies
echo -e "\n${YELLOW}=== Getting Dependencies ===${NC}"
flutter pub get > /dev/null 2>&1 & DEPS_PID=$!
spinner $DEPS_PID &
SPINNER_PID=$!

if ! handle_termination $DEPS_PID $SPINNER_PID 180 "Dependencies operation"; then
    cd "$ORIGINAL_DIR"
    exit 1
fi

show_progress 2 4

# Build APK
echo -e "\n${YELLOW}=== Building APK ===${NC}"
flutter build apk --debug > /dev/null 2>&1 & BUILD_PID=$!
spinner $BUILD_PID &
SPINNER_PID=$!

if ! handle_termination $BUILD_PID $SPINNER_PID 600 "Build operation"; then
    cd "$ORIGINAL_DIR"
    exit 1
fi

show_progress 3 4

# Install and run
echo -e "\n${YELLOW}=== Installing and Running ===${NC}"
flutter run -d RFCRA18GTEZ --no-pub > /dev/null 2>&1 & RUN_PID=$!
spinner $RUN_PID &
SPINNER_PID=$!

if ! handle_termination $RUN_PID $SPINNER_PID 300 "Run operation"; then
    cd "$ORIGINAL_DIR"
    exit 1
fi

show_progress 4 4

cd "$ORIGINAL_DIR"
echo -e "\n${GREEN}Deployment complete!${NC}"
echo -e "${YELLOW}Check your device for the app.${NC}" 