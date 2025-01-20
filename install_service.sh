#!/bin/bash

# Exit on error
set -e

# Check if running as root
if [ "$EUID" -ne 0 ]; then 
    echo "Please run as root"
    exit 1
fi

# Create word-gen user and group
echo "Creating word-gen user and group..."
if ! id "word-gen" &>/dev/null; then
    useradd -r -s /bin/false word-gen
fi

# Create application directory
echo "Creating application directory..."
mkdir -p /opt/word-gen
mkdir -p /etc/word-gen

# Copy application files
echo "Copying application files..."
cp -r app static tests requirements.txt run.py install.sh /opt/word-gen/

# Create and copy config file
echo "Creating configuration file..."
cat > /etc/word-gen/config.yaml << EOL
server:
  host: "127.0.0.1"
  port: 5050
database:
  path: "/opt/word-gen/data/words.db"
EOL

# Create data directory and download words file
echo "Setting up data directory..."
mkdir -p /opt/word-gen/data
if [ ! -f /opt/word-gen/data/words.txt ]; then
    echo "Downloading words.txt..."
    curl -o /opt/word-gen/data/words.txt https://www.cs.utexas.edu/~mitra/csFall2022/cs313/assgn/words.txt
fi

# Set up virtual environment
echo "Setting up virtual environment..."
cd /opt/word-gen
python3 -m venv venv
source venv/bin/activate
pip install --upgrade pip
pip install -r requirements.txt

# Initialize database
echo "Initializing database..."
python run.py --init --config /etc/word-gen/config.yaml

# Copy systemd service file
echo "Installing systemd service..."
cp word-generator.service /etc/systemd/system/

# Set permissions
echo "Setting permissions..."
chown -R word-gen:word-gen /opt/word-gen
chown -R word-gen:word-gen /etc/word-gen
chmod 755 /opt/word-gen
chmod 755 /etc/word-gen
chmod 644 /etc/word-gen/config.yaml
chmod 644 /etc/systemd/system/word-generator.service

# Reload systemd and enable service
echo "Enabling and starting service..."
systemctl daemon-reload
systemctl enable word-generator
systemctl start word-generator

echo "Installation complete!"
echo "Service status:"
systemctl status word-generator 