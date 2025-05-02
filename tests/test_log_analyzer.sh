#!/bin/bash

# test_log_analyzer.sh
# Tests the log analysis script

set -euo pipefail

LOG_FILE="/var/log/log_analyzer_test.log"

# Logging function
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

main() {
    log "Starting log analysis test"

    # Create mock log directory and files
    mkdir -p /tmp/test_logs
    echo "2025-05-02 10:00:00 ERROR: Database connection failed" > /tmp/test_logs/service1.log
    echo "2025-05-02 10:01:00 INFO: Service running" >> /tmp/test_logs/service1.log
    echo "2025-05-02 10:02:00 CRITICAL: Out of memory" > /tmp/test_logs/service2.log

    # Mock configuration
    cat <<EOF > /tmp/test_log_analyzer.conf
LOG_DIR="/tmp/test_logs"
OUTPUT_REPORT="/tmp/test_report.txt"
ERROR_PATTERN="ERROR|CRITICAL"
EMAIL_RECIPIENT="test@example.com"
MAX_LOG_SIZE_MB=10
EOF

    # Run log analyzer script
    if scripts/log_analyzer.sh; then
        log "Log analysis test passed"
    else
        log "Log analysis test failed"
        exit 1
    fi

    # Validate report
    if grep -q "Error Count: 1" /tmp/test_report.txt && grep -q "Error Count: 1" /tmp/test_report.txt; then
        log "Report validation passed"
    else
        log "Report validation failed"
        exit 1
    fi

    log "Cleaning up test environment"
    rm -rf /tmp/test_logs /tmp/test_log_analyzer.conf /tmp/test_report.txt
}

main "$@"