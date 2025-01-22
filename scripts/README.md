# Development Scripts

This directory contains scripts used during development.

## Icon Generation

The `generate_icons.py` script converts the SVG icon to various PNG sizes and favicon.ico for the web application.

### Requirements

Requires Python 3.9 or newer. The setup script will automatically use the newest available version from:
- Python 3.11
- Python 3.10
- Python 3.9
- python3 (if version >= 3.9)

Run the setup script:
```bash
cd scripts
chmod +x setup.sh
./setup.sh
```

The setup script will:
1. Create a virtual environment with the newest available Python version (>= 3.9)
2. Install required system dependencies
3. Install Python packages
4. Set up environment variables (on macOS)

### Usage

From the project root:
```bash
scripts/venv/bin/python scripts/generate_icons.py
```