#!/bin/bash

# Check if ADB is installed
if ! command -v adb &> /dev/null; then
    echo "[ERROR] ADB not found. Please install it (e.g., sudo apt install android-tools-adb)."
    exit 1
fi

echo "Starting debloat..."

# Read packages from packs.txt
while IFS= read -r pkg || [[ -n "$pkg" ]]; do
    # Ignore empty lines and lines starting with #
    [[ -z "$pkg" || "$pkg" =~ ^# ]] && continue

    echo "Removing package: $pkg"
    adb shell pm uninstall --user 0 "$pkg"
done < "packs.txt"

echo "Done! It is recommended to reboot your phone."
