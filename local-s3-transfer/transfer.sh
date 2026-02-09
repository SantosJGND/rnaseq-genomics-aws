#!/bin/bash

# Continuous Local to S3 Transfer Script
# Uses rclone for data synchronization with monitoring

set -euo pipefail

# Load environment variables
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ENV_FILE="${SCRIPT_DIR}/.env"

if [[ ! -f "$ENV_FILE" ]]; then
    echo "Error: .env file not found. Please copy .env.example to .env and configure."
    exit 1
fi

# Source environment variables
set -a
source "$ENV_FILE"
set +a

# Validate required variables
required_vars=("LOCAL_SOURCE_DIR" "S3_BUCKET" "S3_REMOTE_NAME" "MONITOR_INTERVAL" "LOCAL_DEST_DIR")
for var in "${required_vars[@]}"; do
    if [[ -z "${!var:-}" ]]; then
        echo "Error: Required variable $var is not set in .env"
        exit 1
    fi
done

# Setup logging
LOG_FILE="${SCRIPT_DIR}/${LOG_FILE}"
mkdir -p "$(dirname "$LOG_FILE")"

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

# Check if rclone is installed and configured
check_rclone() {
    if ! command -v rclone &> /dev/null; then
        log "Error: rclone is not installed. Please install rclone first."
        exit 1
    fi
}

# Check if local directory exists
check_local_dir() {
    if [[ ! -d "$LOCAL_SOURCE_DIR" ]]; then
        log "Error: Local source directory '$LOCAL_SOURCE_DIR' does not exist."
        exit 1
    fi
}

# Transfer files from local to S3
transfer_to_s3() {
    local source_path="$1"
    local dest_path="${S3_REMOTE_NAME}:${S3_BUCKET}/${2:-}"
    
    log "Starting transfer: $source_path -> $dest_path"
    
    local retry_count=0
    while [[ $retry_count -lt $MAX_RETRIES ]]; do
        if rclone sync "$source_path" "$dest_path" \
            --progress \
            --checksum \
            --create-empty-src-dirs \
            --transfers "$TRANSFERS" \
            --checkers "$CHECKERS" \
            --chunk-size "$CHUNK_SIZE" \
            --log-file "$LOG_FILE" \
            --log-level INFO; then
            
            log "Transfer completed successfully: $source_path -> $dest_path"
            return 0
        else
            retry_count=$((retry_count + 1))
            log "Transfer failed (attempt $retry_count/$MAX_RETRIES). Retrying in 60 seconds..."
            sleep 60
        fi
    done
    
    log "Error: Transfer failed after $MAX_RETRIES attempts: $source_path -> $dest_path"
    return 1
}

# Transfer files from local to another local directory
transfer_to_local() {
    local source_path="$1"
    local dest_path="$LOCAL_DEST_DIR/${2:-}"
    log "$source_path"
    log "$dest_path"

    log "Starting local transfer: $source_path -> $dest_path"
    
    local retry_count=0
    while [[ $retry_count -lt $MAX_RETRIES ]]; do
        if rclone sync "$source_path" "$dest_path" \
            --progress \
            --checksum \
            --create-empty-src-dirs \
            --transfers "$TRANSFERS" \
            --checkers "$CHECKERS" \
            --log-file "$LOG_FILE" \
            --log-level INFO; then
            
            log "Local transfer completed successfully: $source_path -> $dest_path"
            return 0
        else
            retry_count=$((retry_count + 1))
            log "Local transfer failed (attempt $retry_count/$MAX_RETRIES). Retrying in 60 seconds..."
            sleep 60
        fi
    done
    
    log "Error: Local transfer failed after $MAX_RETRIES attempts: $source_path -> $dest_path"
    return 1
}

# Monitor directory for changes and trigger transfers
monitor_and_transfer() {
    log "Starting continuous monitoring of $LOCAL_SOURCE_DIR"
    log "Transfer interval: ${MONITOR_INTERVAL} seconds"
    
    while true; do
        if [[ -n "$(find "$LOCAL_SOURCE_DIR" -type f -newer "$SCRIPT_DIR/.last_transfer" 2>/dev/null || true)" ]]; then
        
            log "Changes detected, initiating transfer..."
            
            # Perform the transfer
            if transfer_to_local "$LOCAL_SOURCE_DIR" ""; then
                # Update last transfer timestamp
                touch "$SCRIPT_DIR/.last_transfer"
                log "Transfer cycle completed successfully"
            else
                log "Transfer cycle failed, will retry in next cycle"
            fi
        else
            log "No changes detected, continuing monitoring..."
        fi
        
        # Wait for next monitoring cycle
        sleep "$MONITOR_INTERVAL"
    done
}

# Initialize last transfer timestamp
init_timestamp() {
    if [[ ! -f "$SCRIPT_DIR/.last_transfer" ]]; then
        touch "$SCRIPT_DIR/.last_transfer"
        log "Initialized transfer timestamp"
    fi
}

# Cleanup function
cleanup() {
    log "Received interrupt signal, shutting down gracefully..."
    exit 0
}

# Main execution
main() {
    log "=== Local to S3 Transfer Service Started ==="
    
    # Setup signal handlers
    trap cleanup SIGINT SIGTERM
    
    # Perform initial checks
    check_rclone
    check_local_dir
    init_timestamp
    
    # Start monitoring
    monitor_and_transfer
}

# Run main function
main "$@"
