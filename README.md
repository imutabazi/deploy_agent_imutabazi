# Student Attendance Tracker - Deploy Agent

## Overview
This repository contains a shell script (`setup_project.sh`) that acts as a "Project Factory" for the Student Attendance Tracker. It automates the bootstrapping of the Python development environment by creating directories, copying necessary source files, dynamically configuring settings, and enforcing strict process management.

## Project Structure
When executed, the script creates the following structure based on the user's input:

```text
attendance_tracker_{input}/
├── attendance_checker.py   # Main application logic
├── Helpers/
│   ├── assets.csv          # Student data
│   └── config.json         # Configuration settings
└── reports/
    └── reports.log         # Log file

```

## Prerequisites

The following source files must be present in the same directory as the script before running:

* `attendance_checker.py`
* `assets.csv`
* `config.json`
* `reports.log` (optional, script will create if missing)

## How to Run

1. **Clone the repository:**
```bash
git clone [https://github.com/YourUsername/deploy_agent_YourUsername.git](https://github.com/YourUsername/deploy_agent_YourUsername.git)
cd deploy_agent_YourUsername

```


2. **Make the script executable:**
```bash
chmod +x setup_project.sh

```


3. **Run the script:**
```bash
./setup_project.sh

```


4. **Follow the prompts:**
* Enter a project suffix (e.g., `v1`).
* Enter new threshold values for Warning and Failure.



## Key Features & Logic

### 1. Robust Directory Automation

The script checks if the target directory already exists to prevent overwriting. It creates the `Helpers` and `reports` directories and securely copies the source files into their designated locations.

### 2. Dynamic Configuration with Validation

* **Input Validation:** The script validates that the user inputs **numeric values** for the thresholds.
* **Edge Case Handling:** If the user enters non-numeric text or leaves the input empty, the script automatically defaults to standard values (Warning: 75, Failure: 50).
* **Stream Editing:** It uses `sed` to update `config.json` in-place without opening the file manually.

### 3. Process Management (The "Safety Net")

The script implements a **Signal Trap** for `SIGINT` (Ctrl+C).

* **Trigger:** If the user interrupts the script mid-execution (during the sleep phase).
* **Action:** The script immediately catches the signal, bundles the incomplete directory into a tarball (e.g., `attendance_tracker_v1_archive.tar.gz`), and deletes the messy folder to keep the workspace clean.

### 4. Environment Validation

Before finishing, the script runs a health check to verify:

* That `python3` is installed and accessible.
* That all required files were successfully copied and exist in the correct paths.

## Compatibility Note (macOS vs Linux)

This script was developed on **macOS**. It uses the BSD-compatible syntax for `sed`:

```bash
sed -i '' "s/search/replace/" filename

```

If running on a standard Linux environment, the empty string argument (`''`) should be removed.
