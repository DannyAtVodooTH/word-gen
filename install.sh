#!/bin/bash

# Exit on error
set -e

echo "Creating Python virtual environment..."
python3 -m venv venv

# Activate virtual environment
echo "Activating virtual environment..."
source venv/bin/activate

# Upgrade pip
echo "Upgrading pip..."
pip install --upgrade pip

# Install requirements
echo "Installing requirements..."
pip install -r requirements.txt

# Create data directory if it doesn't exist
echo "Creating data directory..."
mkdir -p data

# Check if words.txt exists, if not create a sample one
if [ ! -f data/words.txt ]; then
    echo "Downloading words.txt from UT Austin..."
    curl -o data/words.txt https://www.cs.utexas.edu/~mitra/csFall2022/cs313/assgn/words.txt
    if [ $? -ne 0 ]; then
        echo "Error downloading words.txt. Creating sample file instead..."
        cat > data/words.txt << EOL
hello
world
python
programming
computer
science
database
network
system
software
developer
engineer
EOL
    fi
fi

# Initialize the database
echo "Initializing database..."
python run.py --init

echo "Installation complete!"
echo "To activate the virtual environment, run: source venv/bin/activate"
echo "To start the application, run: python run.py"

# Install pytest-cov
echo "Installing pytest-cov..."
pip install pytest-cov

# Run tests with coverage
echo "Running tests with coverage..."
python -m pytest --cov=app tests/ 

