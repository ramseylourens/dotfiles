const { contextBridge, ipcRenderer } = require('electron');

contextBridge.exposeInMainWorld('dotfilesShell', {
  getPresentationMode: () => ipcRenderer.invoke('presentation:get'),
  setPresentationMode: mode => ipcRenderer.invoke('presentation:set', mode),
  platform: process.platform,
});
