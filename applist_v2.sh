#!/bin/bash

###############################################################################
# ADB App List v2.0 - Enhanced Application Listing Tool
# Features:
# - Device connection check
# - Categorized output
# - Filter by manufacturer
# - Search functionality
# - Export to multiple formats
###############################################################################

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Configuration
OUTPUT_DIR="app_lists"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
OUTPUT_FILE="$OUTPUT_DIR/app_list_$TIMESTAMP.txt"
OUTPUT_JSON="$OUTPUT_DIR/app_list_$TIMESTAMP.json"
OUTPUT_CSV="$OUTPUT_DIR/app_list_$TIMESTAMP.csv"
FILTER=""
SEARCH=""

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
    print_color "$CYAN" "  ADB App List v2.0"
    print_color "$CYAN" "=========================================="
    echo ""
}

# Print usage
print_usage() {
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  --system         List only system packages"
    echo "  --third-party    List only third-party packages"
    echo "  --enabled        List only enabled packages"
    echo "  --disabled       List only disabled packages"
    echo "  --search TEXT    Search for packages containing TEXT"
    echo "  --json           Export to JSON format"
    echo "  --csv            Export to CSV format"
    echo "  --all            Export to all formats"
    echo "  --help           Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0                           # List all packages"
    echo "  $0 --third-party             # List only user apps"
    echo "  $0 --search google           # Search for google packages"
    echo "  $0 --json                    # Export to JSON"
    echo "  $0 --system --all            # List system apps and export to all formats"
}

# Create output directory
create_output_dir() {
    mkdir -p "$OUTPUT_DIR"
}

# Check if ADB is installed
check_adb() {
    if ! command -v adb &> /dev/null; then
        print_color "$RED" "[ERROR] ADB not found. Please install it."
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
        exit 1
    fi
    
    # Get device info
    DEVICE_MODEL=$(adb shell getprop ro.product.model 2>/dev/null | tr -d '\r')
    ANDROID_VERSION=$(adb shell getprop ro.build.version.release 2>/dev/null | tr -d '\r')
    MANUFACTURER=$(adb shell getprop ro.product.manufacturer 2>/dev/null | tr -d '\r')
    
    print_color "$GREEN" "[OK] Device connected: $MANUFACTURER $DEVICE_MODEL"
    print_color "$GREEN" "[OK] Android version: $ANDROID_VERSION"
}

# Get package list with details
get_packages() {
    local filter=$1
    
    case "$filter" in
        --system)
            adb shell pm list packages -s 2>/dev/null | sed 's/package://'
            ;;
        --third-party)
            adb shell pm list packages -3 2>/dev/null | sed 's/package://'
            ;;
        --enabled)
            adb shell pm list packages -e 2>/dev/null | sed 's/package://'
            ;;
        --disabled)
            adb shell pm list packages -d 2>/dev/null | sed 's/package://'
            ;;
        *)
            adb shell pm list packages 2>/dev/null | sed 's/package://'
            ;;
    esac
}

# Search packages
search_packages() {
    local search_term=$1
    adb shell pm list packages 2>/dev/null | sed 's/package://' | grep -i "$search_term"
}

# Get package details
get_package_details() {
    local pkg=$1
    local version=$(adb shell dumpsys package "$pkg" 2>/dev/null | grep "versionName=" | head -1 | cut -d'=' -f2)
    local version_code=$(adb shell dumpsys package "$pkg" 2>/dev/null | grep "versionCode=" | head -1 | cut -d'=' -f2 | cut -d' ' -f1)
    local install_time=$(adb shell dumpsys package "$pkg" 2>/dev/null | grep "firstInstallTime" | head -1 | cut -d'=' -f2)
    
    echo "$pkg|$version|$version_code|$install_time"
}

# Export to JSON
export_json() {
    local packages=$1
    
    print_color "$BLUE" "[INFO] Exporting to JSON..."
    
    echo "{" > "$OUTPUT_JSON"
    echo "  \"timestamp\": \"$(date -Iseconds)\"," >> "$OUTPUT_JSON"
    echo "  \"device\": {" >> "$OUTPUT_JSON"
    echo "    \"manufacturer\": \"$MANUFACTURER\"," >> "$OUTPUT_JSON"
    echo "    \"model\": \"$DEVICE_MODEL\"," >> "$OUTPUT_JSON"
    echo "    \"android_version\": \"$ANDROID_VERSION\"" >> "$OUTPUT_JSON"
    echo "  }," >> "$OUTPUT_JSON"
    echo "  \"packages\": [" >> "$OUTPUT_JSON"
    
    local first=true
    while IFS= read -r pkg; do
        [ -z "$pkg" ] && continue
        
        if [ "$first" = true ]; then
            first=false
        else
            echo "," >> "$OUTPUT_JSON"
        fi
        
        local details=$(get_package_details "$pkg")
        local version=$(echo "$details" | cut -d'|' -f2)
        local version_code=$(echo "$details" | cut -d'|' -f3)
        local install_time=$(echo "$details" | cut -d'|' -f4)
        
        echo -n "    {\"package\": \"$pkg\", \"version\": \"$version\", \"version_code\": \"$version_code\", \"install_time\": \"$install_time\"}" >> "$OUTPUT_JSON"
    done <<< "$packages"
    
    echo "" >> "$OUTPUT_JSON"
    echo "  ]" >> "$OUTPUT_JSON"
    echo "}" >> "$OUTPUT_JSON"
    
    print_color "$GREEN" "[OK] JSON exported to: $OUTPUT_JSON"
}

# Export to CSV
export_csv() {
    local packages=$1
    
    print_color "$BLUE" "[INFO] Exporting to CSV..."
    
    echo "Package,Version,Version Code,Install Time" > "$OUTPUT_CSV"
    
    while IFS= read -r pkg; do
        [ -z "$pkg" ] && continue
        
        local details=$(get_package_details "$pkg")
        local version=$(echo "$details" | cut -d'|' -f2)
        local version_code=$(echo "$details" | cut -d'|' -f3)
        local install_time=$(echo "$details" | cut -d'|' -f4)
        
        echo "$pkg,$version,$version_code,$install_time" >> "$OUTPUT_CSV"
    done <<< "$packages"
    
    print_color "$GREEN" "[OK] CSV exported to: $OUTPUT_CSV"
}

# Export to TXT
export_txt() {
    local packages=$1
    
    print_color "$BLUE" "[INFO] Exporting to TXT..."
    
    echo "# ADB App List - $(date)" > "$OUTPUT_FILE"
    echo "# Device: $MANUFACTURER $DEVICE_MODEL" >> "$OUTPUT_FILE"
    echo "# Android: $ANDROID_VERSION" >> "$OUTPUT_FILE"
    echo "# Total packages: $(echo "$packages" | wc -l)" >> "$OUTPUT_FILE"
    echo "" >> "$OUTPUT_FILE"
    
    while IFS= read -r pkg; do
        [ -z "$pkg" ] && continue
        echo "$pkg" >> "$OUTPUT_FILE"
    done <<< "$packages"
    
    print_color "$GREEN" "[OK] TXT exported to: $OUTPUT_FILE"
}

# Display statistics
show_statistics() {
    local packages=$1
    local total=$(echo "$packages" | wc -l)
    local system=$(adb shell pm list packages -s 2>/dev/null | wc -l)
    local third_party=$(adb shell pm list packages -3 2>/dev/null | wc -l)
    local enabled=$(adb shell pm list packages -e 2>/dev/null | wc -l)
    local disabled=$(adb shell pm list packages -d 2>/dev/null | wc -l)
    
    echo ""
    print_color "$CYAN" "=========================================="
    print_color "$CYAN" "           STATISTICS"
    print_color "$CYAN" "=========================================="
    echo ""
    echo "Total packages:      $total"
    echo "System packages:      $system"
    echo "Third-party packages: $third_party"
    echo "Enabled packages:     $enabled"
    echo "Disabled packages:    $disabled"
    echo ""
}

###############################################################################
# Main
###############################################################################

# Parse arguments
export_json_flag=false
export_csv_flag=false
export_all_flag=false

while [[ $# -gt 0 ]]; do
    case $1 in
        --system)
            FILTER="--system"
            shift
            ;;
        --third-party)
            FILTER="--third-party"
            shift
            ;;
        --enabled)
            FILTER="--enabled"
            shift
            ;;
        --disabled)
            FILTER="--disabled"
            shift
            ;;
        --search)
            SEARCH="$2"
            shift 2
            ;;
        --json)
            export_json_flag=true
            shift
            ;;
        --csv)
            export_csv_flag=true
            shift
            ;;
        --all)
            export_all_flag=true
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
create_output_dir
check_adb
check_device

# Get packages
print_color "$BLUE" "[INFO] Getting package list..."

if [ -n "$SEARCH" ]; then
    PACKAGES=$(search_packages "$SEARCH")
    print_color "$BLUE" "[INFO] Searching for: $SEARCH"
else
    PACKAGES=$(get_packages "$FILTER")
fi

# Display statistics
show_statistics "$PACKAGES"

# Export
export_txt "$PACKAGES"

if [ "$export_json_flag" = true ] || [ "$export_all_flag" = true ]; then
    export_json "$PACKAGES"
fi

if [ "$export_csv_flag" = true ] || [ "$export_all_flag" = true ]; then
    export_csv "$PACKAGES"
fi

echo ""
print_color "$GREEN" "[DONE] Package list completed!"
echo ""
print_color "YELLOW" "Output directory: $OUTPUT_DIR"
echo ""
