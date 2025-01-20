# Word Generator Web Application

[![Tests](https://github.com/DannyAtVodooTH/word-generator/actions/workflows/tests.yml/badge.svg)](https://github.com/DannyAtVodooTH/word-generator/actions/workflows/tests.yml)
[![codecov](https://codecov.io/gh/DannyAtVodooTH/word-generator/branch/main/graph/badge.svg)](https://codecov.io/gh/DannyAtVodooTH/word-generator)

A Flask-based web application that generates random words based on specified length and count. The application stores words in a SQLite database and provides both a web interface and REST API for generating random word combinations.

## Features

- Generate random words based on specified length and count
- Web interface for easy interaction
- REST API for programmatic access
- SQLite database for word storage
- Command-line options for database initialization and configuration
- Unit tests for core functionality

## Directory Structure

```
word-generator/
├── app/
│   ├── __init__.py
│   ├── database.py      # SQLite database operations
│   ├── word_service.py  # Word generation service
│   └── webapp.py        # Flask web application
├── static/
│   └── index.html       # Web interface
├── tests/
│   ├── __init__.py
│   ├── test_database.py
│   └── test_word_service.py
├── data/
│   └── words.txt        # Source words file
├── requirements.txt
├── install.sh
├── README.md
└── run.py
```

## Quick Start

1. Clone the repository and navigate to the directory:
```bash
git clone https://github.com/yourusername/word-generator.git
cd word-generator
```

2. Run the installation script:
```bash
chmod +x install.sh
./install.sh
```

3. Start the application:
```bash
source venv/bin/activate
python run.py
```

The web interface will be available at `http://127.0.0.1:5050`

### test

```bash
$> curl -X POST http://127.0.0.1:5050/words \
     -H "Content-Type: application/json" \
     -d '{"wordLength": 8, "numberOfWords": 2}'
{"words":"flangers-firewood"}
```

## Manual Installation

If you prefer to install manually:

1. Create and activate virtual environment:
```bash
python3 -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate
```

2. Install dependencies:
```bash
pip install -r requirements.txt
```

3. Initialize the database:
```bash
python run.py --init
```

## Command Line Options

- `--init`: Initialize database with words from data/words.txt
- `--dbname`: Specify SQLite database filename (default: words.db)
- `--config`: Path to YAML configuration file

Example:
```bash
python run.py --init --dbname custom.db

# Or with config file:
python run.py --config config/default.yaml
```

## Configuration File

The application uses configuration from config/default.yaml by default. You can override these settings by providing your own config file with the --config option.

Default configuration (config/default.yaml):

```yaml
server:
  host: "127.0.0.1"
  port: 5050
database:
  path: "data/words.db"
```

To override settings, create your own YAML file with the desired values and use the --config option:

```bash
python run.py --config my_config.yaml
```

You only need to specify the values you want to override. Unspecified values will use the defaults from config/default.yaml.

## System Service Installation

To install the application as a system service:

```bash
sudo ./install_service.sh
```

This will:
1. Create a word-gen user
2. Install the application in /opt/word-gen
3. Create configuration in /etc/word-gen
4. Set up and enable systemd service
5. Download word list and initialize database

### Installation Details

The service installation:
- Creates a dedicated system user 'word-gen'
- Installs application files to `/opt/word-gen/`
- Creates configuration in `/etc/word-gen/config.yaml`
- Downloads word list from UT Austin CS department
- Sets up a Python virtual environment
- Initializes the database in `/opt/word-gen/data/words.db`
- Configures systemd service to run as 'word-gen' user

Service management commands:
```bash
sudo systemctl start word-generator
sudo systemctl stop word-generator
sudo systemctl restart word-generator
sudo systemctl status word-generator
```

### File Locations

- Configuration: `/etc/word-gen/config.yaml`
- Application: `/opt/word-gen/`
- Database: `/opt/word-gen/data/words.db`
- Word list: `/opt/word-gen/data/words.txt`
- Service file: `/etc/systemd/system/word-generator.service`

### Default Service Configuration

```yaml
server:
  host: "127.0.0.1"
  port: 5050
database:
  path: "/opt/word-gen/data/words.db"
```

To modify the service configuration, edit `/etc/word-gen/config.yaml` and restart the service:
```bash
sudo nano /etc/word-gen/config.yaml
sudo systemctl restart word-generator
```

## Dependencies

- Flask: Web framework
- SQLAlchemy: Database ORM
- Alembic: Database migrations
- pytest: Testing framework


## Development

```

```

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.