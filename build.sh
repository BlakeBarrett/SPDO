#!/bin/bash
set -e

# SPDO Build Script for macOS and Linux
# This script automatically detects the platform and Qt path, then builds and runs the SPDO app

# Colors for terminal output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}=== SPDO Build Script ===${NC}"

# Function to detect OS
detect_os() {
  if [[ "$OSTYPE" == "darwin"* ]]; then
    echo "macos"
  elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
    echo "linux"
  else
    echo "unknown"
  fi
}

# Detect the operating system
OS=$(detect_os)
echo -e "${YELLOW}Detected OS: ${OS}${NC}"

# Set paths based on OS
if [ "$OS" == "macos" ]; then
  # Try different possible macOS Qt paths
  if [ -d "/Volumes/Macintosh SSD/Blake/Qt/6.9.0/macos" ]; then
    QT_PATH="/Volumes/Macintosh SSD/Blake/Qt/6.9.0/macos"
  elif [ -d "/Users/blake/Qt/6.9.0/macos" ]; then
    QT_PATH="/Users/blake/Qt/6.9.0/macos"
  else
    echo -e "${RED}Error: Qt installation not found in common macOS locations${NC}"
    echo "Please specify Qt path manually by setting the QT_PATH environment variable"
    exit 1
  fi
  EXECUTABLE="./build/SPDO_exe.app/Contents/MacOS/SPDO_exe"
elif [ "$OS" == "linux" ]; then
  # Try Linux Qt path
  if [ -d "/media/ntfs/Users/Blake/Qt/6.9.0/gcc_64" ]; then
    QT_PATH="/media/ntfs/Users/Blake/Qt/6.9.0/gcc_64"
  else
    echo -e "${RED}Error: Qt installation not found in common Linux location${NC}"
    echo "Please specify Qt path manually by setting the QT_PATH environment variable"
    exit 1
  fi
  EXECUTABLE="./build/SPDO_exe"
else
  echo -e "${RED}Unsupported OS: $OS${NC}"
  exit 1
fi

# Allow overriding Qt path from environment
if [ ! -z "$QT_PATH" ]; then
  echo -e "${YELLOW}Using Qt from: $QT_PATH${NC}"
else
  echo -e "${RED}Qt path not found. Please set QT_PATH environment variable${NC}"
  exit 1
fi

# Check if build directory exists and clean if it does
if [ -d "build" ]; then
  echo -e "${YELLOW}Cleaning existing build directory...${NC}"
  rm -rf build
fi

# Create build directory
echo -e "${YELLOW}Creating build directory...${NC}"
mkdir -p build

# Enter build directory and run cmake
echo -e "${YELLOW}Running CMake...${NC}"
cd build
cmake .. -DCMAKE_PREFIX_PATH="$QT_PATH"

# Build the project
echo -e "${YELLOW}Building project...${NC}"
cmake --build .

# Check if build was successful
if [ $? -eq 0 ]; then
  echo -e "${GREEN}Build successful!${NC}"
  
  # Navigate back to the project root
  cd ..
  
  # Run the executable if it exists
  if [ -f "$EXECUTABLE" ]; then
    echo -e "${YELLOW}Running SPDO application...${NC}"
    "$EXECUTABLE"
  else
    echo -e "${RED}Executable not found at: $EXECUTABLE${NC}"
    exit 1
  fi
else
  echo -e "${RED}Build failed!${NC}"
  exit 1
fi

exit 0