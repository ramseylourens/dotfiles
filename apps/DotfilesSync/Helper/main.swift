import Foundation

let home = FileManager.default.homeDirectoryForCurrentUser
let repository = home.appendingPathComponent("dotfiles", isDirectory: true)
let script = repository.appendingPathComponent("bin/dotfiles-hourly-sync")
let logs = home.appendingPathComponent("Library/Logs/DotfilesSync", isDirectory: true)
let logFile = logs.appendingPathComponent("sync.log")

func log(_ text: String, to handle: FileHandle) {
    let line = "\(Date()): \(text)\n"
    if let data = line.data(using: .utf8) {
        handle.write(data)
    }
}

do {
    try FileManager.default.createDirectory(at: logs, withIntermediateDirectories: true)
    if !FileManager.default.fileExists(atPath: logFile.path) {
        FileManager.default.createFile(atPath: logFile.path, contents: nil)
    }
    let handle = try FileHandle(forWritingTo: logFile)
    defer { try? handle.close() }
    try handle.seekToEnd()

    guard FileManager.default.fileExists(atPath: script.path) else {
        log("Dotfiles sync script not found at \(script.path)", to: handle)
        exit(1)
    }

    log("Starting hourly sync", to: handle)
    let process = Process()
    process.executableURL = URL(fileURLWithPath: "/bin/zsh")
    process.arguments = [script.path]
    process.currentDirectoryURL = repository
    process.environment = [
        "HOME": home.path,
        "PATH": "/opt/homebrew/bin:/opt/homebrew/sbin:/usr/local/bin:/usr/local/sbin:/opt/local/bin:/opt/local/sbin:/usr/bin:/bin:/usr/sbin:/sbin",
        "SHELL": "/bin/zsh",
        "GIT_TERMINAL_PROMPT": "0",
    ]
    process.standardOutput = handle
    process.standardError = handle
    try process.run()
    process.waitUntilExit()
    log("Sync exited with status \(process.terminationStatus)", to: handle)
    exit(process.terminationStatus)
} catch {
    FileHandle.standardError.write(Data("Dotfiles sync helper failed: \(error)\n".utf8))
    exit(1)
}
