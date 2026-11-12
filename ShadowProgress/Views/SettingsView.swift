import SwiftUI
import UniformTypeIdentifiers

/// FileDocument gives backups a standard Files share/save flow instead of requiring an account.
struct BackupDocument: FileDocument {
    static var readableContentTypes: [UTType] { [.json] }
    var data: Data
    init(data: Data = Data()) { self.data = data }
    init(configuration: ReadConfiguration) throws {
        data = configuration.file.regularFileContents ?? Data()
    }
    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        FileWrapper(regularFileWithContents: data)
    }
}

/// Preferences affect the visible catalog without erasing any hidden DLC progress.
struct SettingsView: View {
    @EnvironmentObject private var store: ProgressStore
    @AppStorage("includeDLC") private var includeDLC = true
    @AppStorage("hideSpoilers") private var hideSpoilers = true
    @State private var export = false
    @State private var importing = false
    @State private var confirmReset = false
    @State private var confirmImport = false
    @State private var pendingImport: Data?
    @State private var backup = BackupDocument()
    @State private var message: String?

    var body: some View {
        Form {
            Section {
                Toggle("Include DLC achievements", isOn: $includeDLC)
                Toggle("Hide story spoilers", isOn: $hideSpoilers)
            } header: { Text("Your expedition") } footer: {
                Text("Base game: 63 achievements. With DLC: 99. Excluding DLC keeps its saved progress. Hidden objectives can be revealed individually.")
            }
            Section {
                Button("Export progress backup", systemImage: "square.and.arrow.up") {
                    do { backup = BackupDocument(data: try store.exportData()); export = true }
                    catch { message = error.localizedDescription }
                }
                Button("Import progress backup", systemImage: "square.and.arrow.down") { importing = true }
            } header: { Text("Keep your discoveries safe") } footer: {
                Text("Backups include counts, completion dates, pins, and personal notes. Store them somewhere private. Import replaces your current journal after confirmation.")
            }
            Section("About the journal") {
                LabeledContent("Version", value: "1.0")
                LabeledContent("Platform list", value: "Steam / Xbox")
                Text("PlayStation’s platinum trophy is not included. Requirements are short checklists, not walkthroughs. Progress is entered manually; game accounts are not connected.").font(.footnote).foregroundStyle(.secondary)
                Link("View achievement source", destination: URL(string: "https://steamcommunity.com/stats/750920/achievements")!)
                Text("An independent fan companion for Shadow of the Tomb Raider. Not affiliated with the game’s developers or publishers. No analytics or advertising.").font(.footnote).foregroundStyle(.secondary)
            }
            Section {
                Button("Reset all progress", role: .destructive) { confirmReset = true }
            } footer: { Text("Export a backup before resetting if you want to restore your progress later.") }
        }
        .scrollContentBackground(.hidden).background(Theme.background)
        .navigationTitle("Field Kit")
        .fileExporter(isPresented: $export, document: backup, contentType: .json, defaultFilename: "ShadowProgress-Backup") { result in
            if case .failure(let error) = result { message = error.localizedDescription }
        }
        .fileImporter(isPresented: $importing, allowedContentTypes: [.json]) { result in
            do {
                let url = try result.get()
                let access = url.startAccessingSecurityScopedResource()
                defer { if access { url.stopAccessingSecurityScopedResource() } }
                // Bound input size before decoding a backup selected from Files.
                let size = try url.resourceValues(forKeys: [.fileSizeKey]).fileSize ?? 0
                guard size <= 5_000_000 else { throw ImportError.tooLarge }
                pendingImport = try Data(contentsOf: url)
                confirmImport = true
            } catch { message = error.localizedDescription }
        }
        .confirmationDialog("Replace your current journal with this backup?", isPresented: $confirmImport, titleVisibility: .visible) {
            Button("Replace progress", role: .destructive) {
                guard let data = pendingImport else { return }
                do { try store.importData(data); message = "Your backup was restored." }
                catch { message = error.localizedDescription }
                pendingImport = nil
            }
            Button("Cancel", role: .cancel) { pendingImport = nil }
        }
        .confirmationDialog("Reset all achievements, notes, and pinned objectives?", isPresented: $confirmReset, titleVisibility: .visible) {
            Button("Reset all progress", role: .destructive) { store.reset() }
            Button("Cancel", role: .cancel) {}
        }
        .alert("Journal backup", isPresented: Binding(get: { message != nil }, set: { if !$0 { message = nil } })) {
            Button("OK") { message = nil }
        } message: { Text(message ?? "") }
    }

    enum ImportError: LocalizedError {
        case tooLarge
        var errorDescription: String? { "This file is too large to be a journal backup. Choose a file smaller than 5 MB." }
    }
}
