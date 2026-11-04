import Foundation
import React

extension Notification.Name {
  static let dotfilesPresentationModeChanged = Notification.Name("DotfilesPresentationModeChanged")
}

@objc(PresentationModeModule)
final class PresentationModeModule: NSObject {
  @objc static func requiresMainQueueSetup() -> Bool {
    true
  }

  @objc func getMode(
    _ resolve: RCTPromiseResolveBlock,
    rejecter reject: RCTPromiseRejectBlock
  ) {
    resolve(UserDefaults.standard.string(forKey: "dotfiles.presentationMode") ?? "window")
  }

  @objc func setMode(
    _ mode: String,
    resolver resolve: RCTPromiseResolveBlock,
    rejecter reject: RCTPromiseRejectBlock
  ) {
    guard mode == "window" || mode == "tray" else {
      reject("invalid_mode", "Expected 'window' or 'tray'.", nil)
      return
    }

    DispatchQueue.main.async {
      UserDefaults.standard.set(mode, forKey: "dotfiles.presentationMode")
      NotificationCenter.default.post(name: .dotfilesPresentationModeChanged, object: nil)
      resolve(mode)
    }
  }
}
