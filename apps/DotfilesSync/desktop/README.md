# Dotfiles Sync Desktop

The shared settings and UI are built with React Native. macOS uses the React Native macOS target; Linux and Windows run the shared web UI in Electron. iOS and Android are not supported or included in this desktop application.

## Requirements

- Node.js 22 or newer and Yarn 1.22 or newer.
- macOS development: Xcode and CocoaPods.
- Linux development and packaging: Linux with the native libraries required by Electron.
- Windows packaging: Windows 10/11 and PowerShell. Windows builds must run on Windows.

## Build and run

Install the shared dependencies:

```sh
yarn install --frozen-lockfile
```

For macOS, install CocoaPods and open `macos/ReactNativeStarter.xcodeproj` in Xcode. The repository installer builds and installs the app with:

```sh
./setup.sh --install-sync-app
```

For Linux:

```sh
yarn linux:install
yarn linux:dev
yarn linux:build
```

The Linux package build produces an AppImage and a Debian package under `linux/dist/`.

For Windows, use the following commands to build the portable app:

```powershell
yarn install --frozen-lockfile
yarn linux:install
yarn windows:build
```

The platform build scripts use `scripts/build-web.js` to set the production stage consistently across shells.

## Presentation mode

Open Settings to select a normal Dock/taskbar window or a compact menu-bar/system-tray mode. The choice is persisted between launches. In tray mode, closing the window hides it without quitting; use the tray menu to reopen or quit.

- macOS creates a menu-bar status item and switches between Dock and accessory-app behavior.
- Linux and Windows use Electron's system tray and persist the choice in Electron's user-data directory.

## Checks

```sh
yarn typecheck
yarn lint
yarn test
```

## License

This project is licensed under the MIT License.
