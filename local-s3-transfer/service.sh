#!/bin/bash

# Service Management Script for Local S3 Transfer

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TRANSFER_SCRIPT="$SCRIPT_DIR/transfer.sh"
PID_FILE="$SCRIPT_DIR/transfer.pid"
LOG_FILE="$SCRIPT_DIR/transfer.log"

case "$1" in
    start)
        if [[ -f "$PID_FILE" ]] && kill -0 "$(cat "$PID_FILE")" 2>/dev/null; then
            echo "Transfer service is already running (PID: $(cat "$PID_FILE"))"
            exit 1
        fi
        
        echo "Starting transfer service..."
        nohup "$TRANSFER_SCRIPT" > "$LOG_FILE" 2>&1 &
        echo $! > "$PID_FILE"
        echo "Transfer service started (PID: $(cat "$PID_FILE"))"
        ;;
    
    stop)
        if [[ ! -f "$PID_FILE" ]]; then
            echo "Transfer service is not running"
            exit 1
        fi
        
        PID=$(cat "$PID_FILE")
        if kill -0 "$PID" 2>/dev/null; then
            echo "Stopping transfer service (PID: $PID)..."
            kill "$PID"
            rm -f "$PID_FILE"
            echo "Transfer service stopped"
        else
            echo "Transfer service is not running (stale PID file)"
            rm -f "$PID_FILE"
        fi
        ;;
    
    status)
        if [[ -f "$PID_FILE" ]] && kill -0 "$(cat "$PID_FILE")" 2>/dev/null; then
            echo "Transfer service is running (PID: $(cat "$PID_FILE"))"
        else
            echo "Transfer service is not running"
        fi
        ;;
    
    restart)
        "$0" stop
        sleep 2
        "$0" start
        ;;
    
    logs)
        if [[ -f "$LOG_FILE" ]]; then
            tail -f "$LOG_FILE"
        else
            echo "Log file not found: $LOG_FILE"
        fi
        ;;
    
    *)
        echo "Usage: $0 {start|stop|status|restart|logs}"
        exit 1
        ;;
esac