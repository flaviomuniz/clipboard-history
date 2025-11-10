
![ClipboardHistory Icon](icon.jpeg)
# ClipboardHistory

An open-source clipboard history manager for macOS (Apple Silicon and Intel).

## Features

- 📋 **Clipboard History**: Keeps a history of everything you copy
- 🔍 **Search**: Quickly find items in history
- 🗑️ **Management**: Delete individual items or clear entire history
- 🖼️ **Multi-type Support**: Text and images
- 🚀 **Lightweight & Fast**: Optimized for performance
- ❓ **Help & About**: Built-in documentation with GitHub links

## Installation

### Requirements
- macOS 13.0 (Ventura) or later

### Build from Source

1. Clone the repository:
```bash
git clone https://github.com/flaviomuniz/clipboard-history
cd ClipboardHistory
```

2. Build the app:
```bash
chmod +x build.sh
./build.sh
```

3. Install the app:
```bash
cp -r ClipboardHistory.app /Applications/
```

## Configuration

### Required Permissions

On first launch, the app will request:

1. **Accessibility**: To monitor clipboard and simulate keyboard shortcuts
   - Go to System Preferences > Privacy & Security > Accessibility
   - Add and authorize ClipboardHistory

## Usage

1. **Copy**: Use Cmd+C normally to copy any content
2. **Open History**: Click the clipboard icon in the menu bar
3. **Paste**: Click any item to paste it immediately
4. **Search**: Type in the search box to filter items
5. **Delete**: Click the power button to quit the app
6. **Help**: Click the question mark for app information

## Project Structure

```
ClipboardHistory/
├── ClipboardHistorySimple.swift    # Main app file
├── build.sh                        # Build script
├── create_icon.swift              # Icon generation script
├── ClipboardHistory.icns          # App icon
└── README.md                      # This file
```

## Privacy & Security

- All data is stored locally on your Mac
- No data is sent to third-party servers
- Completely open-source code for auditing

## Development

### Building

The app is built as a single Swift file for simplicity:

```bash
./build.sh
```

This compiles `ClipboardHistorySimple.swift` into a complete macOS app bundle with:
- Native SwiftUI interface
- Menu bar integration
- Custom app icon
- Proper Info.plist configuration

### Contributing

1. Fork the project
2. Create your feature branch (`git checkout -b feature/MyFeature`)
3. Commit your changes (`git commit -m 'Add: new feature'`)
4. Push to the branch (`git push origin feature/MyFeature`)
5. Open a Pull Request

## License

This project is open-source under the MIT License. See the LICENSE file for details.

## Support

- **Issues**: [GitHub Issues](https://github.com/flaviomuniz/clipboard-history/issues)
- **Discussions**: [GitHub Discussions](https://github.com/flaviomuniz/clipboard-history/discussions)

## Roadmap

- [ ] Code snippets support with syntax highlighting
- [ ] Categories and tags for organization
- [ ] Customizable shortcuts for specific actions
- [ ] Configurable history expiration

## Credits

Developed by @flaviomuniz