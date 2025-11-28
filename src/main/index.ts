import { app, shell, BrowserWindow, ipcMain, clipboard, Tray, Menu, nativeImage } from 'electron'
import { join } from 'path'
import { electronApp, optimizer, is } from '@electron-toolkit/utils'
import icon from '../../resources/icon.png?asset'


let mainWindow: BrowserWindow | null = null
let tray: Tray | null = null

function createWindow(): void {
  // Create the browser window.
  mainWindow = new BrowserWindow({
    width: 900,
    height: 670,
    show: false,
    autoHideMenuBar: true,
    frame: false, // Frameless for custom UI
    vibrancy: 'under-window', // macOS blur effect
    visualEffectState: 'active',
    ...(process.platform === 'linux' ? { icon } : {}),
    webPreferences: {
      preload: join(__dirname, '../preload/index.js'),
      sandbox: false
    }
  })

  mainWindow.on('ready-to-show', () => {
    mainWindow?.show()
    console.log('Window ready to show')
  })

  mainWindow.on('blur', () => {
     // Optional: hide on blur like DeepL
     // mainWindow?.hide()
  })

  mainWindow.webContents.setWindowOpenHandler((details) => {
    shell.openExternal(details.url)
    return { action: 'deny' }
  })

  // HMR for renderer base on electron-vite cli.
  // Load the remote URL for development or the local html file for production.
  if (is.dev && process.env['ELECTRON_RENDERER_URL']) {
    mainWindow.loadURL(process.env['ELECTRON_RENDERER_URL'])
  } else {
    mainWindow.loadFile(join(__dirname, '../renderer/index.html'))
  }
}

// This method will be called when Electron has finished
// initialization and is ready to create browser windows.
// Some APIs can only be used after this event occurs.
app.whenReady().then(() => {
  // Set app user model id for windows
  electronApp.setAppUserModelId('com.electron')

  // Default open or close DevTools by F12 in development
  // and ignore CommandOrControl + R in production.
  // see https://github.com/alex8088/electron-toolkit/tree/master/packages/utils
  app.on('browser-window-created', (_, window) => {
    optimizer.watchWindowShortcuts(window)
  })

  // IPC test
  ipcMain.on('ping', () => console.log('pong'))

  createWindow()

  // Create Tray
  // Use the custom tray icon (SVG)
  // Handle dev vs prod paths
  let iconPath = join(process.resourcesPath, 'tray.svg')
  if (is.dev) {
    iconPath = join(__dirname, '../../resources/tray.svg')
  }
  
  console.log('Loading tray icon from:', iconPath)
  const trayIcon = nativeImage.createFromPath(iconPath)
  // trayIcon.setTemplateImage(true) // Try without forcing template first, or keep it? 
  // Usually for SVG/PNG in tray, setTemplateImage(true) is correct for monochrome.
  trayIcon.setTemplateImage(true)
  
  tray = new Tray(trayIcon)
  const contextMenu = Menu.buildFromTemplate([
    { label: 'Show TransPop', click: () => mainWindow?.show() },
    { type: 'separator' },
    { label: 'Quit', click: () => app.quit() }
  ])
  tray.setToolTip('TransPop')
  tray.setContextMenu(contextMenu)
  
  tray.on('click', () => {
    if (mainWindow?.isVisible()) {
      mainWindow.hide()
    } else {
      mainWindow?.show()
      mainWindow?.focus()
    }
  })

  // Translation IPC
  const { translate } = require('google-translate-api-x')
  ipcMain.handle('translate', async (_, { text, source, target }) => {
    try {
      const options: any = { to: target, forceTo: true }
      if (source && source !== 'auto') {
        options.from = source
      }
      // Don't use forceFrom: true as it breaks if user selects wrong language
      
      console.log(`Translating '${text}' from ${source} to ${target}`)
      const res = await translate(text, options)
      return { text: res.text, from: res.from.language.iso }
    } catch (error) {
      console.error('Translation error:', error)
      return { text: '[Error] Could not translate', error }
    }
  })

  // Window Control IPC
  ipcMain.on('window-minimize', () => {
    mainWindow?.hide() // Minimize to tray means hide in this context
  })
  
  ipcMain.on('window-hide', () => {
    mainWindow?.hide()
  })

  const { dialog } = require('electron')
  ipcMain.on('window-close-request', async () => {
    if (!mainWindow) return
    
    const { response } = await dialog.showMessageBox(mainWindow, {
      type: 'question',
      buttons: ['Minimize to Tray', 'Quit App', 'Cancel'],
      defaultId: 0,
      title: 'Close TransPop',
      message: 'Do you want to minimize to the tray or quit the application?',
      detail: 'Minimizing keeps the app running in the background for global shortcuts.'
    })

    if (response === 0) {
      mainWindow.hide()
    } else if (response === 1) {
      app.quit()
    }
    // response === 2 is Cancel, do nothing
  })

  // Initialize uiohook
  const { uIOhook, UiohookKey } = require('uiohook-napi')
  const { screen } = require('electron')

  let lastCPressTime = 0
  const DOUBLE_PRESS_DELAY = 500 // ms

  uIOhook.on('keydown', (e) => {
    // Check for 'C' key (keycode 46)
    if (e.keycode === UiohookKey.C) {
      if (e.metaKey) {
        const now = Date.now()
        if (now - lastCPressTime < DOUBLE_PRESS_DELAY) {
          console.log('Double Cmd+C detected!')
          // Trigger translation
          setTimeout(() => {
            const text = clipboard.readText()
            console.log('Clipboard text:', text)
            if (mainWindow) {
              // Get cursor position
              const cursorPoint = screen.getCursorScreenPoint()
              // Move window to cursor
              // Offset slightly so it doesn't cover the text immediately
              const x = cursorPoint.x
              const y = cursorPoint.y + 20 
              
              mainWindow.setPosition(x, y)
              mainWindow.setSize(400, 300) // Mini size
              mainWindow.show()
              mainWindow.focus()
              
              // Send mode 'mini' to renderer
              mainWindow.webContents.send('set-mode', 'mini')
              mainWindow.webContents.send('on-translation-request', text)
            }
          }, 100)
          
          lastCPressTime = 0 // Reset
        } else {
          console.log('Single Cmd+C detected')
          lastCPressTime = now
        }
      }
    }
  })

  uIOhook.start()

  // Clean up on quit
  app.on('will-quit', () => {
    uIOhook.stop()
  })

  // IPC to expand window
  ipcMain.on('window-expand', () => {
    if (mainWindow) {
      mainWindow.setSize(900, 670)
      mainWindow.center()
      mainWindow.webContents.send('set-mode', 'full')
    }
  })


  app.on('activate', function () {
    // On macOS it's common to re-create a window in the app when the
    // dock icon is clicked and there are no other windows open.
    if (BrowserWindow.getAllWindows().length === 0) createWindow()
  })

  // Set Dock Icon on macOS
  if (process.platform === 'darwin') {
    app.dock?.setIcon(trayIcon)
  }
})

// Quit when all windows are closed, except on macOS. There, it's common
// for applications and their menu bar to stay active until the user quits
// explicitly with Cmd + Q.
app.on('window-all-closed', () => {
  if (process.platform !== 'darwin') {
    app.quit()
  }
  // On macOS, we keep the app running in tray even if window is closed (hidden)
})

// In this file you can include the rest of your app's specific main process
// code. You can also put them in separate files and require them here.
