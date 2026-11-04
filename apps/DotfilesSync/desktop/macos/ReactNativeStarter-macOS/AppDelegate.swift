import SwiftUI
import React
import React_RCTAppDelegate
import ReactAppDependencyProvider

@main
struct ReactNativeStarterApp: App {
  @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

  var body: some Scene {
    Window("Dotfiles Sync", id: "main") {
      ReactNativeView(factory: appDelegate.reactNativeFactory)
    }
    .defaultSize(width: 900, height: 640)
  }
}

// MARK: - App Delegate

class AppDelegate: NSObject, NSApplicationDelegate {
  private let reactNativeDelegate: ReactNativeDelegate
  private var statusItem: NSStatusItem?
  private var presentationModeObserver: NSObjectProtocol?
  let reactNativeFactory: RCTReactNativeFactory

  func applicationDidFinishLaunching(_ notification: Notification) {
    let item = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
    item.button?.image = NSImage(
      systemSymbolName: "arrow.triangle.2.circlepath",
      accessibilityDescription: "Dotfiles Sync"
    )
    item.button?.toolTip = "Dotfiles Sync"

    let menu = NSMenu()
    menu.addItem(NSMenuItem(title: "Open Dotfiles Sync", action: #selector(openMainWindow), keyEquivalent: "o"))
    menu.addItem(NSMenuItem.separator())
    menu.addItem(NSMenuItem(title: "Quit", action: #selector(quitApplication), keyEquivalent: "q"))
    item.menu = menu
    statusItem = item

    presentationModeObserver = NotificationCenter.default.addObserver(
      forName: .dotfilesPresentationModeChanged,
      object: nil,
      queue: .main
    ) { [weak self] _ in
      self?.applyPresentationMode()
    }
    applyPresentationMode()
  }

  func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
    UserDefaults.standard.string(forKey: "dotfiles.presentationMode") != "tray"
  }

  @objc private func openMainWindow() {
    NSApp.activate(ignoringOtherApps: true)
    NSApp.windows.first?.makeKeyAndOrderFront(nil)
  }

  @objc private func quitApplication() {
    NSApp.terminate(nil)
  }

  private func applyPresentationMode() {
    let isTrayMode = UserDefaults.standard.string(forKey: "dotfiles.presentationMode") == "tray"
    statusItem?.isVisible = isTrayMode
    NSApp.setActivationPolicy(isTrayMode ? .accessory : .regular)
    if isTrayMode {
      NSApp.windows.forEach { $0.orderOut(nil) }
    }
  }

  override init() {
    let delegate = ReactNativeDelegate()
    let factory = RCTReactNativeFactory(delegate: delegate)
    delegate.dependencyProvider = RCTAppDependencyProvider()

    reactNativeDelegate = delegate
    reactNativeFactory = factory
    super.init()
  }

  deinit {
    if let presentationModeObserver {
      NotificationCenter.default.removeObserver(presentationModeObserver)
    }
  }
}

// MARK: - React Native Delegate

class ReactNativeDelegate: RCTDefaultReactNativeFactoryDelegate {
  override func sourceURL(for bridge: RCTBridge) -> URL? {
    bundleURL()
  }

  override func bundleURL() -> URL? {
#if DEBUG
    RCTBundleURLProvider.sharedSettings().jsBundleURL(forBundleRoot: "index")
#else
    Bundle.main.url(forResource: "main", withExtension: "jsbundle")
#endif
  }
}

// MARK: - React Native SwiftUI View

struct ReactNativeView: NSViewRepresentable {
  let factory: RCTReactNativeFactory

  func makeNSView(context: Context) -> NSView {
    factory.rootViewFactory.view(withModuleName: "DotfilesSync")
  }

  func updateNSView(_ nsView: NSView, context: Context) {}
}
