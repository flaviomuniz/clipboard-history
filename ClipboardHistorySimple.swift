#!/usr/bin/env swift

import Cocoa
import SwiftUI

// MARK: - Clipboard Item Model
struct ClipboardItem: Identifiable {
    let id = UUID()
    let content: String
    let timestamp: Date

    var displayText: String {
        String(content.prefix(100))
    }

    var timeAgo: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: timestamp, relativeTo: Date())
    }
}

// MARK: - Clipboard Manager
class ClipboardManager: ObservableObject {
    @Published var items: [ClipboardItem] = []
    private var timer: Timer?
    private var lastChangeCount = 0

    func startMonitoring() {
        timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { _ in
            self.checkClipboard()
        }
    }

    private func checkClipboard() {
        let pasteboard = NSPasteboard.general
        let changeCount = pasteboard.changeCount

        guard changeCount != lastChangeCount else { return }
        lastChangeCount = changeCount

        if let string = pasteboard.string(forType: .string), !string.isEmpty {
            let item = ClipboardItem(content: string, timestamp: Date())
            DispatchQueue.main.async {
                self.items.removeAll { $0.content == item.content }
                self.items.insert(item, at: 0)
                if self.items.count > 50 {
                    self.items = Array(self.items.prefix(50))
                }
            }
        }
    }

    func copyItem(_ item: ClipboardItem) {
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.setString(item.content, forType: .string)
        lastChangeCount = pasteboard.changeCount
    }
}

// MARK: - History View
struct HistoryView: View {
    @ObservedObject var manager: ClipboardManager
    @State private var searchText = ""
    @State private var showingAbout = false

    var filteredItems: [ClipboardItem] {
        if searchText.isEmpty {
            return manager.items
        } else {
            return manager.items.filter {
                $0.content.localizedCaseInsensitiveContains(searchText)
            }
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Image(systemName: "doc.on.clipboard")
                    .font(.title2)
                Text("Clipboard History")
                    .font(.title2)
                Spacer()

                Button(action: {
                    showingAbout = true
                }) {
                    Image(systemName: "questionmark.circle")
                        .font(.title2)
                }
                .buttonStyle(.plain)
                .help("About")

                Button("Clear") {
                    manager.items.removeAll()
                }

                Button(action: {
                    NSApplication.shared.terminate(nil)
                }) {
                    Image(systemName: "power.circle")
                        .font(.title2)
                        .foregroundColor(.red)
                }
                .buttonStyle(.plain)
                .help("Quit ClipboardHistory")
            }
            .padding()

            // Search
            TextField("Search...", text: $searchText)
                .textFieldStyle(.roundedBorder)
                .padding(.horizontal)

            // List
            ScrollView {
                VStack(spacing: 2) {
                    ForEach(filteredItems) { item in
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(item.timeAgo)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                Text(item.displayText)
                                    .lineLimit(2)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }

                            Button("Copy") {
                                manager.copyItem(item)
                                NSApplication.shared.keyWindow?.close()
                            }
                            .buttonStyle(.bordered)
                        }
                        .padding(8)
                        .background(Color(NSColor.controlBackgroundColor))
                        .cornerRadius(4)
                    }
                }
                .padding()
            }
        }
        .frame(width: 400, height: 550)
        .sheet(isPresented: $showingAbout) {
            AboutViewSimple()
        }
    }
}

// MARK: - About View
struct AboutViewSimple: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 20) {
            // App Icon and Title
            VStack(spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: 20)
                        .fill(LinearGradient(
                            gradient: Gradient(colors: [Color.blue.opacity(0.8), Color.purple.opacity(0.8)]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ))
                        .frame(width: 80, height: 80)

                    Image(systemName: "doc.on.clipboard")
                        .font(.system(size: 40, weight: .medium))
                        .foregroundColor(.white)
                }
                .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)

                Text("ClipboardHistory")
                    .font(.title)
                    .fontWeight(.bold)

                Text("Version 1.0.0")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Divider()

            // Description
            VStack(spacing: 8) {
                Text("A modern clipboard history manager for macOS")
                    .font(.body)
                    .multilineTextAlignment(.center)

                Text("Keep track of everything you copy and paste with ease. Access your clipboard history instantly.")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }

            // Features
            VStack(alignment: .leading, spacing: 8) {
                Text("Features")
                    .font(.headline)

                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Image(systemName: "doc.on.clipboard")
                            .foregroundColor(.blue)
                            .frame(width: 16)
                        Text("Clipboard History")
                            .font(.caption)
                    }

                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.blue)
                            .frame(width: 16)
                        Text("Quick Search")
                            .font(.caption)
                    }

                    HStack {
                        Image(systemName: "bolt")
                            .foregroundColor(.blue)
                            .frame(width: 16)
                        Text("Lightning Fast")
                            .font(.caption)
                    }
                }
            }

            Spacer()

            // GitHub Link
            Button(action: {
                if let url = URL(string: "https://github.com/flaviomuniz/clipboard-history") {
                    NSWorkspace.shared.open(url)
                }
            }) {
                HStack(spacing: 6) {
                    Image(systemName: "link")
                    Text("View on GitHub")
                }
                .foregroundColor(.blue)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(Color.blue.opacity(0.1))
                .cornerRadius(8)
            }
            .buttonStyle(.plain)

            Text("Developed by @flaviomuniz")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(20)
        .frame(width: 350, height: 500)
    }
}

// MARK: - App Delegate
class AppDelegate: NSObject, NSApplicationDelegate {
    var statusItem: NSStatusItem?
    var popover: NSPopover?
    let manager = ClipboardManager()

    func applicationDidFinishLaunching(_ notification: Notification) {
        // Create status bar item
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)

        if let button = statusItem?.button {
            button.image = NSImage(systemSymbolName: "doc.on.clipboard",
                                  accessibilityDescription: "Clipboard History")
            button.action = #selector(togglePopover)
            button.target = self
        }

        // Create popover
        popover = NSPopover()
        popover?.contentViewController = NSHostingController(rootView: HistoryView(manager: manager))
        popover?.behavior = .transient

        // Start monitoring
        manager.startMonitoring()
    }

    @objc func togglePopover() {
        guard let button = statusItem?.button else { return }

        if popover?.isShown == true {
            popover?.performClose(nil)
        } else {
            popover?.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
            NSApplication.shared.activate(ignoringOtherApps: true)
        }
    }
}

// MARK: - Main
let app = NSApplication.shared
app.setActivationPolicy(.accessory)

let delegate = AppDelegate()
app.delegate = delegate

app.run()