# 🧹 ADB Cleaner - Android Debloat Tool

> Effective solution for removing pre-installed applications from Android devices

## Description

**ADB Cleaner** is a cross-platform tool for removing unnecessary pre-installed applications from Android devices. Works without root access via ADB (Android Debug Bridge).

### Key Features:
- 🗑️ **Remove** pre-installed applications
- 💻 **Cross-platform** — Windows, Linux, macOS
- 📱 **Device support** — Xiaomi, Samsung and others
- 🛡️ **Safety** — removal only for current user
- ⚡ **Simplicity** — one command execution

## 🚀 Quick Start

### Requirements:

1. **ADB (Android Debug Bridge)** — installed and added to PATH
2. **USB Debugging** — enabled in Android device settings
3. **USB Cable** — to connect device to computer

### Installing ADB:

#### Windows
```powershell
# Via Chocolatey
choco install adb

# Or download Android SDK Platform Tools
# https://developer.android.com/studio/releases/platform-tools
```

#### Linux
```bash
# Ubuntu/Debian
sudo apt install android-tools-adb

# Arch Linux
sudo pacman -S android-tools

# Fedora
sudo dnf install android-tools
```

#### macOS
```bash
# Via Homebrew
brew install android-platform-tools
```

### Usage:

#### Windows
```powershell
# Run debloat
.\debloat.bat

# Get list of installed applications
.\applist.bat
```

#### Linux/macOS
```bash
# Make scripts executable
chmod +x debloat.sh applist.sh

# Run debloat
./debloat.sh

# Get list of installed applications
./applist.sh
```

It is recommended to reboot the device after running the script.

## 📁 Project Structure

```
ADB_Cleaner/
├── 📄 README.md              # Documentation
├── 🔧 debloat.bat           # Windows debloat script
├── 🔧 debloat.sh            # Unix debloat script
├── 📋 applist.bat           # Windows app list script
├── 📋 applist.sh            # Unix app list script
├── 📝 packs.txt             # List of packages to remove
├── 📱 app_list.txt          # List of installed applications
├── 🛠️ adb.exe              # ADB for Windows
├── 🔗 AdbWinApi.dll         # Windows ADB library
└── 🔗 AdbWinUsbApi.dll      # Windows USB ADB library
```

## ⚙️ Configuration

### Editing Package List

Edit the `packs.txt` file to configure the list of applications to remove:

```txt
# Example packs.txt content
com.android.bips                    # Bluetooth printing
com.google.android.apps.wellbeing   # Google Wellbeing
com.miui.documentsuioverlay         # MIUI documents
com.xiaomi.mi_connect_service       # Xiaomi Connect
# ... and other packages
```

### Getting List of Installed Applications

To get a complete list of installed applications on your device:

```bash
# Windows
.\applist.bat

# Linux/macOS
./applist.sh
```

The result will be saved to `app_list.txt` file.

## 🎯 Supported Devices

### Xiaomi/MIUI
- MIUI system applications
- Xiaomi services
- Pre-installed games and applications

### Samsung
- Samsung system applications
- Knox services
- Pre-installed applications

### Other Manufacturers
- Google applications
- Carrier applications
- Games and entertainment applications

## ⚠️ Important Warnings

### 🚨 Risks

- **Bootloop**: Removing critical system applications may lead to boot loop
- **Loss of functionality**: Some device features may stop working
- **Recovery difficulty**: Restoring removed applications may be difficult

### 🛡️ Safety Recommendations

1. **Create a backup** of important data
2. **Review the list** of packages before removal
3. **Start small** — remove applications in small batches
4. **Test functionality** after each removal
5. **Reboot the device** after debloating

### 🚫 Avoid Removing

```txt
# Critical system applications
com.android.systemui      # System interface
com.android.settings      # Settings
com.android.phone         # Phone
com.android.mms           # SMS
```

## 🔧 Troubleshooting

### ADB Not Found
```bash
# Check ADB installation
adb version

# If not installed, install according to instructions above
```

### Device Not Detected
```bash
# Check connection
adb devices

# Make sure USB debugging is enabled
# Allow debugging on device when prompted
```

### Removal Errors
```bash
# Some applications may be protected from removal
# This is normal - script will continue with others
```

## 📊 Statistics

- **199+ packages** in base removal list
- **3+ platform support** (Windows, Linux, macOS)
- **Compatibility** with Android 5.0+

## 🤝 Contributing

We welcome contributions to the project!

### How to help:
1. 🍴 Fork the repository
2. 🌿 Create a branch for new feature
3. 💾 Make changes
4. 📤 Create a Pull Request

### What can be improved:
- Add support for new devices
- Improve error handling
- Add GUI interface
- Create database of safe packages

## 📄 License

This project is distributed under the MIT license. See [LICENSE](LICENSE) file for details.

## ⚖️ Disclaimer

**Use at your own risk!** Authors are not responsible for any device damage or data loss. Always create backups before use.

## 📞 Support

If you have questions or problems:

1. 📖 Check the "Troubleshooting" section
2. 🔍 Search existing Issues for solutions
3. 🆕 Create a new Issue with detailed problem description

---

**Made with ❤️ for the Android community**
