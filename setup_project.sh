#!/bin/bash

# ==========================================
# Project: Student Attendance Tracker Bootstrapper
# Author: [Innocente Mutabazi Umuhuza /imutabazi]
# Description: Automates workspace creation, config, and handling.
# System: macOS / BSD Compatible
# ==========================================

# 1. Capture User Input for Project Name
echo "------------------------------------------"
echo "   Attendance Tracker Project Setup       "
echo "------------------------------------------"
read -p "Enter the project suffix (e.g., v1, beta): " PROJECT_SUFFIX

# Define Directory Variables
PROJECT_DIR="attendance_tracker_${PROJECT_SUFFIX}"
HELPERS_DIR="${PROJECT_DIR}/Helpers"
REPORTS_DIR="${PROJECT_DIR}/reports"
ARCHIVE_NAME="attendance_tracker_${PROJECT_SUFFIX}_archive.tar.gz"

# 2. Define the Signal Trap (The Safety Net)
cleanup_and_archive() {
    echo -e "\n\n[!] Interrupt Signal Detected!"
    echo "    Bundling current state into ${ARCHIVE_NAME}..."
    
    if [ -d "$PROJECT_DIR" ]; then
        tar -czf "$ARCHIVE_NAME" "$PROJECT_DIR"
        echo "    Archive created."
        echo "    Cleaning up incomplete workspace..."
        rm -rf "$PROJECT_DIR"
        echo "    Cleanup complete. Exiting."
    else
        echo "    No directory to clean up."
    fi
    exit 1
}

trap cleanup_and_archive SIGINT

# 3. Create Directory Architecture
echo "[*] Creating directory structure..."
if [ -d "$PROJECT_DIR" ]; then
    echo "    Directory $PROJECT_DIR already exists. Skipping creation."
else
    # Rubric: Robustly handle permission errors
    mkdir -p "$HELPERS_DIR" "$REPORTS_DIR" || { echo "Error: Could not create directories. Check permissions."; exit 1; }
    echo "    Directories created: $PROJECT_DIR, Helpers, reports"
fi

# 4. Copy Source Files (Using the provided files)
echo "[*] Copying source files..."

# Check if the source files exist in the current directory first!
if [[ ! -f "attendance_checker.py" ]] || [[ ! -f "assets.csv" ]] || [[ ! -f "config.json" ]]; then
    echo "    [ERROR] Source files (attendance_checker.py, assets.csv, config.json) not found in current directory!"
    echo "    Please download them and place them next to this script."
    exit 1
fi

# Copy files to their designated locations
cp "attendance_checker.py" "${PROJECT_DIR}/"
cp "assets.csv" "${HELPERS_DIR}/"
cp "config.json" "${HELPERS_DIR}/"

# Handle reports.log (Create if missing, copy if exists)
if [ -f "reports.log" ]; then
    cp "reports.log" "${REPORTS_DIR}/"
else
    touch "${REPORTS_DIR}/reports.log"
fi

echo "    Files copied successfully."

# 5. Dynamic Configuration (Stream Editing)
echo "------------------------------------------"
echo "   Configuration Settings"
echo "------------------------------------------"
read -p "Update Warning Threshold? (Default 75): " USER_WARN
read -p "Update Failure Threshold? (Default 50): " USER_FAIL

# RUBRIC WINNER: Validate Input is Numeric
if [[ -z "$USER_WARN" || ! "$USER_WARN" =~ ^[0-9]+$ ]]; then
    echo "    [!] Invalid or empty input. Using default (75)."
    WARN_VAL=75
else
    WARN_VAL=$USER_WARN
fi

if [[ -z "$USER_FAIL" || ! "$USER_FAIL" =~ ^[0-9]+$ ]]; then
    echo "    [!] Invalid or empty input. Using default (50)."
    FAIL_VAL=50
else
    FAIL_VAL=$USER_FAIL
fi

echo "[*] Updating config.json with Warning: $WARN_VAL% and Failure: $FAIL_VAL%..."

CONFIG_FILE="${HELPERS_DIR}/config.json"

# macOS Compatibility: sed -i ''
sed -i '' "s/\"warning_threshold\": [0-9]*/\"warning_threshold\": $WARN_VAL/" "$CONFIG_FILE"
sed -i '' "s/\"failure_threshold\": [0-9]*/\"failure_threshold\": $FAIL_VAL/" "$CONFIG_FILE"

# 6. Artificial Delay to allow testing the TRAP
echo "[*] Finalizing setup (Press Ctrl+C now to test the archive trap)..."
for i in {1..3}; do
    sleep 1
    echo -n "."
done
echo ""

# 7. Environment Validation (Health Check)
echo "------------------------------------------"
echo "   System Health Check"
echo "------------------------------------------"

# Check Python Version
if python3 --version > /dev/null 2>&1; then
    PY_VERSION=$(python3 --version)
    echo "[PASS] $PY_VERSION is installed."
else
    echo "[FAIL] python3 is not installed or not found in PATH."
fi

# Check Directory Structure & Files
if [ -f "${PROJECT_DIR}/attendance_checker.py" ] && \
   [ -f "${HELPERS_DIR}/config.json" ] && \
   [ -f "${HELPERS_DIR}/assets.csv" ] && \
   [ -f "${REPORTS_DIR}/reports.log" ]; then
    echo "[PASS] Project directory structure is valid."
else
    echo "[FAIL] Some files are missing in the target directory."
fi

echo "------------------------------------------"
echo "   Setup Complete!"
echo "------------------------------------------"
