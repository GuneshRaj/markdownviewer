import SwiftUI
import WebKit
import AppKit

// Shared state for the application
class AppState: ObservableObject {
    @Published var htmlContent: String = "<html><body><h1>Markdown Viewer v1.0</h1><p>Gunesh.raj@gmail.com</p></body></html>"
    @Published var webView: WKWebView = WKWebView()
    @Published var currentFileURL: URL? = nil

    // MARK: - Core Logic

    func openFile() {
        let panel = NSOpenPanel()
        panel.canChooseFiles = true
        panel.canChooseDirectories = false
        panel.allowsMultipleSelection = false
        panel.allowedContentTypes = [.text] // Allows .md, .markdown, .txt etc.

        if panel.runModal() == .OK, let url = panel.url {
            _ = loadMarkdown(from: url)
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
                self.htmlContent = html
                self.currentFileURL = url
            }
            return true
        } catch {
            let errorHtml = "<html><body><h1>Error reading file</h1><p>\(error.localizedDescription)</p></body></html>"
            DispatchQueue.main.async {
                self.htmlContent = errorHtml
                self.currentFileURL = nil
            }
            return false
        }
    }

    private func renderMarkdown(from markdown: String) -> String {
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
    
    private func showAlert(title: String, message: String) {
        let alert = NSAlert()
        alert.messageText = title
        alert.informativeText = message
        alert.alertStyle = .critical
        alert.runModal()
    }
}

// MARK: - Application Setup

extension Notification.Name {
    static let openFile = Notification.Name("openFileNotification")
    static let exportPdf = Notification.Name("exportPdfNotification")
}

class AppDelegate: NSObject, NSApplicationDelegate {
    var window: NSWindow!
    var appState = AppState()

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Add observers for toolbar button actions
        NotificationCenter.default.addObserver(self, selector: #selector(openFileAction(_:)), name: .openFile, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(exportToPdfAction(_:)), name: .exportPdf, object: nil)

        // Create the main menu
        let mainMenu = NSMenu()
        NSApp.mainMenu = mainMenu

        // Create the app menu
        let appMenuItem = NSMenuItem()
        mainMenu.addItem(appMenuItem)

        let appMenu = NSMenu()
        appMenuItem.submenu = appMenu
        appMenu.addItem(withTitle: "Quit \(Bundle.main.infoDictionary?["CFBundleName"] as? String ?? "App")", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q")

        // Create the file menu
        let fileMenuItem = NSMenuItem()
        mainMenu.addItem(fileMenuItem)

        let fileMenu = NSMenu(title: "File")
        fileMenuItem.submenu = fileMenu
        fileMenu.addItem(withTitle: "Open...", action: #selector(openFileAction(_:)), keyEquivalent: "o")
        fileMenu.addItem(withTitle: "Export as PDF...", action: #selector(exportToPdfAction(_:)), keyEquivalent: "p")

        // Create the SwiftUI view
        let contentView = ContentView().environmentObject(appState)

        // Create the window and set the content view.
        window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 800, height: 600),
            styleMask: [.titled, .closable, .miniaturizable, .resizable, .fullSizeContentView],
            backing: .buffered, defer: false)
        window.center()
        window.setFrameAutosaveName("Main Window")
        window.contentView = NSHostingView(rootView: contentView)
        window.makeKeyAndOrderFront(nil)
        window.title = "Markdown Viewer"

        // Check for command-line arguments to open a file directly
        if CommandLine.arguments.count > 1 {
            // The first argument is the executable path, the second is the file.
            let filePath = CommandLine.arguments[1]
            let fileURL = URL(fileURLWithPath: filePath)
            _ = appState.loadMarkdown(from: fileURL)
        }
    }

    func applicationWillTerminate(_ aNotification: Notification) {}

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true
    }

    // Handle opening files from Finder
    func application(_ sender: NSApplication, openFile filename: String) -> Bool {
        let fileURL = URL(fileURLWithPath: filename)
        return appState.loadMarkdown(from: fileURL)
    }

    // Action for the "Open" menu item
    @objc func openFileAction(_ sender: Any?) {
        appState.openFile()
    }

    // Action for the "Export to PDF" menu item
    @objc func exportToPdfAction(_ sender: Any?) {
        appState.exportToPdf()
    }
}

// MARK: - Views

struct ContentView: View {
    @EnvironmentObject var appState: AppState

    var body: some View {
        WebView(appState: appState)
            .frame(minWidth: 800, minHeight: 600)
            .toolbar {
                ToolbarItemGroup(placement: .automatic) {
                    Button(action: {
                        NotificationCenter.default.post(name: .openFile, object: nil)
                    }) {
                        Label("Open", systemImage: "doc")
                    }
                    Button(action: {
                        NotificationCenter.default.post(name: .exportPdf, object: nil)
                    }) {
                        Label("Export to PDF", systemImage: "square.and.arrow.up")
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

// --- Main application entry point ---
let delegate = AppDelegate()
let application = NSApplication.shared
application.delegate = delegate
application.run()