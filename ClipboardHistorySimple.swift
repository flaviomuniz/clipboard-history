#!/usr/bin/env swift

import Cocoa
import SwiftUI
import ServiceManagement

// MARK: - Clipboard Item Model
struct ClipboardItem: Identifiable, Codable {
    let id: UUID
    let content: String
    let timestamp: Date

    init(content: String, timestamp: Date) {
        self.id = UUID()
        self.content = content
        self.timestamp = timestamp
    }

    var displayText: String {
        String(content.prefix(100))
    }

    var timeAgo: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: timestamp, relativeTo: Date())
    }
}

// MARK: - Persistence
struct PersistenceManager {
    private static var storageURL: URL {
        let appSupport = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        let appDir = appSupport.appendingPathComponent("ClipboardHistory")
        if !FileManager.default.fileExists(atPath: appDir.path) {
            try? FileManager.default.createDirectory(at: appDir, withIntermediateDirectories: true)
        }
        return appDir.appendingPathComponent("history.json")
    }

    static func save(_ items: [ClipboardItem]) {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        guard let data = try? encoder.encode(items) else { return }
        try? data.write(to: storageURL, options: .atomic)
    }

    static func load() -> [ClipboardItem] {
        guard let data = try? Data(contentsOf: storageURL) else { return [] }
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return (try? decoder.decode([ClipboardItem].self, from: data)) ?? []
    }
}

// MARK: - Clipboard Manager
class ClipboardManager: ObservableObject {
    @Published var items: [ClipboardItem] = []
    @Published var historyLimit: Int {
        didSet { UserDefaults.standard.set(historyLimit, forKey: "historyLimit") }
    }
    private var timer: Timer?
    private var lastChangeCount = 0

    init() {
        let saved = UserDefaults.standard.integer(forKey: "historyLimit")
        self.historyLimit = saved > 0 ? saved : 50
        self.items = PersistenceManager.load()
    }

    func startMonitoring() {
        lastChangeCount = NSPasteboard.general.changeCount
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
                if self.items.count > self.historyLimit {
                    self.items = Array(self.items.prefix(self.historyLimit))
                }
                PersistenceManager.save(self.items)
            }
        }
    }

    func copyItem(_ item: ClipboardItem) {
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.setString(item.content, forType: .string)
        lastChangeCount = pasteboard.changeCount
    }

    func deleteItem(_ item: ClipboardItem) {
        items.removeAll { $0.id == item.id }
        PersistenceManager.save(items)
    }

    func clearAll() {
        items.removeAll()
        PersistenceManager.save(items)
    }
}

// MARK: - Settings View
struct SettingsView: View {
    @ObservedObject var manager: ClipboardManager
    @Environment(\.dismiss) private var dismiss
    @State private var launchAtLogin = SMAppService.mainApp.status == .enabled
    @State private var showClearConfirmation = false

    private let historyOptions = [25, 50, 100, 200]

    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("Settings")
                    .font(.title2)
                    .fontWeight(.semibold)
                Spacer()
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title2)
                        .foregroundColor(.secondary)
                }
                .buttonStyle(.plain)
            }
            .padding()

            Divider()

            VStack(spacing: 20) {
                // General section
                VStack(alignment: .leading, spacing: 12) {
                    Text("General")
                        .font(.headline)
                        .foregroundColor(.secondary)

                    HStack {
                        Image(systemName: "arrow.clockwise")
                            .foregroundColor(.blue)
                            .frame(width: 20)
                        Toggle("Launch at Login", isOn: $launchAtLogin)
                            .toggleStyle(.switch)
                            .onChange(of: launchAtLogin) { oldValue, newValue in
                                do {
                                    if newValue {
                                        try SMAppService.mainApp.register()
                                    } else {
                                        try SMAppService.mainApp.unregister()
                                    }
                                } catch {
                                    launchAtLogin = oldValue
                                }
                            }
                    }
                }
                .padding(.horizontal)

                Divider()
                    .padding(.horizontal)

                // Storage section
                VStack(alignment: .leading, spacing: 12) {
                    Text("Storage")
                        .font(.headline)
                        .foregroundColor(.secondary)

                    HStack {
                        Image(systemName: "tray.full")
                            .foregroundColor(.blue)
                            .frame(width: 20)
                        Text("History Limit")
                        Spacer()
                        Picker("", selection: $manager.historyLimit) {
                            ForEach(historyOptions, id: \.self) { count in
                                Text("\(count) items").tag(count)
                            }
                        }
                        .frame(width: 120)
                    }

                    HStack {
                        Image(systemName: "info.circle")
                            .foregroundColor(.secondary)
                            .frame(width: 20)
                        Text("Currently storing \(manager.items.count) items")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.horizontal)

                Divider()
                    .padding(.horizontal)

                // Danger zone
                VStack(alignment: .leading, spacing: 12) {
                    Text("Danger Zone")
                        .font(.headline)
                        .foregroundColor(.secondary)

                    HStack {
                        Image(systemName: "trash")
                            .foregroundColor(.red)
                            .frame(width: 20)

                        if showClearConfirmation {
                            Text("Are you sure?")
                                .foregroundColor(.red)
                            Spacer()
                            Button("Cancel") {
                                showClearConfirmation = false
                            }
                            Button("Delete All") {
                                manager.clearAll()
                                showClearConfirmation = false
                            }
                            .foregroundColor(.red)
                        } else {
                            Text("Clear All History")
                            Spacer()
                            Button("Clear...") {
                                showClearConfirmation = true
                            }
                        }
                    }
                }
                .padding(.horizontal)

                Spacer()
            }
            .padding(.top)
        }
        .frame(width: 350, height: 380)
    }
}

// MARK: - History View
struct HistoryView: View {
    @ObservedObject var manager: ClipboardManager
    @State private var searchText = ""
    @State private var showingAbout = false
    @State private var showingSettings = false

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

                Button(action: { showingSettings = true }) {
                    Image(systemName: "gearshape")
                        .font(.title2)
                }
                .buttonStyle(.plain)
                .help("Settings")

                Button(action: { showingAbout = true }) {
                    Image(systemName: "questionmark.circle")
                        .font(.title2)
                }
                .buttonStyle(.plain)
                .help("About")

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
            HStack {
                TextField("Search...", text: $searchText)
                    .textFieldStyle(.roundedBorder)
                Spacer()
                Text("\(manager.items.count) items")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
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

                            Button(action: { manager.deleteItem(item) }) {
                                Image(systemName: "trash")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            .buttonStyle(.plain)
                            .help("Delete")

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
        .sheet(isPresented: $showingSettings) {
            SettingsView(manager: manager)
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

                Text("Version 1.1.0")
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

                    HStack {
                        Image(systemName: "externaldrive")
                            .foregroundColor(.blue)
                            .frame(width: 16)
                        Text("Persistent History")
                            .font(.caption)
                    }

                    HStack {
                        Image(systemName: "arrow.clockwise")
                            .foregroundColor(.blue)
                            .frame(width: 16)
                        Text("Launch at Login")
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

    func applicationWillTerminate(_ notification: Notification) {
        PersistenceManager.save(manager.items)
    }

    @objc func togglePopover() {
        guard let button = statusItem?.button else { return }

        if popover?.isShown == true {
            popover?.performClose(nil)
        } else {
            popover?.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)

            if let popoverWindow = popover?.contentViewController?.view.window {
                var frame = popoverWindow.frame

                if let screen = NSScreen.main {
                    let screenFrame = screen.visibleFrame

                    if frame.maxY > screenFrame.maxY {
                        frame.origin.y = screenFrame.maxY - frame.height
                    }

                    if frame.minY < screenFrame.minY {
                        frame.origin.y = screenFrame.minY
                    }

                    popoverWindow.setFrame(frame, display: true)
                }
            }

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