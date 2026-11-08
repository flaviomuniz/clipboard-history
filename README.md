
![ClipboardHistory Icon](icon.jpeg)
# ClipboardHistory

An open-source, lightweight clipboard history manager for macOS (Apple Silicon and Intel).

## Features

- **Clipboard History** - Keeps a history of everything you copy (up to 200 items)
- **Search** - Quickly find items in history
- **Persistent Storage** - History is saved to disk and survives app restarts
- **Launch at Login** - Option to start automatically when you log in
- **Ignore Apps** - Choose apps (password managers by default) whose copies are never saved
- **Global Shortcut** - Open history from anywhere with ⇧⌘V (Cmd+Shift+V), changeable in Settings
- **Keyboard Navigation** - Move through the list with ↑ ↓, copy with Return or ⌘1 to ⌘9, close with Esc
- **Settings** - Configurable history limit, launch at login, keyboard shortcut, ignored apps, clear history
- **Menu Bar App** - Lives in your menu bar, out of the way
- **Lightweight & Fast** - Single-file Swift app, minimal resource usage
- **Privacy First** - All data stored locally, nothing sent anywhere

## Installation

### Requirements
- macOS 13.0 (Ventura) or later

### Build from Source

1. Clone the repository:
```bash
git clone https://github.com/flaviomuniz/clipboard-history
cd clipboard-history
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

## Usage

1. **Copy** - Use Cmd+C normally to copy any content
2. **Open History** - Click the clipboard icon in the menu bar
3. **Paste** - Click "Copy" on any item, or the item itself, to put it back on your clipboard. It moves to the top of the list
4. **Search** - Type in the search box to filter items
5. **Delete** - Click the trash icon to remove individual items
6. **Settings** - Click the gear icon to configure preferences

You can also press Cmd+Shift+V in any app to open or close the history. While ClipboardHistory is running, this replaces "Paste and Match Style" in other apps. If you use that, pick another shortcut in Settings.

### Keyboard

The search box has focus when the history opens, so you can type to filter right away.

- **↑ / ↓** - Move the highlight. Nothing is highlighted when the history opens, so the first ↓ highlights the first item.
- **Return** - Copy the highlighted item and close the history. Then paste with Cmd+V.
- **Cmd+1 to Cmd+9** - Copy the item with that number (shown on the first nine rows).
- **Cmd+Delete** - Delete the highlighted item. This only works after you move into the list with ↑ or ↓. Before that, Cmd+Delete clears the search box as usual.
- **Esc** - Close the history.

## How It Works

ClipboardHistory monitors your system clipboard every 0.5 seconds. When it detects a new text copy, it saves it to a local JSON file at `~/Library/Application Support/ClipboardHistory/history.json`. The history persists across app restarts and system reboots.

Copies marked as passwords by password managers are never saved, and copies from ignored apps are skipped. When an app doesn't say where a copy came from, the source is guessed from the frontmost app, so source-app detection is best-effort. The password marker is the main protection.

## Project Structure

```
ClipboardHistory/
├── ClipboardHistorySimple.swift    # Main app (single-file)
├── build.sh                        # Build script
├── create_icon.swift               # Icon generation script
├── ClipboardHistory.icns           # App icon
├── images/                         # Screenshots
├── LICENSE                         # MIT License
├── CONTRIBUTING.md                 # Contribution guidelines
└── README.md                       # This file
```

## Privacy & Security

- All data is stored locally on your Mac
- No network requests, no analytics, no telemetry
- Completely open-source for auditing
- History stored at `~/Library/Application Support/ClipboardHistory/`

## Roadmap

- [x] Global keyboard shortcut (e.g. `Cmd+Shift+V`) to open history
- [ ] Image and rich text support
- [x] Keyboard navigation (arrow keys + Enter to copy)
- [ ] Auto-paste into the previous app (opt-in)
- [ ] Configurable history expiration
- [ ] Homebrew cask for easy installation
- [ ] Code snippets support with syntax highlighting
- [ ] Categories and tags for organization

## Contributing

Contributions are welcome! Please see [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.

## License

This project is open-source under the [MIT License](LICENSE).

## Support

- **Issues**: [GitHub Issues](https://github.com/flaviomuniz/clipboard-history/issues)
- **Discussions**: [GitHub Discussions](https://github.com/flaviomuniz/clipboard-history/discussions)

## Credits

Developed by [@flaviomuniz](https://github.com/flaviomuniz)
