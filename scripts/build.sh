#!/bin/bash

###############################################################################
# Build Script for ADB Cleaner
# Supports: Linux, macOS, Windows (cross-compile)
###############################################################################

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
APP_NAME="adb-cleaner"
VERSION="2.0.0"
BUILD_DIR="build"
DIST_DIR="dist"

# Print colored message
print_color() {
    local color=$1
    local message=$2
    echo -e "${color}${message}${NC}"
}

# Print header
print_header() {
    echo ""
    print_color "$BLUE" "=========================================="
    print_color "$BLUE" "  ADB Cleaner Build Script"
    print_color "$BLUE" "=========================================="
    echo ""
}

# Print usage
print_usage() {
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  --linux          Build for Linux (amd64)"
    echo "  --linux-arm64    Build for Linux (arm64)"
    echo "  --macos          Build for macOS (amd64)"
    echo "  --macos-arm64    Build for macOS (arm64)"
    echo "  --windows        Build for Windows (amd64)"
    echo "  --windows-arm64  Build for Windows (arm64)"
    echo "  --all            Build for all platforms"
    echo "  --clean          Clean build directory"
    echo "  --help           Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0 --linux"
    echo "  $0 --all"
    echo "  $0 --macos --windows"
}

# Clean build directory
clean_build() {
    print_color "$YELLOW" "[INFO] Cleaning build directory..."
    rm -rf "$BUILD_DIR" "$DIST_DIR"
    print_color "$GREEN" "[OK] Build directory cleaned"
}

# Create build directories
create_dirs() {
    mkdir -p "$BUILD_DIR"
    mkdir -p "$DIST_DIR"
}

# Build for specific platform
build_platform() {
    local os=$1
    local arch=$2
    local output_name=$3

    print_color "$BLUE" "[INFO] Building for $os/$arch..."

    local goos="$os"
    local goarch="$arch"

    # Set output filename
    if [ "$os" = "windows" ]; then
        output_name="${output_name}.exe"
    fi

    # Build
    GOOS="$goos" GOARCH="$goarch" go build \
        -ldflags "-s -w -X main.Version=$VERSION" \
        -o "$BUILD_DIR/$output_name" \
        ./cmd/adb-cleaner

    # Create archive
    if [ "$os" = "windows" ]; then
        cd "$BUILD_DIR" && zip -q "../${DIST_DIR}/${output_name}.zip" "$output_name" && cd ..
    else
        cd "$BUILD_DIR" && tar -czf "../${DIST_DIR}/${output_name}.tar.gz" "$output_name" && cd ..
    fi

    print_color "$GREEN" "[OK] Built: $output_name"
}

# Build for Linux
build_linux() {
    build_platform "linux" "amd64" "${APP_NAME}-linux-amd64"
}

# Build for Linux ARM64
build_linux_arm64() {
    build_platform "linux" "arm64" "${APP_NAME}-linux-arm64"
}

# Build for macOS
build_macos() {
    build_platform "darwin" "amd64" "${APP_NAME}-macos-amd64"
}

# Build for macOS ARM64
build_macos_arm64() {
    build_platform "darwin" "arm64" "${APP_NAME}-macos-arm64"
}

# Build for Windows
build_windows() {
    build_platform "windows" "amd64" "${APP_NAME}-windows-amd64"
}

# Build for Windows ARM64
build_windows_arm64() {
    build_platform "windows" "arm64" "${APP_NAME}-windows-arm64"
}

# Build for all platforms
build_all() {
    print_color "$BLUE" "[INFO] Building for all platforms..."
    build_linux
    build_linux_arm64
    build_macos
    build_macos_arm64
    build_windows
    build_windows_arm64
}

# Check Go installation
check_go() {
    if ! command -v go &> /dev/null; then
        print_color "$RED" "[ERROR] Go is not installed."
        echo "Please install Go from https://golang.org/dl/"
        exit 1
    fi

    local go_version=$(go version | awk '{print $3}')
    print_color "$GREEN" "[OK] Go version: $go_version"
}

# Download dependencies
download_deps() {
    print_color "$BLUE" "[INFO] Downloading dependencies..."
    go mod download
    go mod tidy
    print_color "$GREEN" "[OK] Dependencies downloaded"
}

# Print summary
print_summary() {
    echo ""
    print_color "$CYAN" "=========================================="
    print_color "$CYAN" "           Build Summary"
    print_color "$CYAN" "=========================================="
    echo ""
    echo "Version: $VERSION"
    echo "Build directory: $BUILD_DIR"
    echo "Distribution directory: $DIST_DIR"
    echo ""

    if [ -d "$DIST_DIR" ]; then
        print_color "$GREEN" "Built artifacts:"
        ls -lh "$DIST_DIR"
    fi
    echo ""
}

###############################################################################
# Main
###############################################################################

# Parse arguments
if [ $# -eq 0 ]; then
    print_usage
    exit 0
fi

# Execute
print_header
check_go
create_dirs

while [[ $# -gt 0 ]]; do
    case $1 in
        --linux)
            download_deps
            build_linux
            shift
            ;;
        --linux-arm64)
            download_deps
            build_linux_arm64
            shift
            ;;
        --macos)
            download_deps
            build_macos
            shift
            ;;
        --macos-arm64)
            download_deps
            build_macos_arm64
            shift
            ;;
        --windows)
            download_deps
            build_windows
            shift
            ;;
        --windows-arm64)
            download_deps
            build_windows_arm64
            shift
            ;;
        --all)
            download_deps
            build_all
            shift
            ;;
        --clean)
            clean_build
            shift
            ;;
        --help)
            print_usage
            exit 0
            ;;
        *)
            print_color "$RED" "[ERROR] Unknown option: $1"
            print_usage
            exit 1
            ;;
    esac
done

print_summary
print_color "$GREEN" "[DONE] Build completed!"
