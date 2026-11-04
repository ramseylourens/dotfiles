const path = require('path');
const fs = require('fs');
const { app, BrowserWindow, ipcMain, Menu, nativeImage, session, shell, Tray } = require('electron');

// Set WEB_URL to load the webpack dev server instead of the bundled web build.
const devUrl = process.env.WEB_URL;
const isSmokeTest = process.env.SMOKE_TEST === '1';
const validPresentationModes = new Set(['window', 'tray']);
let presentationMode = 'window';
let mainWindow;
let tray;
let isQuitting = false;

if (!app.requestSingleInstanceLock()) {
  app.quit();
}

function isAllowedUrl(url) {
  if (devUrl && url.startsWith(devUrl)) {
    return true;
  }
  return url.startsWith('file://');
}

function settingsPath() {
  return path.join(app.getPath('userData'), 'settings.json');
}

function readPresentationMode() {
  try {
    const settings = JSON.parse(fs.readFileSync(settingsPath(), 'utf8'));
    return validPresentationModes.has(settings.presentationMode) ? settings.presentationMode : 'window';
  } catch (error) {
    if (error.code !== 'ENOENT') {
      throw error;
    }
    return 'window';
  }
}

function writePresentationMode(mode) {
  fs.mkdirSync(app.getPath('userData'), { recursive: true });
  fs.writeFileSync(settingsPath(), JSON.stringify({ presentationMode: mode }, null, 2));
}

function showMainWindow() {
  if (!mainWindow || mainWindow.isDestroyed()) {
    createWindow();
  }
  if (mainWindow.isMinimized()) {
    mainWindow.restore();
  }
  mainWindow.show();
  mainWindow.focus();
}

function createTray() {
  if (tray) {
    return;
  }

  const iconPath = path.join(__dirname, 'app', 'Icon.png');
  const icon = nativeImage.createFromPath(iconPath);
  if (icon.isEmpty()) {
    throw new Error(`Could not load system tray icon: ${iconPath}`);
  }

  tray = new Tray(icon.resize({ width: 20, height: 20 }));
  tray.setToolTip('Dotfiles Sync');
  tray.setContextMenu(Menu.buildFromTemplate([
    { label: 'Open Dotfiles Sync', click: showMainWindow },
    { type: 'separator' },
    { label: 'Quit', click: () => { isQuitting = true; app.quit(); } },
  ]));
  tray.on('click', showMainWindow);
}

function applyPresentationMode(mode) {
  if (mode === 'tray') {
    createTray();
    presentationMode = mode;
    if (mainWindow && !mainWindow.isDestroyed()) {
      mainWindow.hide();
    }
    return;
  }

  presentationMode = 'window';
  if (tray) {
    tray.destroy();
    tray = undefined;
  }
  showMainWindow();
}

function createWindow() {
  mainWindow = new BrowserWindow({
    width: 1280,
    height: 800,
    show: false,
    webPreferences: {
      contextIsolation: true,
      nodeIntegration: false,
      sandbox: true,
      preload: path.join(__dirname, 'preload.js'),
    },
  });

  mainWindow.once('ready-to-show', () => {
    if (presentationMode === 'window') {
      mainWindow.show();
    }
  });

  mainWindow.webContents.setWindowOpenHandler(({ url }) => {
    if (/^https?:\/\//.test(url)) {
      shell.openExternal(url);
    }
    return { action: 'deny' };
  });

  mainWindow.webContents.on('will-navigate', (event, url) => {
    if (!isAllowedUrl(url)) {
      event.preventDefault();
    }
  });

  if (isSmokeTest) {
    mainWindow.webContents.once('did-finish-load', () => app.exit(0));
    mainWindow.webContents.once('did-fail-load', () => app.exit(1));
  }

  if (devUrl) {
    mainWindow.loadURL(devUrl);
    mainWindow.webContents.openDevTools({ mode: 'detach' });
  } else {
    mainWindow.loadFile(path.join(__dirname, 'app', 'index.html'));
  }

  mainWindow.on('close', event => {
    if (presentationMode === 'tray' && !isQuitting) {
      event.preventDefault();
      mainWindow.hide();
    }
  });
  mainWindow.on('closed', () => { mainWindow = undefined; });
}

app.whenReady().then(() => {
  session.defaultSession.setPermissionRequestHandler((_wc, _permission, callback) => callback(false));
  ipcMain.handle('presentation:get', () => presentationMode);
  ipcMain.handle('presentation:set', (_event, mode) => {
    if (!validPresentationModes.has(mode)) {
      throw new Error(`Unsupported presentation mode: ${mode}`);
    }

    applyPresentationMode(mode);
    writePresentationMode(mode);
    return mode;
  });

  presentationMode = readPresentationMode();
  createWindow();
  if (presentationMode === 'tray') {
    createTray();
  }

  app.on('activate', () => {
    showMainWindow();
  });
});

app.on('second-instance', () => {
  showMainWindow();
});

app.on('before-quit', () => { isQuitting = true; });
app.on('window-all-closed', () => {
  if (presentationMode !== 'tray') {
    app.quit();
  }
});
