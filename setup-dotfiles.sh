#!/bin/bash

# setup-dotfiles.sh - Copy i3 and fish configuration files to user config directories
# This script dynamically detects the home directory and copies configuration files
# to the appropriate locations under ~/.config/

set -e  # Exit immediately if a command exits with a non-zero status

# Function to print messages
print_status() {
    echo "[INFO] $1"
}

# Function to print error messages
print_error() {
    echo "[ERROR] $1" >&2
}

# Function to check if source file exists
check_source_file() {
    if [[ ! -f "$1" ]]; then
        print_error "Source file does not exist: $1"
        exit 1
    fi
}

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Define source paths
I3_CONFIG_SRC="$SCRIPT_DIR/i3config/config"
I3_BLOCKSCONF_SRC="$SCRIPT_DIR/i3config/i3blocks.conf"
I3_VOLUME_CLICK_SRC="$SCRIPT_DIR/i3config/scripts/volume-click"
FISH_CONFIG_SRC="$SCRIPT_DIR/fish/config.fish"

# Define destination paths
I3_CONFIG_DEST="$HOME/.config/i3/config"
I3_BLOCKSCONF_DEST="$HOME/.config/i3/i3blocks.conf"
I3_VOLUME_CLICK_DEST="$HOME/.config/i3/scripts/volume-click"
FISH_CONFIG_DEST="$HOME/.config/fish/config.fish"

# Check if all source files exist
print_status "Checking source files..."
check_source_file "$I3_CONFIG_SRC"
check_source_file "$I3_BLOCKSCONF_SRC"
check_source_file "$I3_VOLUME_CLICK_SRC"
check_source_file "$FISH_CONFIG_SRC"

# Create destination directories if they don't exist
print_status "Creating destination directories..."
mkdir -p "$HOME/.config/i3/scripts" 2>/dev/null || {
    print_error "Failed to create directory: $HOME/.config/i3/scripts"
    exit 1
}
mkdir -p "$HOME/.config/fish" 2>/dev/null || {
    print_error "Failed to create directory: $HOME/.config/fish"
    exit 1
}

# Copy i3 configuration files
print_status "Copying i3 configuration files..."
cp "$I3_CONFIG_SRC" "$I3_CONFIG_DEST" && \
    print_status "Copied $I3_CONFIG_SRC to $I3_CONFIG_DEST"

cp "$I3_BLOCKSCONF_SRC" "$I3_BLOCKSCONF_DEST" && \
    print_status "Copied $I3_BLOCKSCONF_SRC to $I3_BLOCKSCONF_DEST"

cp "$I3_VOLUME_CLICK_SRC" "$I3_VOLUME_CLICK_DEST" && \
    print_status "Copied $I3_VOLUME_CLICK_SRC to $I3_VOLUME_CLICK_DEST"

# Make the volume-click script executable
chmod +x "$I3_VOLUME_CLICK_DEST" 2>/dev/null || {
    print_error "Failed to make $I3_VOLUME_CLICK_DEST executable"
}

# Copy fish configuration file
print_status "Copying fish configuration file..."
cp "$FISH_CONFIG_SRC" "$FISH_CONFIG_DEST" && \
    print_status "Copied $FISH_CONFIG_SRC to $FISH_CONFIG_DEST"

print_status "Dotfiles setup completed successfully!"
print_status "You may need to restart your shell or run 'exec fish' for fish changes to take effect."
print_status "For i3, you can reload the configuration with Mod+Shift+R or restart i3."
