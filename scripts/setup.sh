#!/bin/bash

# Exit on error
set -e

# Function to check Python version
check_python_version() {
    local python_cmd=$1
    if ! command -v "$python_cmd" &> /dev/null; then
        return 1
    fi
    local version=$("$python_cmd" -c 'import sys; print(f"{sys.version_info.major}.{sys.version_info.minor}")')
    if (( $(echo "$version >= 3.9" | bc -l) )); then
        echo "$python_cmd (version $version)"
        return 0
    fi
    return 1
}

# Find suitable Python version
echo "Checking for Python version >= 3.9..."
PYTHON_CMD=""
for cmd in python3.11 python3.10 python3.9 python3; do
    if result=$(check_python_version "$cmd"); then
        PYTHON_CMD="$cmd"
        echo "Found suitable Python: $result"
        break
    fi
done

if [ -z "$PYTHON_CMD" ]; then
    echo "Error: No suitable Python version found. Please install Python >= 3.9"
    exit 1
fi

# Create virtual environment if it doesn't exist
if [ ! -d "venv" ]; then
    echo "Creating Python virtual environment..."
    $PYTHON_CMD -m venv venv
fi

# Activate virtual environment
echo "Activating virtual environment..."
source venv/bin/activate

# Install/upgrade pip
echo "Upgrading pip..."
pip install --upgrade pip

# Install system dependencies based on OS
if [[ "$OSTYPE" == "darwin"* ]]; then
    # macOS
    echo "Installing macOS dependencies..."
    if ! command -v brew &> /dev/null; then
        echo "Error: Homebrew is required but not found"
        exit 1
    fi
    
    brew install cairo pango librsvg pkg-config
    
    echo "Setting up environment variables..."
    export PKG_CONFIG_PATH="/opt/homebrew/lib/pkgconfig"
    export LDFLAGS="-L/opt/homebrew/lib"
    export CPPFLAGS="-I/opt/homebrew/include"
elif command -v apt-get &> /dev/null; then
    # Debian/Ubuntu
    echo "Installing Debian/Ubuntu dependencies..."
    sudo apt-get update
    sudo apt-get install -y python3-cairo python3-cairosvg
elif command -v dnf &> /dev/null; then
    # RHEL/CentOS
    echo "Installing RHEL/CentOS dependencies..."
    sudo dnf install -y python3-cairo python3-cairosvg
else
    echo "Warning: Unsupported OS, you may need to install dependencies manually"
fi

# Install Python dependencies
echo "Installing Python dependencies..."
pip install -r requirements.txt

echo ""
echo "Setup complete! To generate icons:"
echo "Run from project root:"
echo "   scripts/venv/bin/python scripts/generate_icons.py"
echo "" 