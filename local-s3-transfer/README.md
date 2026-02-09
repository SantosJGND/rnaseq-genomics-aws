# Local S3 Transfer Service

## Overview

File synchronization service for automated data transfer between local storage systems and Amazon S3.

Attention: This service is currently defined for local transfer for demonstration purposes - see `transfer.sh`.

Script is designed to recognize changes in a local directory and synchronize them to an S3 bucket. For the purpose of local testing, a new source directory must be created and specified in the .env file.

## Architecture

The service implements the following components:

- **File System Monitor**: Continuous directory watching for file changes
- **Transfer Engine**: rclone-based S3 synchronization with multi-part uploads
- **Logging System**: Comprehensive audit trail and performance metrics
- **Configuration Manager**: Environment-based parameter management

## System Requirements

### Software Dependencies

- **rclone**: 1.55+ (S3 synchronization)

## Installation and Configuration

### 1. Environment Setup

```bash
# Clone the repository
git clone <repository-url>
cd local-s3-transfer

# Configure environment variables
cp .env.example .env
nano .env # for the purpose of local testing, define source as ../data/data
```

### 2. rclone Installation and Configuration

```bash
# Install rclone (Ubuntu/Debian)
sudo apt update && sudo apt install rclone

# Install rclone (CentOS/RHEL)
sudo yum install epel-release && sudo yum install rclone

# Configure S3 remote
rclone config
# Follow prompts to create S3 remote with the name specified in .env
```

### 3. Service Deployment

```bash

# for the purpose of local testing:
mkdir -p ../data/data

# Start the transfer service
./service.sh start

# Verify service status
./service.sh status

# for the purpose of local testing:
cp -r ../data/test_data/* ../data/data/

```

## Configuration Parameters

### Environment Variables (.env)

```bash
# S3 Configuration
S3_REMOTE_NAME=mys3
S3_BUCKET_NAME=data-bucket
S3_PATH=backup/

# Local Configuration
LOCAL_SOURCE_PATH=/data/input
MONITOR_INTERVAL=30

# Transfer Parameters
CHUNK_SIZE=128M
CONCURRENT_TRANSFERS=4
MAX_RETRIES=3

# Logging Configuration
LOG_FILE=transfer.log
```

### Advanced Configuration

**Performance Tuning**:

- Increase `CONCURRENT_TRANSFERS` for high-bandwidth connections
- Adjust `CHUNK_SIZE` based on file size distribution
- Modify `MONITOR_INTERVAL` for real-time vs. resource-efficient operation

## Service Management

### Standard Operations

```bash
./service.sh start      # Start continuous transfer service
./service.sh stop       # Stop the service gracefully
./service.sh restart    # Restart the service
./service.sh status     # Check service status and statistics
./service.sh logs       # View live logs with tail -f
```
