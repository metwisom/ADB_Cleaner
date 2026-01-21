# 🧹 ADB Cleaner v2.0 - Go Edition

> Modern Android Debloat Tool with TUI Interface

## 📖 Overview

**ADB Cleaner v2.0** is a complete rewrite of the original ADB Cleaner in Go, featuring a modern Terminal User Interface (TUI) with keyboard and mouse support. This version provides a more user-friendly experience with enhanced features and better cross-platform support.

### ✨ New Features

- 🎨 **Modern TUI Interface** - Beautiful terminal UI with colors and smooth navigation
- ⌨️ **Keyboard & Mouse Support** - Intuitive controls for all operations
- 🔍 **Search & Filter** - Quickly find packages by name or description
- 📊 **Real-time Progress** - Visual progress bar during debloating
- 💾 **Backup System** - Save and restore package selections
- 🎯 **Risk Levels** - Packages categorized by safety (SAFE, RISKY, DANGER)
- 📱 **Device Detection** - Automatic device information display
- 🌐 **Cross-platform** - Windows, Linux, macOS (ARM64 and AMD64)

---

## 🚀 Quick Start

### Prerequisites

1. **Go 1.21+** - Download from [golang.org](https://golang.org/dl/)
2. **ADB** - Android Debug Bridge must be installed and in PATH
3. **USB Debugging** - Enabled on your Android device

### Installation

#### From Source

```bash
# Clone the repository
git clone https://github.com/adb-cleaner/adb-cleaner.git
cd adb-cleaner

# Download dependencies
go mod download

# Build for your platform
go build -o adb-cleaner ./cmd/adb-cleaner

# Run
./adb-cleaner
```

#### Using Make (Linux/macOS)

```bash
# Build for current platform
make build

# Build for all platforms
make all

# Run
make run
```

#### Using Build Scripts

**Linux/macOS:**
```bash
chmod +x scripts/build.sh
./scripts/build.sh --linux
```

**Windows:**
```cmd
scripts\build.bat --windows
```

---

## 🎮 Usage

### Starting the Application

```bash
# Linux/macOS
./adb-cleaner

# Windows
adb-cleaner.exe
```

### Keyboard Controls

| Key | Action |
|-----|--------|
| `↑` / `↓` or `K` / `J` | Navigate package list |
| `Space` | Toggle package selection |
| `F1` | Select all packages |
| `F2` | Deselect all packages |
| `F3` | Select only installed packages |
| `F4` | Select only SAFE packages |
| `F5` | Enter search mode |
| `Enter` | Confirm selection / Start debloating |
| `Esc` | Go back / Exit search mode |
| `Ctrl+C` | Quit application |

### Mouse Controls

- **Click** on packages to toggle selection
- **Click** on buttons to navigate
- **Scroll** to move through the list

---

## 📁 Project Structure

```
adb-cleaner/
├── cmd/
│   └── adb-cleaner/       # Application entry point
│       └── main.go
├── internal/
│   ├── adb/               # ADB client implementation
│   │   └── client.go
│   ├── config/            # Configuration management
│   │   └── config.go
│   ├── packages/          # Package management
│   │   └── manager.go
│   └── ui/                # TUI interface
│       └── app.go
├── pkg/                   # Public packages (if any)
├── scripts/               # Build scripts
│   ├── build.sh          # Linux/macOS build script
│   └── build.bat         # Windows build script
├── packs/                # Package lists
│   ├── safe.txt          # Safe packages
│   └── manufacturer/    # Manufacturer-specific lists
│       └── xiaomi.txt
├── configs/              # Configuration files
├── go.mod               # Go module definition
├── go.sum               # Go module checksums
├── Makefile             # Make targets
├── LICENSE              # MIT License
└── README_GO.md         # This file
```

---

## ⚙️ Configuration

### Config File

Create a `config.json` file in the project root:

```json
{
  "adbPath": "adb",
  "packagesFile": "packs.txt",
  "logDir": "logs",
  "backupDir": "backups",
  "userId": "0",
  "theme": "default",
  "autoSelectSafe": false
}
```

### Configuration Options

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `adbPath` | string | `"adb"` | Path to ADB executable |
| `packagesFile` | string | `"packs.txt"` | Path to packages list file |
| `logDir` | string | `"logs"` | Directory for log files |
| `backupDir` | string | `"backups"` | Directory for backup files |
| `userId` | string | `"0"` | Android user ID |
| `theme` | string | `"default"` | UI theme |
| `autoSelectSafe` | bool | `false` | Auto-select safe packages |

---

## 📦 Package Lists

### Format

Package lists support metadata in the following format:

```
# Comments start with #
com.example.package # Description | Category | RiskLevel
```

### Risk Levels

- **SAFE** - Generally safe to remove
- **RISKY** - May affect some features
- **DANGER** - Can cause system instability

### Example

```
# Safe packages
com.miui.gallery # MIUI Gallery | Apps | SAFE
com.miui.weather2 # MIUI Weather | Apps | SAFE

# Risky packages
com.miui.cloudservice # MIUI Cloud Service | System | RISKY

# Dangerous packages
com.miui.daemon # MIUI Daemon (DO NOT REMOVE) | System | DANGER
```

---

## 🔧 Building

### Build for Current Platform

```bash
go build -o adb-cleaner ./cmd/adb-cleaner
```

### Build for Specific Platforms

**Linux (AMD64):**
```bash
GOOS=linux GOARCH=amd64 go build -o adb-cleaner-linux ./cmd/adb-cleaner
```

**macOS (Apple Silicon):**
```bash
GOOS=darwin GOARCH=arm64 go build -o adb-cleaner-macos ./cmd/adb-cleaner
```

**Windows (AMD64):**
```bash
GOOS=windows GOARCH=amd64 go build -o adb-cleaner.exe ./cmd/adb-cleaner
```

### Using Make

```bash
# Show all available targets
make help

# Build for current platform
make build

# Build for all platforms
make all

# Clean build directory
make clean

# Run tests
make test

# Format code
make fmt

# Run linter
make lint
```

### Using Build Scripts

**Linux/macOS:**
```bash
# Build for Linux
./scripts/build.sh --linux

# Build for all platforms
./scripts/build.sh --all

# Clean build directory
./scripts/build.sh --clean
```

**Windows:**
```cmd
REM Build for Windows
scripts\build.bat --windows

REM Build for all platforms
scripts\build.bat --all

REM Clean build directory
scripts\build.bat --clean
```

---

## 🧪 Development

### Running Tests

```bash
go test ./...
```

### Code Formatting

```bash
go fmt ./...
```

### Linting

```bash
# Install golangci-lint
curl -sSfL https://raw.githubusercontent.com/golangci/golangci-lint/master/install.sh | sh -s -- -b $(go env GOPATH)/bin

# Run linter
golangci-lint run
```

### Adding New Features

The project follows the Standard Go Project Layout:

- `cmd/` - Application entry points
- `internal/` - Private application code
- `pkg/` - Public libraries
- `scripts/` - Build and utility scripts

---

## 🐛 Troubleshooting

### ADB Not Found

```
Error: ADB not found. Please install ADB and add it to PATH.
```

**Solution:** Install ADB for your platform:

**Ubuntu/Debian:**
```bash
sudo apt install android-tools-adb
```

**Arch Linux:**
```bash
sudo pacman -S android-tools
```

**Fedora:**
```bash
sudo dnf install android-tools
```

**macOS:**
```bash
brew install android-platform-tools
```

**Windows:**
Download from [developer.android.com](https://developer.android.com/studio/releases/platform-tools)

### Device Not Connected

```
Error: No device found or device not authorized.
```

**Solution:**
1. Connect your device via USB
2. Enable USB Debugging in Developer Options
3. Accept the debugging prompt on your device

### Build Errors

```
error: cannot find package "github.com/charmbracelet/bubbletea"
```

**Solution:**
```bash
go mod download
go mod tidy
```

---

## 📊 Comparison with Original Version

| Feature | Original (Bash) | Go Version |
|---------|-----------------|------------|
| Interface | CLI | TUI |
| Mouse Support | No | Yes |
| Real-time Progress | No | Yes |
| Search & Filter | No | Yes |
| Package Categorization | No | Yes |
| Cross-platform Build | Manual | Automated |
| Binary Distribution | No | Yes |
| Configuration | None | JSON |

---

## 🤝 Contributing

We welcome contributions! Please follow these steps:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

### Development Guidelines

- Follow Go best practices and conventions
- Write tests for new features
- Update documentation as needed
- Ensure code passes linting (`make lint`)

---

## 📄 License

This project is distributed under the MIT License. See [LICENSE](LICENSE) for details.

---

## 🙏 Acknowledgments

- [Bubble Tea](https://github.com/charmbracelet/bubbletea) - TUI framework
- [Lip Gloss](https://github.com/charmbracelet/lipgloss) - Styling library
- [Bubbles](https://github.com/charmbracelet/bubbles) - TUI components
- Original ADB Cleaner project

---

## 📞 Support

- 📖 [Documentation](README_GO.md)
- 🐛 [Report Issues](https://github.com/adb-cleaner/adb-cleaner/issues)
- 💬 [Discussions](https://github.com/adb-cleaner/adb-cleaner/discussions)

---

**Built with ❤️ using Go**
