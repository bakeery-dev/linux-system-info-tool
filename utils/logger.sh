#!/bin/bash

# Simple logging utility for the system info tool

LOG_FILE="/tmp/system_info_tool.log"

log_message() {
    local message="$1"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    
    echo "[$timestamp] $message" >> "$LOG_FILE"
    
    # Also echo to terminal in verbose mode
    if [[ "$VERBOSE" == "true" ]]; then
        echo "[LOG] $message"
    fi
}

# Initialize log
log_message "System Info Tool started by user: $USER"
