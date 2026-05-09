import AppKit

@main
struct K8Switcher {
  static func main() {
    let app = NSApplication.shared
    let delegate = AppDelegate()
    app.delegate = delegate
    app.run()
  }
}

class AppDelegate: NSObject, NSApplicationDelegate, NSMenuDelegate {
  private var statusItem: NSStatusItem!

  func applicationDidFinishLaunching(_ notification: Notification) {
    NSApp.setActivationPolicy(.accessory)

    statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)

    if let button = statusItem.button {
      // button.title = "\(getCurrentContext())"
      button.title = "K8S"
    }

    buildMenu()
    statusItem.menu?.delegate = self
  }

  // MARK: - NSMenuDelegate

  func menuWillOpen(_ menu: NSMenu) {
    buildMenu()
    statusItem.menu?.delegate = self
  }

  @MainActor
  func buildMenu() {
    let menu = NSMenu()
    menu.delegate = self

    let contexts = getKubeContexts()
    let current = getCurrentContext()

    // обновляем кнопку
    if let button = statusItem.button {
      if current.isEmpty {
        button.title = "K8S"
      } else {
        let truncated = String(current.prefix(8))
        button.title = truncated
      }
    }

    for context in contexts {
      let item = NSMenuItem(
        title: context,
        action: #selector(switchContext(_:)),
        keyEquivalent: ""
      )
      item.target = self
      if context == current {
        item.state = .on
      }
      menu.addItem(item)
    }

    menu.addItem(.separator())
    menu.addItem(
      NSMenuItem(title: "Quit", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))

    statusItem.menu = menu
  }
  @MainActor
  @objc func switchContext(_ sender: NSMenuItem) {
    let context = sender.title
    runCommand("kubectl config use-context \(context)")
    buildMenu()
  }

  // MARK: - kubectl helpers

  func getKubeContexts() -> [String] {
    let output = runCommand("kubectl config get-contexts -o name")
    NSLog("kubectl output: '\(output)'")
    return output.split(separator: "\n").map(String.init).filter { !$0.isEmpty }
  }

  func getCurrentContext() -> String {
    return runCommand("kubectl config current-context").trimmingCharacters(
      in: .whitespacesAndNewlines)
  }

  @discardableResult
  func runCommand(_ command: String) -> String {
    let process = Process()
    let pipe = Pipe()

    process.executableURL = URL(fileURLWithPath: "/bin/bash")
    process.arguments = ["-c", command]
    process.standardOutput = pipe
    process.standardError = pipe
    process.environment = [
      "PATH": "/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin",
      "HOME": NSHomeDirectory(),
    ]

    try? process.run()
    process.waitUntilExit()

    let data = pipe.fileHandleForReading.readDataToEndOfFile()
    return String(data: data, encoding: .utf8) ?? ""
  }
}
