#!/bin/bash

# Memory Forensics Activity Generator Script
# Author: Professional Linux User
# Version: 1.0

# Configuration
LIME_PATH="/home/ubuntu/LiME/src"
MEMORY_OUTPUT_DIR="/mnt/forensic"
MAX_MEMORY_CAPTURES=30
LOG_FILE="/var/log/activity_generator.log"

# Color codes for verbose output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging function
log_message() {
    local level=$1
    local message=$2
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    
    echo -e "${message}"
    echo "[${timestamp}] [${level}] ${message}" >> "$LOG_FILE"
}

# Check if running as root
check_root() {
    if [[ $EUID -ne 0 ]]; then
        log_message "ERROR" "This script must be run as root"
        exit 1
    fi
}

# Initialize directories and files
initialize() {
    log_message "INFO" "Initializing system..."
    
    # Create necessary directories
    mkdir -p "$MEMORY_OUTPUT_DIR"
    mkdir -p "$(dirname "$LOG_FILE")"
    
    # Check if LiME directory exists
    if [[ ! -d "$LIME_PATH" ]]; then
        log_message "ERROR" "LiME directory not found at $LIME_PATH"
        log_message "INFO" "Please ensure LiME is installed at the correct path"
        exit 1
    fi
    
    # Check kernel version for LiME module
    KERNEL_VERSION=$(uname -r)
    LIME_MODULE="$LIME_PATH/lime-$KERNEL_VERSION.ko"
    
    if [[ ! -f "$LIME_MODULE" ]]; then
        log_message "WARNING" "LiME module for kernel $KERNEL_VERSION not found"
        log_message "INFO" "Attempting to find alternative LiME module..."
        
        # Try to find any LiME module
        LIME_MODULE=$(find "$LIME_PATH" -name "lime*.ko" | head -n 1)
        
        if [[ -z "$LIME_MODULE" ]]; then
            log_message "ERROR" "No LiME module found in $LIME_PATH"
            exit 1
        else
            log_message "INFO" "Using LiME module: $LIME_MODULE"
        fi
    fi
    
    touch "$LOG_FILE"
    log_message "INFO" "Initialization complete"
}

# Function to generate random user activity
generate_activity() {
    log_message "INFO" "${GREEN}Generating random user activity...${NC}"
    
    # List of possible user activities
    declare -a activities=(
        "browsing_web"
        "file_operations"
        "system_commands"
        "document_editing"
        "media_playback"
        "package_management"
        "network_operations"
    )
    
    # Select random number of activities (3-8)
    NUM_ACTIVITIES=$((RANDOM % 6 + 3))
    
    log_message "INFO" "${BLUE}Generating $NUM_ACTIVITIES random activities${NC}"
    
    for ((i=1; i<=NUM_ACTIVITIES; i++)); do
        # Select random activity type
        ACTIVITY_TYPE=${activities[$((RANDOM % ${#activities[@]}))]}
        
        case $ACTIVITY_TYPE in
            "browsing_web")
                log_message "INFO" "${YELLOW}Activity $i: Simulating web browsing${NC}"
                
                # Simulate opening browser or curl requests
                if command -v curl &> /dev/null; then
                    SITES=("https://www.google.com" "https://www.github.com" "https://www.wikipedia.org" "https://www.ubuntu.com")
                    SITE=${SITES[$((RANDOM % ${#SITES[@]}))]}
                    
                    # Simulate web request (with timeout to avoid hanging)
                    timeout 2 curl -s -I "$SITE" > /dev/null 2>&1 &
                    log_message "DEBUG" "  - Accessed $SITE"
                fi
                
                # Simulate browser process
                if [[ $((RANDOM % 2)) -eq 0 ]]; then
                    if command -v firefox &> /dev/null; then
                        timeout 3 firefox --headless --screenshot /tmp/test_screenshot.png https://www.example.com > /dev/null 2>&1 &
                        log_message "DEBUG" "  - Firefox headless screenshot"
                    fi
                fi
                ;;
                
            "file_operations")
                log_message "INFO" "${YELLOW}Activity $i: Performing file operations${NC}"
                
                # Create some random files
                TEMP_DIR="/tmp/user_activity_$(date +%s)"
                mkdir -p "$TEMP_DIR"
                
                # Create 2-5 random files
                NUM_FILES=$((RANDOM % 4 + 2))
                for ((j=0; j<NUM_FILES; j++)); do
                    FILE_NAME="$TEMP_DIR/file_${j}_$(date +%s).txt"
                    echo "Random content $(date) - $RANDOM" > "$FILE_NAME"
                    log_message "DEBUG" "  - Created file: $FILE_NAME"
                done
                
                # List files
                ls -la "$TEMP_DIR" > /dev/null 2>&1
                
                # Copy some files
                if [[ $((RANDOM % 3)) -eq 0 ]]; then
                    cp "$TEMP_DIR"/*.txt /tmp/ 2>/dev/null || true
                    log_message "DEBUG" "  - Copied files to /tmp/"
                fi
                
                # Clean up (sometimes)
                if [[ $((RANDOM % 2)) -eq 0 ]]; then
                    rm -rf "$TEMP_DIR"
                    log_message "DEBUG" "  - Cleaned up temporary directory"
                fi
                ;;
                
            "system_commands")
                log_message "INFO" "${YELLOW}Activity $i: Running system commands${NC}"
                
                # Array of common user commands
                declare -a commands=(
                    "ls -la /home"
                    "ps aux | head -10"
                    "df -h"
                    "free -m"
                    "whoami"
                    "date"
                    "uptime"
                    "uname -a"
                )
                
                # Execute 2-4 random commands
                NUM_COMMANDS=$((RANDOM % 3 + 2))
                for ((j=0; j<NUM_COMMANDS; j++)); do
                    CMD=${commands[$((RANDOM % ${#commands[@]}))]}
                    log_message "DEBUG" "  - Executing: $CMD"
                    eval "$CMD" > /dev/null 2>&1
                done
                ;;
                
            "document_editing")
                log_message "INFO" "${YELLOW}Activity $i: Editing documents${NC}"
                
                # Simulate text editing
                TEMP_FILE="/tmp/document_$(date +%s).txt"
                
                # Create/edit a document
                echo "# Document created at $(date)" > "$TEMP_FILE"
                echo "This is some sample text for user activity simulation." >> "$TEMP_FILE"
                echo "Random number: $RANDOM" >> "$TEMP_FILE"
                echo "Another line of text for forensic analysis." >> "$TEMP_FILE"
                
                # Sometimes append more
                if [[ $((RANDOM % 2)) -eq 0 ]]; then
                    echo "Additional content added later." >> "$TEMP_FILE"
                    log_message "DEBUG" "  - Appended to document"
                fi
                
                # View the document
                cat "$TEMP_FILE" > /dev/null 2>&1
                log_message "DEBUG" "  - Created and viewed document: $TEMP_FILE"
                ;;
                
            "media_playback")
                log_message "INFO" "${YELLOW}Activity $i: Media operations${NC}"
                
                # Simulate media-related activities
                if command -v ffmpeg &> /dev/null; then
                    # Create a test image
                    convert -size 100x100 xc:blue /tmp/test_image.png 2>/dev/null || \
                    ffmpeg -f lavfi -i color=c=blue:s=100x100 -frames:v 1 /tmp/test_image.png 2>/dev/null || true
                    log_message "DEBUG" "  - Created test image"
                fi
                
                # Play a sound if possible
                if command -v aplay &> /dev/null && [[ -f /usr/share/sounds/alsa/Noise.wav ]]; then
                    timeout 1 aplay /usr/share/sounds/alsa/Noise.wav 2>/dev/null &
                    log_message "DEBUG" "  - Played test sound"
                fi
                ;;
                
            "package_management")
                log_message "INFO" "${YELLOW}Activity $i: Package management${NC}"
                
                # Simulate package management activities
                if command -v apt &> /dev/null; then
                    # Check for updates (simulate)
                    timeout 5 apt update > /dev/null 2>&1 &
                    log_message "DEBUG" "  - Checked for package updates"
                    
                    # List installed packages
                    dpkg -l | head -20 > /dev/null 2>&1
                    log_message "DEBUG" "  - Listed installed packages"
                elif command -v yum &> /dev/null; then
                    timeout 5 yum check-update > /dev/null 2>&1 &
                    log_message "DEBUG" "  - Checked for package updates (yum)"
                fi
                ;;
                
            "network_operations")
                log_message "INFO" "${YELLOW}Activity $i: Network operations${NC}"
                
                # Simulate network activities
                if command -v ping &> /dev/null; then
                    # Ping localhost
                    ping -c 2 127.0.0.1 > /dev/null 2>&1 &
                    log_message "DEBUG" "  - Pinged localhost"
                fi
                
                # Check network connections
                if command -v netstat &> /dev/null; then
                    netstat -tuln | head -10 > /dev/null 2>&1
                    log_message "DEBUG" "  - Checked network connections"
                elif command -v ss &> /dev/null; then
                    ss -tuln | head -10 > /dev/null 2>&1
                    log_message "DEBUG" "  - Checked network connections (ss)"
                fi
                
                # DNS lookup
                if command -v nslookup &> /dev/null; then
                    nslookup google.com > /dev/null 2>&1 &
                    log_message "DEBUG" "  - Performed DNS lookup"
                fi
                ;;
        esac
        
        # Random delay between activities (1-3 seconds)
        sleep $((RANDOM % 3 + 1))
    done
    
    log_message "SUCCESS" "${GREEN}User activity generation completed!${NC}"
    log_message "INFO" "${BLUE}$NUM_ACTIVITIES different activities were simulated${NC}"
}

# Function to acquire memory using LiME
acquire_memory() {
    log_message "INFO" "${GREEN}Starting memory acquisition process...${NC}"
    
    # Check if LiME module exists
    if [[ ! -f "$LIME_MODULE" ]]; then
        log_message "ERROR" "LiME module not found: $LIME_MODULE"
        return 1
    fi
    
    # Find the next available memory dump index
    local index=1
    while [[ -f "${MEMORY_OUTPUT_DIR}/clean_$(printf '%02d' $index).raw" && $index -le $MAX_MEMORY_CAPTURES ]]; do
        ((index++))
    done
    
    if [[ $index -gt $MAX_MEMORY_CAPTURES ]]; then
        log_message "ERROR" "Maximum number of memory captures ($MAX_MEMORY_CAPTURES) reached"
        return 1
    fi
    
    local formatted_index=$(printf '%02d' $index)
    local output_file="${MEMORY_OUTPUT_DIR}/clean_${formatted_index}.raw"
    
    log_message "INFO" "${BLUE}Acquiring memory to: $output_file${NC}"
    log_message "INFO" "${YELLOW}Using LiME module: $(basename "$LIME_MODULE")${NC}"
    
    # Load LiME kernel module and capture memory
    local lime_command="insmod $LIME_MODULE \"path=$output_file format=raw\""
    
    log_message "DEBUG" "Executing: $lime_command"
    
    # Execute the LiME command
    if insmod "$LIME_MODULE" "path=$output_file format=raw"; then
        log_message "SUCCESS" "${GREEN}Memory acquisition successful!${NC}"
        log_message "INFO" "${BLUE}Memory dump saved to: $output_file${NC}"
        
        # Get file size
        if [[ -f "$output_file" ]]; then
            local file_size=$(du -h "$output_file" | cut -f1)
            log_message "INFO" "Memory dump size: $file_size"
            
            # Take hash of the memory dump
            take_hash "$output_file"
        else
            log_message "WARNING" "Memory dump file not found after acquisition"
        fi
    else
        log_message "ERROR" "${RED}Failed to acquire memory with LiME${NC}"
        return 1
    fi
}

# Function to take hash of files
take_hash() {
    local target_path=$1
    
    log_message "INFO" "${GREEN}Calculating hashes...${NC}"
    
    # If no specific path provided, hash all memory dumps
    if [[ -z "$target_path" ]]; then
        log_message "INFO" "${BLUE}Hashing all memory dump files in $MEMORY_OUTPUT_DIR${NC}"
        
        for file in "${MEMORY_OUTPUT_DIR}"/clean_*.raw; do
            if [[ -f "$file" ]]; then
                _calculate_file_hash "$file"
            fi
        done
        
        # Also hash the log file
        if [[ -f "$LOG_FILE" ]]; then
            _calculate_file_hash "$LOG_FILE"
        fi
    else
        # Hash specific file
        if [[ -f "$target_path" ]]; then
            _calculate_file_hash "$target_path"
        else
            log_message "ERROR" "File not found: $target_path"
        fi
    fi
    
    log_message "SUCCESS" "${GREEN}Hash calculation completed!${NC}"
}

# Helper function to calculate and display file hash
_calculate_file_hash() {
    local file=$1
    
    if [[ ! -f "$file" ]]; then
        return 1
    fi
    
    log_message "INFO" "${YELLOW}Calculating hashes for: $(basename "$file")${NC}"
    
    # Calculate different hash types
    if command -v sha256sum &> /dev/null; then
        local sha256_hash=$(sha256sum "$file" | cut -d' ' -f1)
        log_message "INFO" "  SHA256: $sha256_hash"
    fi
    
    if command -v sha1sum &> /dev/null; then
        local sha1_hash=$(sha1sum "$file" | cut -d' ' -f1)
        log_message "INFO" "  SHA1:   $sha1_hash"
    fi
    
    if command -v md5sum &> /dev/null; then
        local md5_hash=$(md5sum "$file" | cut -d' ' -f1)
        log_message "INFO" "  MD5:    $md5_hash"
    fi
    
    # Display file info
    local file_size=$(du -h "$file" | cut -f1)
    local file_date=$(stat -c %y "$file" 2>/dev/null || ls -la "$file" | awk '{print $6, $7, $8}')
    log_message "INFO" "  Size:   $file_size"
    log_message "INFO" "  Date:   $file_date"
    echo ""
}

# Display current status
show_status() {
    log_message "INFO" "${BLUE}=== Current Status ===${NC}"
    
    # Count memory dumps
    local dump_count=$(find "$MEMORY_OUTPUT_DIR" -name "clean_*.raw" 2>/dev/null | wc -l)
    log_message "INFO" "Memory dumps captured: $dump_count/$MAX_MEMORY_CAPTURES"
    
    # List memory dumps
    if [[ $dump_count -gt 0 ]]; then
        log_message "INFO" "${YELLOW}Existing memory dumps:${NC}"
        find "$MEMORY_OUTPUT_DIR" -name "clean_*.raw" 2>/dev/null | sort | while read -r dump; do
            local size=$(du -h "$dump" 2>/dev/null | cut -f1 || echo "unknown")
            log_message "INFO" "  - $(basename "$dump") ($size)"
        done
    fi
    
    # Log file info
    if [[ -f "$LOG_FILE" ]]; then
        local log_size=$(du -h "$LOG_FILE" | cut -f1)
        log_message "INFO" "Log file: $LOG_FILE ($log_size)"
    fi
    
    # LiME module status
    if lsmod | grep -q lime; then
        log_message "INFO" "${GREEN}LiME kernel module is loaded${NC}"
    else
        log_message "INFO" "${YELLOW}LiME kernel module is not loaded${NC}"
    fi
    
    log_message "INFO" "${BLUE}=====================${NC}"
}

# Display menu
display_menu() {
    echo -e "${BLUE}========================================${NC}"
    echo -e "${GREEN}    Memory Forensics Activity Tool    ${NC}"
    echo -e "${BLUE}========================================${NC}"
    echo -e "1. ${YELLOW}Generate User Activity${NC}"
    echo -e "   - Mimic normal user behaviors"
    echo -e "   - Random activities each execution"
    echo ""
    echo -e "2. ${YELLOW}Acquire Memory${NC}"
    echo -e "   - Use LiME tool for memory capture"
    echo -e "   - Creates clean_01.raw to clean_30.raw"
    echo ""
    echo -e "3. ${YELLOW}Take Hash${NC}"
    echo -e "   - Calculate hashes of memory dumps"
    echo -e "   - SHA256, SHA1, MD5 hashes"
    echo ""
    echo -e "4. ${YELLOW}Show Status${NC}"
    echo -e "   - Display current capture status"
    echo ""
    echo -e "5. ${YELLOW}Exit${NC}"
    echo -e "${BLUE}========================================${NC}"
}

# Main function
main() {
    # Check if running as root
    check_root
    
    # Initialize system
    initialize
    
    # Clear screen
    clear
    
    while true; do
        display_menu
        echo ""
        read -p "$(echo -e ${GREEN}'Select option (1-5): '${NC})" choice
        
        case $choice in
            1)
                echo ""
                generate_activity
                ;;
            2)
                echo ""
                acquire_memory
                ;;
            3)
                echo ""
                take_hash
                ;;
            4)
                echo ""
                show_status
                ;;
            5)
                echo ""
                log_message "INFO" "Exiting Memory Forensics Activity Tool"
                echo -e "${GREEN}Goodbye!${NC}"
                exit 0
                ;;
            *)
                echo ""
                log_message "WARNING" "Invalid option: $choice. Please select 1-5."
                ;;
        esac
        
        echo ""
        read -p "$(echo -e ${YELLOW}'Press Enter to continue...'${NC})" dummy
        clear
    done
}

# Trap for cleanup on exit
cleanup() {
    log_message "INFO" "Script terminated"
    
    # Unload LiME module if loaded
    if lsmod | grep -q lime; then
        rmmod lime 2>/dev/null && log_message "INFO" "Unloaded LiME kernel module"
    fi
    
    # Kill any background processes we started
    pkill -f "firefox.*headless" 2>/dev/null || true
    pkill -f "timeout.*curl" 2>/dev/null || true
    
    exit 0
}

# Set trap for cleanup
trap cleanup EXIT INT TERM

# Start the script
main
