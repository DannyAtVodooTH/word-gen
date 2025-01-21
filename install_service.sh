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
$PYTHON_CMD -m venv venv
source venv/bin/activate
pip install --upgrade pip
pip install -r requirements.txt

# Initialize database
echo "Initializing database..."
python run.py --init --config /etc/word-gen/config.yaml

# Copy systemd service file
echo "Installing systemd service..."
cp word-generator.service /etc/systemd/system/

# Prompt for domain name
read -p "Enter base domain (default: v-odoo.com): " BASE_DOMAIN
BASE_DOMAIN=${BASE_DOMAIN:-v-odoo.com}
DOMAIN="word-gen.${BASE_DOMAIN}"

# Install and configure nginx
echo "Setting up nginx configuration..."

# Create Cloudflare realip configuration
if [ ! -f "/etc/nginx/cloudflare_realip" ]; then
    echo "Creating Cloudflare realip configuration..."
    cat > "/etc/nginx/cloudflare_realip" << 'EOL'
    # nginx Cloudflare realip
    #
    
    set_real_ip_from 103.21.244.0/22;
    set_real_ip_from 103.22.200.0/22;
    set_real_ip_from 103.31.4.0/22;
    set_real_ip_from 104.16.0.0/12;
    set_real_ip_from 108.162.192.0/18;
    set_real_ip_from 131.0.72.0/22;
    set_real_ip_from 141.101.64.0/18;
    set_real_ip_from 162.158.0.0/15;
    set_real_ip_from 172.64.0.0/13;
    set_real_ip_from 173.245.48.0/20;
    set_real_ip_from 188.114.96.0/20;
    set_real_ip_from 190.93.240.0/20;
    set_real_ip_from 197.234.240.0/22;
    set_real_ip_from 198.41.128.0/17;
    set_real_ip_from 2400:cb00::/32;
    set_real_ip_from 2606:4700::/32;
    set_real_ip_from 2803:f800::/32;
    set_real_ip_from 2405:b500::/32;
    set_real_ip_from 2405:8100::/32;
    set_real_ip_from 2c0f:f248::/32;
    set_real_ip_from 2a06:98c0::/29;
    
    real_ip_header CF-Connecting-IP;
EOL
    chmod 644 "/etc/nginx/cloudflare_realip"
    echo "Created Cloudflare realip configuration."
else
    echo "Cloudflare realip configuration already exists, skipping."
fi

if ! command -v nginx &> /dev/null; then
    echo "Installing nginx..."
    if command -v apt-get &> /dev/null; then
        apt-get update
        apt-get install -y nginx
    elif command -v dnf &> /dev/null; then
        dnf install -y nginx
    else
        echo "Error: Neither apt-get nor dnf found. Please install nginx manually."
        exit 1
    fi
    echo "Nginx installed successfully."
else
    echo "Nginx already installed, skipping installation."
fi

# Create nginx configuration
echo "Creating nginx configuration..."
cat > "/etc/nginx/conf.d/${DOMAIN}.conf" << EOL
server {
    listen 80;
    server_name ${DOMAIN};

    include cloudflare_realip;

    access_log /var/log/nginx/word-gen.access.log;
    error_log /var/log/nginx/word-gen.error.log;

    location / {
        proxy_pass http://127.0.0.1:5050;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
        proxy_set_header CF-Connecting-IP \$http_cf_connecting_ip;
        proxy_set_header X-Forwarded-Host \$host;
        proxy_set_header X-Forwarded-Server \$host;
    }

    location /static/ {
        alias /opt/word-gen/static/;
        expires 1h;
        add_header Cache-Control "public, no-transform";
    }
}
EOL

# Test nginx configuration
echo "Testing nginx configuration..."
nginx -t

# Reload nginx
echo "Reloading nginx..."
if systemctl is-active nginx >/dev/null 2>&1; then
    systemctl reload nginx
else
    systemctl start nginx
fi

# Set permissions
echo "Setting permissions..."
chown -R word-gen:word-gen /opt/word-gen
chown -R word-gen:word-gen /etc/word-gen
chmod 755 /opt/word-gen
chmod 755 /etc/word-gen
chmod 644 /etc/word-gen/config.yaml
chmod 644 /etc/systemd/system/word-generator.service
chmod 644 "/etc/nginx/conf.d/${DOMAIN}.conf"

# Reload systemd and enable service
echo "Enabling and starting service..."
systemctl daemon-reload
systemctl enable word-generator
systemctl start word-generator

# Add hosts entry suggestion
echo ""
echo "Installation complete! To access the application:"
echo "1. Add the following line to your /etc/hosts file:"
echo "   127.0.0.1 ${DOMAIN}"
echo "2. Access the application at: http://${DOMAIN}"
echo "" 