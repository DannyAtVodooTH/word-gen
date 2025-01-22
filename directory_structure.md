# Word Generator Directory Structure

```
word-generator/
├── app/                    # Flask application package
│   ├── __init__.py        # App initialization
│   ├── routes.py          # Web routes
│   └── database.py        # Database operations
│
├── config/                 # Configuration files
│   └── default.yaml       # Default configuration
│
├── scripts/               # Development scripts
│   ├── generate_icons.py  # Icon generation script
│   ├── requirements.txt   # Script dependencies
│   ├── setup.sh          # Script environment setup
│   └── README.md         # Script documentation
│
├── static/                # Static web assets
│   ├── icon.svg          # Source SVG icon
│   ├── icon-16.png       # Generated icons
│   ├── icon-32.png
│   ├── icon-180.png
│   ├── icon-192.png
│   ├── icon-512.png
│   ├── favicon.ico
│   ├── manifest.json     # PWA manifest
│   └── sw.js            # Service worker
│
├── tests/                 # Test suite
│   ├── __init__.py
│   └── test_app.py       # Application tests
│
├── venv/                  # Virtual environment (gitignored)
├── .gitignore            # Git ignore file
├── install.sh            # Installation script
├── install_service.sh    # Service installation script
├── project_overview.md   # Project overview
├── project-history.md    # Detailed development history
├── README.md            # Project documentation
├── requirements.txt     # Project dependencies
├── run.py              # Application entry point
└── word-generator.service # Systemd service file
``` 