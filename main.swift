import SwiftUI
import WebKit
import Speech
import AVFoundation
#if os(macOS)
import AppKit
#else
import UIKit
#endif

// MARK: - Editor State Management

enum ViewMode {
    case viewer
    case editor
    case splitView
}

enum VoiceState {
    case idle
    case listening
    case processing
}

// Markdown formatting commands
enum MarkdownCommand: String, CaseIterable {
    case bold = "Bold"
    case italic = "Italic"
    case code = "Inline Code"
    case strikethrough = "Strikethrough"
    case header1 = "Header 1"
    case header2 = "Header 2"
    case header3 = "Header 3"
    case header4 = "Header 4"
    case header5 = "Header 5"
    case header6 = "Header 6"
    case bulletList = "Bullet List"
    case numberedList = "Numbered List"
    case checkboxList = "Checkbox List"
    case blockquote = "Blockquote"
    case codeBlock = "Code Block"
    case link = "Link"
    case image = "Image"
    case table = "Table"
    case horizontalRule = "Horizontal Rule"
    case lineBreak = "Line Break"
    
    var prefix: String {
        switch self {
        case .bold: return "**"
        case .italic: return "*"
        case .code: return "`"
        case .strikethrough: return "~~"
        case .header1: return "# "
        case .header2: return "## "
        case .header3: return "### "
        case .header4: return "#### "
        case .header5: return "##### "
        case .header6: return "###### "
        case .bulletList: return "- "
        case .numberedList: return "1. "
        case .checkboxList: return "- [ ] "
        case .blockquote: return "> "
        case .codeBlock: return "```\n"
        case .link: return "["
        case .image: return "!["
        case .table: return "| Column 1 | Column 2 |\n|----------|----------|\n| "
        case .horizontalRule: return "---\n"
        case .lineBreak: return "\n"
        }
    }
    
    var suffix: String {
        switch self {
        case .bold: return "**"
        case .italic: return "*"
        case .code: return "`"
        case .strikethrough: return "~~"
        case .codeBlock: return "\n```"
        case .link: return "](url)"
        case .image: return "](image.jpg)"
        case .table: return " |\n| Cell 1   | Cell 2   |"
        default: return ""
        }
    }
    
    var isLineStart: Bool {
        switch self {
        case .header1, .header2, .header3, .header4, .header5, .header6,
             .bulletList, .numberedList, .checkboxList, .blockquote, .horizontalRule:
            return true
        default:
            return false
        }
    }
    
    var icon: String {
        switch self {
        case .bold: return "bold"
        case .italic: return "italic"
        case .code: return "chevron.left.slash.chevron.right"
        case .strikethrough: return "strikethrough"
        case .header1, .header2, .header3, .header4, .header5, .header6: return "textformat.size"
        case .bulletList: return "list.bullet"
        case .numberedList: return "list.number"
        case .checkboxList: return "checklist"
        case .blockquote: return "quote.bubble"
        case .codeBlock: return "curlybraces"
        case .link: return "link"
        case .image: return "photo"
        case .table: return "tablecells"
        case .horizontalRule: return "minus"
        case .lineBreak: return "return"
        }
    }
}

// Shared state for the application
class AppState: ObservableObject {
    @Published var htmlContent: String = ""
    @Published var markdownText: String = """
# Hello World

Welcome to the Markdown Editor!

This is a **sample document** to test the editor functionality.

## Features to try:

- Type directly in the editor pane (with light yellow background)
- Use voice commands by clicking the microphone button
- Switch between *Viewer*, *Editor*, and *Split* modes
- Save your work with Cmd+S

### Voice Commands:
Say "make header" to create headers like this one.

Happy editing! 🎉
"""
    @Published var webView: WKWebView = WKWebView()
    @Published var currentFileURL: URL? = nil
    @Published var viewMode: ViewMode = .viewer
    @Published var isModified: Bool = false
    @Published var voiceState: VoiceState = .idle
    @Published var lastVoiceCommand: String = ""
    @Published var cursorPosition: Int = 0

    init() {
        htmlContent = renderMarkdown(from: markdownText)
    }

    // MARK: - Core Logic
    
    func updateMarkdownContent(_ text: String) {
        markdownText = text
        htmlContent = renderMarkdown(from: text)
        isModified = true
    }
    
    func insertMarkdown(_ command: MarkdownCommand) {
        let text = markdownText
        let position = min(cursorPosition, text.count)
        
        if command.isLineStart {
            // For line-start commands, find the beginning of current line
            let startIndex = text.startIndex
            let positionIndex = text.index(startIndex, offsetBy: position)
            
            // Find line start
            var lineStartIndex = startIndex
            if position > 0 {
                let textBeforeCursor = String(text[startIndex..<positionIndex])
                if let lastNewlineRange = textBeforeCursor.range(of: "\n", options: .backwards) {
                    lineStartIndex = lastNewlineRange.upperBound
                } else {
                    lineStartIndex = startIndex
                }
            }
            
            let lineStartOffset = text.distance(from: startIndex, to: lineStartIndex)
            let beforeLine = String(text[startIndex..<lineStartIndex])
            let afterLine = String(text[lineStartIndex...])
            
            let newText = beforeLine + command.prefix + afterLine
            updateMarkdownContent(newText)
            cursorPosition = lineStartOffset + command.prefix.count
        } else {
            // For inline commands, insert at cursor position
            let startIndex = text.startIndex
            let insertIndex = text.index(startIndex, offsetBy: position)
            
            let beforeCursor = String(text[startIndex..<insertIndex])
            let afterCursor = String(text[insertIndex...])
            
            let newText = beforeCursor + command.prefix + command.suffix + afterCursor
            updateMarkdownContent(newText)
            cursorPosition = position + command.prefix.count
        }
    }
    
    func createNewFile() {
        markdownText = """
# Hello World

Welcome to the Markdown Editor!

This is a **sample document** to test the editor functionality.

## Features to try:

- Type directly in the editor pane (with light yellow background)
- Use voice commands by clicking the microphone button
- Switch between *Viewer*, *Editor*, and *Split* modes
- Save your work with Cmd+S

### Voice Commands:
Say "make header" to create headers like this one.

Happy editing! 🎉
"""
        htmlContent = renderMarkdown(from: markdownText)
        currentFileURL = nil
        isModified = false
    }

    func openFile() {
        #if os(macOS)
        let panel = NSOpenPanel()
        panel.canChooseFiles = true
        panel.canChooseDirectories = false
        panel.allowsMultipleSelection = false
        panel.allowedContentTypes = [.text]

        if panel.runModal() == .OK, let url = panel.url {
            _ = loadMarkdown(from: url)
        }
        #else
        // iOS implementation would use DocumentPicker
        #endif
    }
    
    func saveFile() {
        if let url = currentFileURL {
            saveMarkdown(to: url)
        } else {
            saveAsFile()
        }
    }
    
    func saveAsFile() {
        #if os(macOS)
        let savePanel = NSSavePanel()
        savePanel.allowedContentTypes = [.plainText]
        savePanel.nameFieldStringValue = "Untitled.md"
        
        if savePanel.runModal() == .OK, let url = savePanel.url {
            saveMarkdown(to: url)
        }
        #else
        // iOS implementation would use DocumentPicker
        #endif
    }
    
    private func saveMarkdown(to url: URL) {
        do {
            try markdownText.write(to: url, atomically: true, encoding: .utf8)
            currentFileURL = url
            isModified = false
        } catch {
            showAlert(title: "Save Error", message: "Failed to save file: \(error.localizedDescription)")
        }
    }

    func exportToPdf() {
        let savePanel = NSSavePanel()
        savePanel.allowedContentTypes = [.pdf]

        if let url = currentFileURL {
            savePanel.nameFieldStringValue = url.deletingPathExtension().appendingPathExtension("pdf").lastPathComponent
        } else {
            savePanel.nameFieldStringValue = "Untitled.pdf"
        }

        if savePanel.runModal() == .OK, let outputURL = savePanel.url {
            let configuration = WKPDFConfiguration()
            // The webView needs to have a non-zero frame to render the PDF correctly.
            webView.frame = CGRect(x: 0, y: 0, width: 1024, height: 768) // A reasonable default page size

            webView.createPDF(configuration: configuration) { result in
                switch result {
                case .success(let data):
                    do {
                        try data.write(to: outputURL)
                    } catch {
                        self.showAlert(title: "Error", message: "Failed to save the PDF file: \(error.localizedDescription)")
                    }
                case .failure(let error):
                    self.showAlert(title: "Error", message: "Failed to create the PDF file: \(error.localizedDescription)")
                }
            }
        }
    }

    @discardableResult
    func loadMarkdown(from url: URL) -> Bool {
        do {
            let markdownContent = try String(contentsOf: url, encoding: .utf8)
            let html = renderMarkdown(from: markdownContent)
            DispatchQueue.main.async {
                self.markdownText = markdownContent
                self.htmlContent = html
                self.currentFileURL = url
                self.isModified = false
            }
            return true
        } catch {
            let errorHtml = "<html><body><h1>Error reading file</h1><p>\(error.localizedDescription)</p></body></html>"
            DispatchQueue.main.async {
                self.htmlContent = errorHtml
                self.markdownText = ""
                self.currentFileURL = nil
                self.isModified = false
            }
            return false
        }
    }

    func renderMarkdown(from markdown: String) -> String {
        let escapedMarkdown = markdown.replacingOccurrences(of: "`", with: "\\`")

        return """
        <!DOCTYPE html>
        <html>
        <head>
            <title>Markdown</title>
            <script src="https://cdn.jsdelivr.net/npm/marked/marked.min.js"></script>
            <style>
                body { font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, Helvetica, Arial, sans-serif; padding: 20px; color: #333; }
                code { background-color: #f4f4f4; padding: 2px 4px; border-radius: 3px; }
                pre { background-color: #f4f4f4; padding: 10px; border-radius: 5px; }
            </style>
        </head>
        <body>
            <div id="content"></div>
            <script>document.getElementById('content').innerHTML = marked.parse(`\(escapedMarkdown)`);</script>
        </body>
        </html>
        """
    }
    
    func showAlert(title: String, message: String) {
        #if os(macOS)
        let alert = NSAlert()
        alert.messageText = title
        alert.informativeText = message
        alert.alertStyle = .critical
        alert.runModal()
        #else
        // iOS alert implementation would go here
        #endif
    }
}

// MARK: - Voice Transcription

class VoiceTranscriber: ObservableObject {
    private let speechRecognizer = SFSpeechRecognizer()
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()
    
    weak var appState: AppState?
    
    init(appState: AppState) {
        self.appState = appState
        requestPermissions()
    }
    
    private func requestPermissions() {
        SFSpeechRecognizer.requestAuthorization { authStatus in
            DispatchQueue.main.async {
                switch authStatus {
                case .authorized:
                    break
                case .denied, .restricted, .notDetermined:
                    self.appState?.showAlert(title: "Speech Recognition", message: "Speech recognition permission is required for voice commands.")
                @unknown default:
                    break
                }
            }
        }
        
        #if !os(macOS)
        AVAudioSession.sharedInstance().requestRecordPermission { granted in
            if !granted {
                DispatchQueue.main.async {
                    self.appState?.showAlert(title: "Microphone Access", message: "Microphone access is required for voice commands.")
                }
            }
        }
        #endif
    }
    
    func startListening() {
        guard let appState = appState else { return }
        
        if audioEngine.isRunning {
            stopListening()
            return
        }
        
        do {
            try startRecording()
            appState.voiceState = .listening
        } catch {
            appState.showAlert(title: "Voice Recognition Error", message: "Could not start voice recognition: \(error.localizedDescription)")
        }
    }
    
    func stopListening() {
        audioEngine.stop()
        recognitionRequest?.endAudio()
        appState?.voiceState = .idle
    }
    
    private func startRecording() throws {
        recognitionTask?.cancel()
        recognitionTask = nil
        
        #if !os(macOS)
        let audioSession = AVAudioSession.sharedInstance()
        try audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
        try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        #endif
        
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        
        let inputNode = audioEngine.inputNode
        guard let recognitionRequest = recognitionRequest else {
            throw NSError(domain: "VoiceRecognition", code: 1, userInfo: [NSLocalizedDescriptionKey: "Unable to create recognition request"])
        }
        
        recognitionRequest.shouldReportPartialResults = true
        
        recognitionTask = speechRecognizer?.recognitionTask(with: recognitionRequest) { [weak self] result, error in
            var isFinal = false
            
            if let result = result {
                let transcribedText = result.bestTranscription.formattedString
                self?.processVoiceInput(transcribedText)
                isFinal = result.isFinal
            }
            
            if error != nil || isFinal {
                self?.audioEngine.stop()
                inputNode.removeTap(onBus: 0)
                self?.recognitionRequest = nil
                self?.recognitionTask = nil
                
                DispatchQueue.main.async {
                    self?.appState?.voiceState = .idle
                }
            }
        }
        
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, _ in
            self.recognitionRequest?.append(buffer)
        }
        
        audioEngine.prepare()
        try audioEngine.start()
    }
    
    private func processVoiceInput(_ text: String) {
        DispatchQueue.main.async {
            self.appState?.lastVoiceCommand = text
            
            // Process voice commands
            if self.isVoiceCommand(text) {
                self.executeVoiceCommand(text)
            } else {
                // Regular transcription - append to markdown text
                if let appState = self.appState {
                    let newText = appState.markdownText + " " + text
                    appState.updateMarkdownContent(newText)
                }
            }
        }
    }
    
    private func isVoiceCommand(_ text: String) -> Bool {
        let lowercased = text.lowercased()
        let commands = [
            "new paragraph", "make header", "bold that", "italic that", 
            "add link", "insert image", "start list", "numbered list",
            "code block", "new line", "blockquote", "table"
        ]
        return commands.contains { lowercased.contains($0) }
    }
    
    private func executeVoiceCommand(_ text: String) {
        guard let appState = appState else { return }
        let lowercased = text.lowercased()
        
        if lowercased.contains("new paragraph") {
            appState.insertMarkdown(.lineBreak)
            appState.insertMarkdown(.lineBreak)
        } else if lowercased.contains("make header") {
            appState.insertMarkdown(.header1)
        } else if lowercased.contains("bold that") {
            appState.insertMarkdown(.bold)
        } else if lowercased.contains("italic that") {
            appState.insertMarkdown(.italic)
        } else if lowercased.contains("add link") {
            appState.insertMarkdown(.link)
        } else if lowercased.contains("insert image") {
            appState.insertMarkdown(.image)
        } else if lowercased.contains("start list") {
            appState.insertMarkdown(.bulletList)
        } else if lowercased.contains("numbered list") {
            appState.insertMarkdown(.numberedList)
        } else if lowercased.contains("code block") {
            appState.insertMarkdown(.codeBlock)
        } else if lowercased.contains("new line") {
            appState.insertMarkdown(.lineBreak)
        } else if lowercased.contains("blockquote") {
            appState.insertMarkdown(.blockquote)
        } else if lowercased.contains("table") {
            appState.insertMarkdown(.table)
        } else {
            // Regular transcription - append to markdown text
            let newText = appState.markdownText + " " + text
            appState.updateMarkdownContent(newText)
        }
    }
}

// MARK: - Platform-Specific Text Editor

struct MarkdownTextEditor: View {
    @Binding var text: String
    @EnvironmentObject var appState: AppState
    let onTextChange: (String) -> Void
    
    var body: some View {
        TextEditor(text: $text)
            .font(.system(size: 14, design: .monospaced))
            .background(Color(red: 1.0, green: 1.0, blue: 0.8)) // Light yellow background
            .onChange(of: text) { newValue in
                // Update cursor position estimate (end of text for now)
                appState.cursorPosition = newValue.count
                onTextChange(newValue)
            }
            .onAppear {
                print("📄 SwiftUI TextEditor appeared with \(text.count) characters")
                appState.cursorPosition = text.count
            }
    }
}

// MARK: - Application Setup

extension Notification.Name {
    static let openFile = Notification.Name("openFileNotification")
    static let exportPdf = Notification.Name("exportPdfNotification")
    static let saveFile = Notification.Name("saveFileNotification")
    static let newFile = Notification.Name("newFileNotification")
}

#if os(macOS)
class DocumentWindowController {
    let window: NSWindow
    let appState: AppState
    let voiceTranscriber: VoiceTranscriber
    
    init() {
        appState = AppState()
        voiceTranscriber = VoiceTranscriber(appState: appState)
        
        let contentView = ContentView().environmentObject(appState)
        
        window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 800, height: 600),
            styleMask: [.titled, .closable, .miniaturizable, .resizable, .fullSizeContentView],
            backing: .buffered, defer: false)
        window.center()
        window.setFrameAutosaveName("MarkdownEditor-\(UUID().uuidString)")
        window.contentView = NSHostingView(rootView: contentView)
        window.makeKeyAndOrderFront(nil)
        window.title = "Markdown Editor - Untitled"
        
        // Update window title when file changes
        NotificationCenter.default.addObserver(
            forName: NSNotification.Name("FileChanged"),
            object: nil,
            queue: .main
        ) { [weak self] notification in
            self?.updateWindowTitle()
        }
    }
    
    private func updateWindowTitle() {
        if let url = appState.currentFileURL {
            window.title = "Markdown Editor - \(url.lastPathComponent)"
        } else if appState.isModified {
            window.title = "Markdown Editor - Untitled *"
        } else {
            window.title = "Markdown Editor - Untitled"
        }
    }
    
    func openFile(_ url: URL) {
        appState.loadMarkdown(from: url)
        updateWindowTitle()
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    private var documentControllers: [DocumentWindowController] = []

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Add observers for menu actions
        NotificationCenter.default.addObserver(self, selector: #selector(openFileAction(_:)), name: .openFile, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(exportToPdfAction(_:)), name: .exportPdf, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(saveFileAction(_:)), name: .saveFile, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(newFileAction(_:)), name: .newFile, object: nil)

        // Create the main menu
        let mainMenu = NSMenu()
        NSApp.mainMenu = mainMenu

        // Create the app menu
        let appMenuItem = NSMenuItem()
        mainMenu.addItem(appMenuItem)

        let appMenu = NSMenu()
        appMenuItem.submenu = appMenu
        appMenu.addItem(withTitle: "About Markdown Editor", action: #selector(showAboutAction(_:)), keyEquivalent: "")
        appMenu.addItem(NSMenuItem.separator())
        appMenu.addItem(withTitle: "Quit \(Bundle.main.infoDictionary?["CFBundleName"] as? String ?? "App")", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q")

        // Create the file menu
        let fileMenuItem = NSMenuItem()
        mainMenu.addItem(fileMenuItem)

        let fileMenu = NSMenu(title: "File")
        fileMenuItem.submenu = fileMenu
        fileMenu.addItem(withTitle: "New Window", action: #selector(newFileAction(_:)), keyEquivalent: "n")
        fileMenu.addItem(withTitle: "Open...", action: #selector(openFileAction(_:)), keyEquivalent: "o")
        fileMenu.addItem(withTitle: "Open in New Window...", action: #selector(openInNewWindowAction(_:)), keyEquivalent: "N")
        fileMenu.addItem(NSMenuItem.separator())
        fileMenu.addItem(withTitle: "Save", action: #selector(saveFileAction(_:)), keyEquivalent: "s")
        fileMenu.addItem(withTitle: "Export as PDF...", action: #selector(exportToPdfAction(_:)), keyEquivalent: "p")
        fileMenu.addItem(NSMenuItem.separator())
        fileMenu.addItem(withTitle: "About", action: #selector(showAboutAction(_:)), keyEquivalent: "")

        // Create the window menu
        let windowMenuItem = NSMenuItem()
        mainMenu.addItem(windowMenuItem)
        
        let windowMenu = NSMenu(title: "Window")
        windowMenuItem.submenu = windowMenu
        windowMenu.addItem(withTitle: "New Window", action: #selector(newFileAction(_:)), keyEquivalent: "n")
        windowMenu.addItem(withTitle: "Minimize", action: #selector(NSWindow.performMiniaturize(_:)), keyEquivalent: "m")
        windowMenu.addItem(NSMenuItem.separator())
        windowMenu.addItem(withTitle: "Bring All to Front", action: #selector(NSApplication.arrangeInFront(_:)), keyEquivalent: "")

        // Create initial document window
        createNewDocument()

        // Check for command-line arguments to open a file directly
        if CommandLine.arguments.count > 1 {
            let filePath = CommandLine.arguments[1]
            let fileURL = URL(fileURLWithPath: filePath)
            if let controller = documentControllers.first {
                controller.openFile(fileURL)
            }
        }
    }

    func applicationWillTerminate(_ aNotification: Notification) {}

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true
    }
    
    private func createNewDocument() {
        let controller = DocumentWindowController()
        documentControllers.append(controller)
        
        // Clean up controller when window closes
        NotificationCenter.default.addObserver(forName: NSWindow.willCloseNotification, object: controller.window, queue: .main) { [weak self] _ in
            self?.documentControllers.removeAll { $0.window == controller.window }
        }
    }
    
    func getCurrentDocumentController() -> DocumentWindowController? {
        // Return the controller for the key window
        if let keyWindow = NSApp.keyWindow {
            return documentControllers.first { $0.window == keyWindow }
        }
        return documentControllers.first
    }

    // Handle opening files from Finder
    func application(_ sender: NSApplication, openFile filename: String) -> Bool {
        let fileURL = URL(fileURLWithPath: filename)
        // Create new window for the file
        let controller = DocumentWindowController()
        documentControllers.append(controller)
        controller.openFile(fileURL)
        
        // Clean up controller when window closes
        NotificationCenter.default.addObserver(forName: NSWindow.willCloseNotification, object: controller.window, queue: .main) { [weak self] _ in
            self?.documentControllers.removeAll { $0.window == controller.window }
        }
        return true
    }

    // Action for the "Open" menu item
    @objc func openFileAction(_ sender: Any?) {
        getCurrentDocumentController()?.appState.openFile()
    }

    // Action for the "Export to PDF" menu item
    @objc func exportToPdfAction(_ sender: Any?) {
        getCurrentDocumentController()?.appState.exportToPdf()
    }
    
    // Action for the "Save" menu item
    @objc func saveFileAction(_ sender: Any?) {
        getCurrentDocumentController()?.appState.saveFile()
    }
    
    // Action for the "New" menu item
    @objc func newFileAction(_ sender: Any?) {
        createNewDocument()
    }
    
    // Action for the "Open in New Window" menu item
    @objc func openInNewWindowAction(_ sender: Any?) {
        let panel = NSOpenPanel()
        panel.canChooseFiles = true
        panel.canChooseDirectories = false
        panel.allowsMultipleSelection = true // Allow multiple file selection
        panel.allowedContentTypes = [.text]

        if panel.runModal() == .OK {
            for url in panel.urls {
                let controller = DocumentWindowController()
                documentControllers.append(controller)
                controller.openFile(url)
                
                // Clean up controller when window closes
                NotificationCenter.default.addObserver(forName: NSWindow.willCloseNotification, object: controller.window, queue: .main) { [weak self] _ in
                    self?.documentControllers.removeAll { $0.window == controller.window }
                }
            }
        }
    }
    
    // Action for the "About" menu item
    @objc func showAboutAction(_ sender: Any?) {
        let alert = NSAlert()
        alert.messageText = "Markdown Editor"
        alert.informativeText = """
        A powerful multi-window markdown editor with voice commands
        
        Author: Gunesh Raj
        GitHub: https://github.com/GuneshRaj/markdownviewer
        Version: 2.0
        
        Features:
        • Multi-window document support
        • Voice-to-markdown transcription
        • Live preview with comprehensive toolbar
        • Cross-platform (macOS & iPadOS)
        
        Built with SwiftUI and Speech frameworks
        """
        alert.alertStyle = .informational
        alert.addButton(withTitle: "OK")
        alert.addButton(withTitle: "Visit GitHub")
        
        let response = alert.runModal()
        
        // If user clicks "Visit GitHub" button
        if response == .alertSecondButtonReturn {
            if let url = URL(string: "https://github.com/GuneshRaj/markdownviewer") {
                NSWorkspace.shared.open(url)
            }
        }
    }
}
#endif

// MARK: - Views

struct ContentView: View {
    @EnvironmentObject var appState: AppState

    var body: some View {
        Group {
            switch appState.viewMode {
            case .viewer:
                WebView(appState: appState)
            case .editor:
                EditorView()
            case .splitView:
                SplitEditorView()
            }
        }
        .frame(minWidth: 800, minHeight: 600)
        .toolbar {
            ToolbarItemGroup(placement: .automatic) {
                // File operations
                Button(action: {
                    NotificationCenter.default.post(name: .newFile, object: nil)
                }) {
                    Label("New", systemImage: "doc.badge.plus")
                }
                
                Button(action: {
                    NotificationCenter.default.post(name: .openFile, object: nil)
                }) {
                    Label("Open", systemImage: "folder")
                }
                
                Button(action: {
                    NotificationCenter.default.post(name: .saveFile, object: nil)
                }) {
                    Label("Save", systemImage: "square.and.arrow.down")
                }
                
                Divider()
                
                // View mode toggle
                Picker("View Mode", selection: $appState.viewMode) {
                    Text("Viewer").tag(ViewMode.viewer)
                    Text("Editor").tag(ViewMode.editor)
                    Text("Split").tag(ViewMode.splitView)
                }
                .pickerStyle(SegmentedPickerStyle())
                
                Divider()
                
                // Voice controls
                Button(action: {
                    #if os(macOS)
                    if let delegate = NSApp.delegate as? AppDelegate,
                       let controller = delegate.getCurrentDocumentController() {
                        controller.voiceTranscriber.startListening()
                    }
                    #endif
                }) {
                    Label("Voice", systemImage: appState.voiceState == .listening ? "mic.fill" : "mic")
                }
                .foregroundColor(appState.voiceState == .listening ? .red : .primary)
                
                Divider()
                
                // Quick formatting buttons
                Button(action: {
                    appState.insertMarkdown(.bold)
                }) {
                    Label("Bold", systemImage: "bold")
                }
                
                Button(action: {
                    appState.insertMarkdown(.italic)
                }) {
                    Label("Italic", systemImage: "italic")
                }
                
                Button(action: {
                    appState.insertMarkdown(.code)
                }) {
                    Label("Code", systemImage: "chevron.left.slash.chevron.right")
                }
                
                // Comprehensive markdown dropdown
                Menu {
                    // Text formatting
                    Menu("Text Formatting") {
                        Button(action: { appState.insertMarkdown(.bold) }) {
                            Label("Bold", systemImage: "bold")
                        }
                        Button(action: { appState.insertMarkdown(.italic) }) {
                            Label("Italic", systemImage: "italic")
                        }
                        Button(action: { appState.insertMarkdown(.code) }) {
                            Label("Inline Code", systemImage: "chevron.left.slash.chevron.right")
                        }
                        Button(action: { appState.insertMarkdown(.strikethrough) }) {
                            Label("Strikethrough", systemImage: "strikethrough")
                        }
                    }
                    
                    // Headers
                    Menu("Headers") {
                        Button(action: { appState.insertMarkdown(.header1) }) {
                            Label("Header 1", systemImage: "1.circle")
                        }
                        Button(action: { appState.insertMarkdown(.header2) }) {
                            Label("Header 2", systemImage: "2.circle")
                        }
                        Button(action: { appState.insertMarkdown(.header3) }) {
                            Label("Header 3", systemImage: "3.circle")
                        }
                        Button(action: { appState.insertMarkdown(.header4) }) {
                            Label("Header 4", systemImage: "4.circle")
                        }
                        Button(action: { appState.insertMarkdown(.header5) }) {
                            Label("Header 5", systemImage: "5.circle")
                        }
                        Button(action: { appState.insertMarkdown(.header6) }) {
                            Label("Header 6", systemImage: "6.circle")
                        }
                    }
                    
                    // Lists
                    Menu("Lists") {
                        Button(action: { appState.insertMarkdown(.bulletList) }) {
                            Label("Bullet List", systemImage: "list.bullet")
                        }
                        Button(action: { appState.insertMarkdown(.numberedList) }) {
                            Label("Numbered List", systemImage: "list.number")
                        }
                        Button(action: { appState.insertMarkdown(.checkboxList) }) {
                            Label("Checkbox List", systemImage: "checklist")
                        }
                    }
                    
                    // Content blocks
                    Menu("Content Blocks") {
                        Button(action: { appState.insertMarkdown(.blockquote) }) {
                            Label("Blockquote", systemImage: "quote.bubble")
                        }
                        Button(action: { appState.insertMarkdown(.codeBlock) }) {
                            Label("Code Block", systemImage: "curlybraces")
                        }
                        Button(action: { appState.insertMarkdown(.table) }) {
                            Label("Table", systemImage: "tablecells")
                        }
                        Button(action: { appState.insertMarkdown(.horizontalRule) }) {
                            Label("Horizontal Rule", systemImage: "minus")
                        }
                    }
                    
                    // Links and media
                    Menu("Links & Media") {
                        Button(action: { appState.insertMarkdown(.link) }) {
                            Label("Link", systemImage: "link")
                        }
                        Button(action: { appState.insertMarkdown(.image) }) {
                            Label("Image", systemImage: "photo")
                        }
                    }
                    
                    Divider()
                    
                    // Line breaks
                    Button(action: { appState.insertMarkdown(.lineBreak) }) {
                        Label("Line Break", systemImage: "return")
                    }
                } label: {
                    Label("Markdown", systemImage: "textformat.alt")
                }
                
                Divider()
                
                Button(action: {
                    NotificationCenter.default.post(name: .exportPdf, object: nil)
                }) {
                    Label("Export to PDF", systemImage: "square.and.arrow.up")
                }
            }
        }
    }
    
}

struct EditorView: View {
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        VStack {
            if appState.voiceState == .listening {
                HStack {
                    Image(systemName: "mic.fill")
                        .foregroundColor(.red)
                    Text("Listening... \(appState.lastVoiceCommand)")
                        .font(.caption)
                    Spacer()
                }
                .padding(.horizontal)
                .padding(.vertical, 4)
                .background(Color.red.opacity(0.1))
            }
            
            MarkdownTextEditor(text: $appState.markdownText) { newText in
                appState.markdownText = newText
                appState.htmlContent = appState.renderMarkdown(from: newText)
                appState.isModified = true
            }
        }
    }
}

struct SplitEditorView: View {
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        VStack {
            if appState.voiceState == .listening {
                HStack {
                    Image(systemName: "mic.fill")
                        .foregroundColor(.red)
                    Text("Listening... \(appState.lastVoiceCommand)")
                        .font(.caption)
                    Spacer()
                }
                .padding(.horizontal)
                .padding(.vertical, 4)
                .background(Color.red.opacity(0.1))
            }
            
            HSplitView {
                VStack {
                    Text("Editor")
                        .font(.headline)
                        .padding(.top)
                    
                    MarkdownTextEditor(text: $appState.markdownText) { newText in
                        appState.markdownText = newText
                        appState.htmlContent = appState.renderMarkdown(from: newText)
                        appState.isModified = true
                    }
                }
                
                VStack {
                    Text("Preview")
                        .font(.headline)
                        .padding(.top)
                    
                    WebView(appState: appState)
                }
            }
        }
    }
}

struct WebView: NSViewRepresentable {
    @ObservedObject var appState: AppState

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeNSView(context: Context) -> WKWebView {
        appState.webView.navigationDelegate = context.coordinator
        return appState.webView
    }

    func updateNSView(_ nsView: WKWebView, context: Context) {
        if appState.htmlContent != context.coordinator.lastLoadedHTML {
            nsView.loadHTMLString(appState.htmlContent, baseURL: nil)
            context.coordinator.lastLoadedHTML = appState.htmlContent
        }
    }

    class Coordinator: NSObject, WKNavigationDelegate {
        var parent: WebView
        var lastLoadedHTML: String = ""

        init(_ parent: WebView) {
            self.parent = parent
        }
    }
}

// MARK: - Main Application Entry Point

#if os(macOS)
let delegate = AppDelegate()
let application = NSApplication.shared
application.delegate = delegate
application.run()
#else
// iOS App
@main
struct MarkdownEditorApp: App {
    @StateObject private var appState = AppState()
    @StateObject private var voiceTranscriber: VoiceTranscriber
    
    init() {
        let appState = AppState()
        _appState = StateObject(wrappedValue: appState)
        _voiceTranscriber = StateObject(wrappedValue: VoiceTranscriber(appState: appState))
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appState)
                .onAppear {
                    voiceTranscriber.appState = appState
                }
        }
    }
}
#endif