import { contextBridge } from 'electron'
import { electronAPI } from '@electron-toolkit/preload'

// Custom APIs for renderer
const api = {
  translate: (text: string, source: string, target: string) => 
    electronAPI.ipcRenderer.invoke('translate', { text, source, target }),
  minimize: () => electronAPI.ipcRenderer.send('window-minimize'),
  hide: () => electronAPI.ipcRenderer.send('window-hide'),
  closeRequest: () => electronAPI.ipcRenderer.send('window-close-request'),
  expandWindow: () => electronAPI.ipcRenderer.send('window-expand'),
  onSetMode: (callback: (mode: 'full' | 'mini') => void) => 
    electronAPI.ipcRenderer.on('set-mode', (_, mode) => callback(mode))
}

// Use `contextBridge` APIs to expose Electron APIs to
// renderer only if context isolation is enabled, otherwise
// just add to the DOM global.
if (process.contextIsolated) {
  try {
    contextBridge.exposeInMainWorld('electron', electronAPI)
    contextBridge.exposeInMainWorld('api', api)
  } catch (error) {
    console.error(error)
  }
} else {
  // @ts-ignore (define in dts)
  window.electron = electronAPI
  // @ts-ignore (define in dts)
  window.api = api
}
