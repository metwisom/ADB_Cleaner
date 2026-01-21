#!/bin/bash

###############################################################################
# ADB Cleaner v2.0 - Enhanced Android Debloat Tool
# Features:
# - Device connection check
# - Error handling and logging
# - Interactive mode
# - Progress bar and colored output
# - Package availability check
# - Report generation
###############################################################################

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Configuration
PACKS_FILE="packs.txt"
LOG_DIR="logs"
BACKUP_DIR="backups"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
LOG_FILE="$LOG_DIR/debloat_$TIMESTAMP.log"
SUCCESS_LOG="$LOG_DIR/success_$TIMESTAMP.txt"
FAIL_LOG="$LOG_DIR/failed_$TIMESTAMP.txt"
SKIP_LOG="$LOG_DIR/skipped_$TIMESTAMP.txt"
BACKUP_FILE="$BACKUP_DIR/backup_$TIMESTAMP.txt"
USER_ID=0

# Counters
TOTAL=0
SUCCESS_COUNT=0
FAIL_COUNT=0
SKIP_COUNT=0

# Mode: auto, interactive, dry-run, safe
MODE="auto"

###############################################################################
# Functions
###############################################################################

# Print colored message
print_color() {
    local color=$1
    local message=$2
    echo -e "${color}${message}${NC}"
}

# Print header
print_header() {
    echo ""
    print_color "$CYAN" "=========================================="
    print_color "$CYAN" "  ADB Cleaner v2.0 - Enhanced Debloat"
    print_color "$CYAN" "=========================================="
    echo ""
}

# Print usage
print_usage() {
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  --auto           Automatic mode (default)"
    echo "  --interactive    Interactive mode with confirmation"
    echo "  --dry-run        Show what would be removed without removing"
    echo "  --safe           Only remove safe packages"
    echo "  --help           Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0 --auto"
    echo "  $0 --interactive"
    echo "  $0 --dry-run"
}

# Create directories
create_dirs() {
    mkdir -p "$LOG_DIR" "$BACKUP_DIR"
}

# Check if ADB is installed
check_adb() {
    if ! command -v adb &> /dev/null; then
        print_color "$RED" "[ERROR] ADB not found. Please install it."
        echo ""
        echo "Ubuntu/Debian: sudo apt install android-tools-adb"
        echo "Arch Linux:    sudo pacman -S android-tools"
        echo "Fedora:        sudo dnf install android-tools"
        echo "macOS:         brew install android-platform-tools"
        exit 1
    fi
    print_color "$GREEN" "[OK] ADB is installed"
}

# Check device connection
check_device() {
    print_color "$BLUE" "[INFO] Checking device connection..."
    
    if ! adb devices | grep -q "device$"; then
        print_color "$RED" "[ERROR] No device found or device not authorized."
        echo ""
        echo "Please:"
        echo "  1. Connect your device via USB"
        echo "  2. Enable USB Debugging in Developer Options"
        echo "  3. Accept the debugging prompt on your device"
        echo ""
        echo "Current devices:"
        adb devices
        exit 1
    fi
    
    # Get device info
    DEVICE_MODEL=$(adb shell getprop ro.product.model 2>/dev/null | tr -d '\r')
    ANDROID_VERSION=$(adb shell getprop ro.build.version.release 2>/dev/null | tr -d '\r')
    MANUFACTURER=$(adb shell getprop ro.product.manufacturer 2>/dev/null | tr -d '\r' | tr '[:upper:]' '[:lower:]')
    
    print_color "$GREEN" "[OK] Device connected: $MANUFACTURER $DEVICE_MODEL"
    print_color "$GREEN" "[OK] Android version: $ANDROID_VERSION"
}

# Count total packages
count_packages() {
    TOTAL=$(grep -v "^#" "$PACKS_FILE" | grep -v "^$" | wc -l)
    print_color "$BLUE" "[INFO] Total packages to process: $TOTAL"
}

# Progress bar
show_progress() {
    local current=$1
    local total=$2
    local percent=$((current * 100 / total))
    local filled=$((percent / 2))
    local empty=$((50 - filled))
    
    printf "\rProgress: ["
    printf "%${filled}s" | tr ' ' '='
    printf "%${empty}s" | tr ' ' ' '
    printf "] %d%% (%d/%d)" "$percent" "$current" "$total"
}

# Check if package is installed
is_package_installed() {
    local pkg=$1
    adb shell pm list packages 2>/dev/null | grep -q "package:$pkg$"
}

# Backup package info
backup_package() {
    local pkg=$1
    echo "$pkg" >> "$BACKUP_FILE"
}

# Remove package
remove_package() {
    local pkg=$1
    
    # Check if package is installed
    if ! is_package_installed "$pkg"; then
        print_color "$YELLOW" "[SKIP] Package not installed: $pkg"
        echo "$pkg" >> "$SKIP_LOG"
        ((SKIP_COUNT++))
        return
    fi
    
    # Backup package
    backup_package "$pkg"
    
    # Interactive mode
    if [ "$MODE" == "interactive" ]; then
        echo ""
        read -p "Remove $pkg? [y/N] " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            print_color "$YELLOW" "[SKIP] User skipped: $pkg"
            echo "$pkg" >> "$SKIP_LOG"
            ((SKIP_COUNT++))
            return
        fi
    fi
    
    # Dry run mode
    if [ "$MODE" == "dry-run" ]; then
        print_color "$CYAN" "[DRY-RUN] Would remove: $pkg"
        return
    fi
    
    # Remove package
    print_color "$BLUE" "[REMOVE] $pkg"
    
    if adb shell pm uninstall --user "$USER_ID" "$pkg" 2>&1 | grep -q "Success"; then
        print_color "$GREEN" "[SUCCESS] $pkg"
        echo "$pkg" >> "$SUCCESS_LOG"
        ((SUCCESS_COUNT++))
    else
        print_color "$RED" "[FAILED] $pkg"
        echo "$pkg" >> "$FAIL_LOG"
        ((FAIL_COUNT++))
    fi
}

# Generate report
generate_report() {
    echo ""
    print_color "$CYAN" "=========================================="
    print_color "$CYAN" "           DEBLOAT REPORT"
    print_color "$CYAN" "=========================================="
    echo ""
    echo "Date: $(date)"
    echo "Device: $MANUFACTURER $DEVICE_MODEL"
    echo "Android: $ANDROID_VERSION"
    echo "Mode: $MODE"
    echo ""
    echo "Statistics:"
    echo "  Total packages:    $TOTAL"
    print_color "$GREEN" "  Successfully removed: $SUCCESS_COUNT"
    print_color "$RED" "  Failed:             $FAIL_COUNT"
    print_color "$YELLOW" "  Skipped:            $SKIP_COUNT"
    echo ""
    echo "Log files:"
    echo "  Main log:      $LOG_FILE"
    echo "  Success:       $SUCCESS_LOG"
    echo "  Failed:        $FAIL_LOG"
    echo "  Skipped:       $SKIP_LOG"
    echo "  Backup list:   $BACKUP_FILE"
    echo ""
    print_color "$CYAN" "=========================================="
}

# Main debloat process
debloat() {
    print_color "$BLUE" "[INFO] Starting debloat process..."
    echo ""
    
    local current=0
    
    while IFS= read -r pkg || [[ -n "$pkg" ]]; do
        # Ignore empty lines and comments
        [[ -z "$pkg" || "$pkg" =~ ^# ]] && continue
        
        ((current++))
        show_progress "$current" "$TOTAL"
        
        # Log to file
        echo "[$(date '+%Y-%m-%d %H:%M:%S')] Processing: $pkg" >> "$LOG_FILE"
        
        remove_package "$pkg"
        
    done < "$PACKS_FILE"
    
    echo ""
}

###############################################################################
# Main
###############################################################################

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --auto)
            MODE="auto"
            shift
            ;;
        --interactive)
            MODE="interactive"
            shift
            ;;
        --dry-run)
            MODE="dry-run"
            shift
            ;;
        --safe)
            MODE="safe"
            shift
            ;;
        --help)
            print_usage
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            print_usage
            exit 1
            ;;
    esac
done

# Execute
print_header
create_dirs
check_adb
check_device
count_packages
debloat
generate_report

echo ""
print_color "$GREEN" "[DONE] Debloat process completed!"
echo ""
if [ "$MODE" != "dry-run" ]; then
    print_color "$YELLOW" "It is recommended to reboot your device."
fi
echo ""
