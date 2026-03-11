# Contributing to ClipboardHistory

Thanks for your interest in contributing! Here's how you can help.

## Getting Started

1. Fork the repository
2. Clone your fork:
   ```bash
   git clone https://github.com/YOUR_USERNAME/clipboard-history
   cd ClipboardHistory
   ```
3. Build the app:
   ```bash
   ./build.sh
   ```

## Making Changes

1. Create a feature branch from `main`:
   ```bash
   git checkout -b feature/your-feature
   ```
2. Make your changes to `ClipboardHistorySimple.swift`
3. Build and test locally:
   ```bash
   ./build.sh
   open ClipboardHistory.app
   ```
4. Commit your changes with a clear message:
   ```bash
   git commit -m "Add: description of your change"
   ```

## Commit Message Convention

- `Add:` for new features
- `Fix:` for bug fixes
- `Update:` for improvements to existing features
- `Refactor:` for code restructuring
- `Docs:` for documentation changes

## Pull Requests

1. Push your branch to your fork
2. Open a Pull Request against `main`
3. Describe what your changes do and why
4. Make sure the CI build passes

## Code Style

- The app is intentionally a single Swift file for simplicity
- Use `// MARK: -` sections to organize code
- Follow Swift naming conventions
- Keep the app lightweight — avoid adding heavy dependencies

## Reporting Issues

- Use [GitHub Issues](https://github.com/flaviomuniz/clipboard-history/issues)
- Include your macOS version
- Describe the steps to reproduce the problem
- Include any error messages or screenshots

## Ideas & Feature Requests

Check the [Roadmap](README.md#roadmap) for planned features. If you have a new idea, open an issue to discuss it before starting work.
