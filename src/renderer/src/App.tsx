import { useState, useEffect } from 'react'

const LANGUAGES = [
  { code: 'en', name: 'English' },
  { code: 'es', name: 'Spanish' },
  { code: 'fr', name: 'French' },
  { code: 'de', name: 'German' },
  { code: 'it', name: 'Italian' },
  { code: 'pt', name: 'Portuguese' },
  { code: 'ru', name: 'Russian' },
  { code: 'ja', name: 'Japanese' },
  { code: 'ko', name: 'Korean' },
  { code: 'zh-CN', name: 'Chinese (Simplified)' },
  { code: 'zh-TW', name: 'Chinese (Traditional)' },
  { code: 'nl', name: 'Dutch' },
  { code: 'pl', name: 'Polish' },
  { code: 'tr', name: 'Turkish' },
  { code: 'vi', name: 'Vietnamese' },
  { code: 'th', name: 'Thai' },
  { code: 'ar', name: 'Arabic' },
  { code: 'hi', name: 'Hindi' },
  { code: 'id', name: 'Indonesian' },
  { code: 'uk', name: 'Ukrainian' },
  { code: 'sv', name: 'Swedish' },
  { code: 'da', name: 'Danish' },
  { code: 'fi', name: 'Finnish' },
  { code: 'no', name: 'Norwegian' },
]

function App(): React.JSX.Element {
  const [sourceText, setSourceText] = useState('')
  const [targetText, setTargetText] = useState('')
  const [isLoading, setIsLoading] = useState(false)

  const [sourceLang, setSourceLang] = useState('auto')
  const [targetLang, setTargetLang] = useState('en')

  useEffect(() => {
    // Listen for translation requests from main process
    const removeListener = window.electron.ipcRenderer.on('on-translation-request', (_, text) => {
      console.log('Received text:', text)
      setSourceText(text as string)
      handleTranslate(text as string, sourceLang, targetLang)
    })

    return () => {
      removeListener()
    }
  }, [sourceLang, targetLang]) // Re-bind if langs change, or just pass current state to handler if we use refs or functional updates. 
  // Actually, handleTranslate closes over state. Better to use a ref or just rely on the fact that the effect runs once.
  // Wait, if the effect runs once, handleTranslate will use initial state. 
  // We should probably just call handleTranslate with the *current* state in the callback, but the callback is defined once.
  // Better approach: Use a ref for current langs, or update the listener when langs change.
  // Simplest for now: Update listener when langs change.

  const handleTranslate = async (text: string, src: string, tgt: string) => {
    setIsLoading(true)
    try {
      // @ts-ignore (api is exposed in preload)
      const result = await window.api.translate(text, src, tgt)
      setTargetText(result.text)

      // If source was auto, we might want to update UI to show detected lang, 
      // but for now let's just show the text.
      // result.from contains the detected language code if we want it.
      if (src === 'auto' && result.from) {
        // Optional: show detected language
        console.log('Detected:', result.from)
      }
    } catch (error) {
      console.error(error)
      setTargetText('[Error] Translation failed')
    } finally {
      setIsLoading(false)
    }
  }

  // Trigger translation when text or languages change
  useEffect(() => {
    const timer = setTimeout(() => {
      if (sourceText) {
        handleTranslate(sourceText, sourceLang, targetLang)
      }
    }, 800) // 800ms debounce delay

    return () => clearTimeout(timer)
  }, [sourceText, sourceLang, targetLang])



  const handleSwap = () => {
    // Swap languages
    if (sourceLang === 'auto') {
      setSourceLang(targetLang)
      setTargetLang('en') // Default to English if swapping from Auto
    } else {
      setSourceLang(targetLang)
      setTargetLang(sourceLang)
    }

    // Swap text
    setSourceText(targetText)
    setTargetText(sourceText)
  }

  const [viewMode, setViewMode] = useState<'full' | 'mini'>('full')

  useEffect(() => {
    // @ts-ignore
    const removeListener = window.api.onSetMode((mode) => {
      setViewMode(mode)
    })
    return () => {
      // Cleanup if needed, though onSetMode wrapper might not return cleanup
    }
  }, [])

  const handleExpand = () => {
    // @ts-ignore
    window.api.expandWindow()
  }

  return (
    <div className="h-screen flex flex-col bg-gray-900 text-white overflow-hidden rounded-lg border border-gray-700 shadow-2xl">
      {/* Header / Drag Area */}
      <div className="h-8 bg-gray-800 flex items-center justify-between px-4 draggable select-none">
        <span className="text-xs font-semibold text-gray-400">TransPop {viewMode === 'mini' ? '(Mini)' : ''}</span>
        <div className="flex space-x-2">
          {viewMode === 'mini' && (
            <button
              onClick={handleExpand}
              className="text-gray-500 hover:text-white focus:outline-none non-draggable"
              title="Expand to Full View"
            >
              ⤢
            </button>
          )}
          <button
            onClick={() => {
              // @ts-ignore
              window.api.minimize()
            }}
            className="text-gray-500 hover:text-white focus:outline-none non-draggable"
            title="Minimize to Tray"
          >
            ─
          </button>
          <button
            onClick={() => {
              // @ts-ignore
              window.api.closeRequest()
            }}
            className="text-gray-500 hover:text-white focus:outline-none non-draggable"
            title="Close"
          >
            ✕
          </button>
        </div>
      </div>

      {/* Content Area */}
      <div className="flex-1 flex flex-col p-4 space-y-4">

        {/* Source Language (Hidden in Mini Mode) */}
        {viewMode === 'full' && (
          <div className="flex-1 flex flex-col space-y-2">
            <div className="flex items-center justify-between">
              <select
                value={sourceLang}
                onChange={(e) => setSourceLang(e.target.value)}
                className="bg-gray-800 text-sm rounded px-2 py-1 outline-none focus:ring-1 focus:ring-blue-500"
              >
                <option value="auto">Detect Language</option>
                {LANGUAGES.map(lang => (
                  <option key={lang.code} value={lang.code}>{lang.name}</option>
                ))}
              </select>
            </div>
            <textarea
              className="flex-1 bg-gray-800 rounded p-3 resize-none outline-none focus:ring-1 focus:ring-blue-500 text-sm"
              placeholder="Type or paste text here..."
              value={sourceText}
              onChange={(e) => setSourceText(e.target.value)}
            />
          </div>
        )}

        {/* Swap Button (Hidden in Mini Mode) */}
        {viewMode === 'full' && (
          <div className="flex justify-center -my-2 z-10">
            <button onClick={handleSwap} className="bg-gray-700 hover:bg-gray-600 rounded-full p-2 shadow-md transition-colors">
              <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
                <path d="M7 10v12" /><path d="M15 10v12" /><path d="M11 14l-4-4-4 4" /><path d="M11 18l4 4 4-4" />
              </svg>
            </button>
          </div>
        )}

        {/* Target Language */}
        <div className="flex-1 flex flex-col space-y-2">
          <div className="flex items-center justify-between">
            <select
              value={targetLang}
              onChange={(e) => setTargetLang(e.target.value)}
              className="bg-gray-800 text-sm rounded px-2 py-1 outline-none focus:ring-1 focus:ring-blue-500"
            >
              {LANGUAGES.map(lang => (
                <option key={lang.code} value={lang.code}>{lang.name}</option>
              ))}
            </select>
            {isLoading && <span className="text-xs text-blue-400 animate-pulse">Translating...</span>}
          </div>
          <textarea
            className="flex-1 bg-gray-800 rounded p-3 resize-none outline-none focus:ring-1 focus:ring-blue-500 text-sm"
            placeholder="Translation will appear here..."
            value={targetText}
            readOnly
          />
        </div>

      </div>
    </div>

  )
}

export default App
