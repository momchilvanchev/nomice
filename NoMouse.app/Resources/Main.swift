import Cocoa

// Create the AppDelegate class
class AppDelegate: NSObject, NSApplicationDelegate {

    var statusItem: NSStatusItem!

    func applicationDidFinishLaunching(_ notification: Notification) {
        // Hide app from dock
        NSApp.setActivationPolicy(.accessory)

        // Create the status bar item
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        statusItem.title = "NoMouse"

        // Add the custom icon
        if let icon = NSImage(named: "YourIconName") {  // Replace with your icon's name
            statusItem.button?.image = icon
        }

        // Add the menu to the status bar item
        statusItem.menu = createStatusMenu()

        // Run the executable (nomouse)
        runExecutable()
    }

    func createStatusMenu() -> NSMenu {
        let menu = NSMenu()

        // Add Quit option to the menu
        menu.addItem(NSMenuItem(title: "Quit", action: #selector(quitApp), keyEquivalent: "q"))

        return menu
    }

    @objc func quitApp() {
        NSApplication.shared.terminate(self)
    }

    func runExecutable() {
        // Path to the 'nomouse' executable
        let task = Process()
        task.launchPath = "../Resources/nomouse"  // Replace with actual path to nomouse executable
        task.launch()
    }
}

// Start the application
let app = NSApplication.shared
let delegate = AppDelegate()
app.delegate = delegate
app.run()
