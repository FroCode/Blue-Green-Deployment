#!/bin/bash

#============================================================== By Frocode =======================================================


# log_analyzer.sh
# Aggregates and analyzes logs from multiple services, generating reports

set -euo pipefail

# Default configuration
CONFIG_FILE="/etc/loganalyzer/log_analyzer.conf"
LOG_FILE="/var/log/log_analyzer.log"

# Logging function
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

# Load configuration
load_config() {
    if [ -f "$CONFIG_FILE" ]; then
        log "Loading configuration from $CONFIG_FILE"
        source "$CONFIG_FILE"
    else
        log "Configuration file $CONFIG_FILE not found, using defaults"
    fi

    # Validate required variables
    : "${LOG_DIR:?LOG_DIR must be set}"
    : "${OUTPUT_REPORT:?OUTPUT_REPORT must be set}"
    : "${ERROR_PATTERN:?ERROR_PATTERN must be set}"
    : "${EMAIL_RECIPIENT:?EMAIL_RECIPIENT must be set}"
    : "${MAX_LOG_SIZE_MB:?MAX_LOG_SIZE_MB must be set}"
}

# Check log file size
check_log_size() {
    local log_file=$1
    local size_mb
    size_mb=$(du -m "$log_file" | cut -f1)
    if [ "$size_mb" -gt "$MAX_LOG_SIZE_MB" ]; then
        log "Warning: $log_file exceeds ${MAX_LOG_SIZE_MB}MB ($size_mb MB)"
        return 1
    fi
    return 0
}

# Analyze logs
analyze_logs() {
    local service=$1
    local log_file=$2
    local error_count
    local critical_lines

    log "Analyzing logs for $service from $log_file"
    if ! check_log_size "$log_file"; then
        return 1
    fi

    # Count errors
    error_count=$(grep -c "$ERROR_PATTERN" "$log_file" || true)
    echo "Service: $service" >> "$OUTPUT_REPORT"
    echo "Error Count: $error_count" >> "$OUTPUT_REPORT"

    # Extract critical lines
    critical_lines=$(grep "$ERROR_PATTERN" "$log_file" | tail -n 5)
    if [ -n "$critical_lines" ]; then
        echo "Recent Errors:" >> "$OUTPUT_REPORT"
        echo "$critical_lines" >> "$OUTPUT_REPORT"
    fi
    echo "----------------------------------------" >> "$OUTPUT_REPORT"
}

# Send report via email
send_report() {
    if [ -f "$OUTPUT_REPORT" ]; then
        log "Sending report to $EMAIL_RECIPIENT"
        if mail -s "Log Analysis Report $(date +%F)" "$EMAIL_RECIPIENT" < "$OUTPUT_REPORT"; then
            log "Report sent successfully"
        else
            log "Failed to send email"
            return 1
        fi
    else
        log "No report generated, skipping email"
    fi
}

main() {
    load_config
    log "Starting log analysis"
    mkdir -p "$(dirname "$OUTPUT_REPORT")"
    : > "$OUTPUT_REPORT"

    # Iterate through log files
    shopt -s nullglob
    for log_file in "$LOG_DIR"/*.log; do
        if [ -f "$log_file" ]; then
            service=$(basename "$log_file" .log)
            analyze_logs "$service" "$log_file"
        fi
    done

    # Send report
    send_report
    log "Log analysis completed. Report saved to $OUTPUT_REPORT"
}

main "$@"