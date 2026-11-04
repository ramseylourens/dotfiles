import ServiceManagement
import SwiftUI

@main
struct DotfilesSyncApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .frame(width: 440, height: 300)
        }
    }
}

struct ContentView: View {
    @State private var statusText = "Checking background service..."
    @State private var message = ""
    @State private var isRunning = false

    private var service: SMAppService {
        SMAppService.agent(plistName: "com.ramseylourens.DotfilesSync.agent.plist")
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Dotfiles Sync")
                .font(.largeTitle.bold())

            Text("Background service: \(statusText)")
                .font(.headline)

            Text("The helper syncs package inventories hourly and pushes only those inventory files to origin/main.")
                .foregroundStyle(.secondary)

            HStack {
                Button("Enable Background Sync") {
                    registerService()
                }
                Button("Disable") {
                    unregisterService()
                }
                Button(isRunning ? "Running..." : "Run Now") {
                    runHelper()
                }
                .disabled(isRunning)
            }

            if !message.isEmpty {
                Text(message)
                    .font(.callout)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer()

            Text("If macOS requests approval, enable Dotfiles Sync under System Settings → General → Login Items → Allow in the Background.")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(24)
        .onAppear {
            refreshStatus()
            if service.status == .notRegistered {
                registerService()
            }
        }
    }

    private func refreshStatus() {
        switch service.status {
        case .enabled:
            statusText = "Enabled"
        case .requiresApproval:
            statusText = "Waiting for approval in System Settings"
        case .notRegistered:
            statusText = "Not enabled"
        case .notFound:
            statusText = "Helper not found in app bundle"
        @unknown default:
            statusText = "Unknown"
        }
    }

    private func registerService() {
        do {
            try service.register()
            message = "Background sync registration requested."
        } catch {
            message = "Could not register background sync: \(error.localizedDescription)"
        }
        refreshStatus()
    }

    private func unregisterService() {
        do {
            try service.unregister()
            message = "Background sync disabled."
        } catch {
            message = "Could not disable background sync: \(error.localizedDescription)"
        }
        refreshStatus()
    }

    private func runHelper() {
        guard let helperURL = Bundle.main.executableURL?
            .deletingLastPathComponent()
            .appendingPathComponent("..")
            .appendingPathComponent("Helpers")
            .appendingPathComponent("DotfilesSyncHelper") else {
            message = "Could not locate the background helper."
            return
        }

        isRunning = true
        message = "Running dotfiles sync..."
        DispatchQueue.global(qos: .utility).async {
            let process = Process()
            process.executableURL = helperURL
            do {
                try process.run()
                process.waitUntilExit()
                DispatchQueue.main.async {
                    isRunning = false
                    message = process.terminationStatus == 0
                        ? "Sync completed."
                        : "Sync failed with exit code \(process.terminationStatus). Check ~/Library/Logs/DotfilesSync/sync.log."
                }
            } catch {
                DispatchQueue.main.async {
                    isRunning = false
                    message = "Could not start sync: \(error.localizedDescription)"
                }
            }
        }
    }
}
