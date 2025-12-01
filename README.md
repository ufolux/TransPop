# TransPop 🚀
> **Make Translation Simple Again** ✨

**Only support macOS now, will add other platform support later**

[简体中文](doc/README_zh-CN.md) | [繁體中文](doc/README_zh-TW.md) | [日本語](doc/README_ja.md) | [한국어](doc/README_ko.md) | [Français](doc/README_fr.md) | [Deutsch](doc/README_de.md) | [Español](doc/README_es.md)

<img width="562" height="712" alt="image" src="https://github.com/user-attachments/assets/c6787432-79fd-4f2f-8908-926065c8289c" />

Tired of the `Cmd+C` -> Open Browser -> Type "Google Translate" -> `Cmd+V` -> Cry -> Repeat cycle? 

Or a 300 MB download just to translate a few words?

Yeah, us too. That's why we built **TransPop**. It's like having a Babel fish in your menu bar, but less slimy.

## Why TransPop? 🧐

Because life is too short to manually copy-paste text into a browser tab.

### 🌟 Features that will make you go "Wow"

*   **The "Double Tap" Magic**: Press `Cmd+C` twice (Double Copy). Boom! Translation pops up. It's like summoning a genie, but for languages. 🧞‍♂️

<img width="509" height="291" alt="image" src="https://github.com/user-attachments/assets/1f2bf6f8-53c1-4f6e-ac1c-f43e2fd4ee02" />

*   **Mini Popup Mode**: The window appears *right where your cursor is*. We call it "Ninja Mode". You don't even have to move your mouse. 🥷
*   **Expandable UI**: Need more space? Click the expand button (arrows icon) in the Mini UI to switch to a full-sized window.
*   **Tray Icon**: We live in your status bar. Always watching. Always waiting. (In a non-creepy way). 👀
*   **Multiple Providers**: 
    *   **Google Translate (Free)**: Works out of the box. No setup required.
    *   **OpenAI / Ollama**: Connect to your local LLM (via Ollama) or OpenAI-compatible API for smarter translations.
*   **Language Swap**: One click to reverse the flow. `English -> Chinese` becomes `Chinese -> English`. Mind = Blown. 🤯
*   **Smart Close**: Choose whether to minimize to tray or quit the app when closing the window. You can even tell it to "Do not ask again".
*   **Dark Mode**: Because we are developers and light mode burns our retinas. 😎

*   **Tiny Size**: The app is only 1.8 MB. No need to download 300 MB of Electron just to translate a few words.

## 🛠 Tech Stack (The Nerd Stuff)

Built with pure, unadulterated **Swift** and **SwiftUI**. No Electron. No Chrome instances eating your RAM. Just pure, native performance. 🍏

*   **SwiftUI**: Declarative UI that looks good on macOS.
*   **AppKit**: For the nitty-gritty window management and status bar magic.
*   **Combine**: For reactive state management.

## 📥 How to Install

Don't want to build from source? We got you.

1.  Go to the [Releases](https://github.com/ufolux/TransPop/releases) page.
2.  Download the latest `.zip` file.
3.  Unzip it and drag `TransPop.app` into your `/Applications` folder.

### ⚠️ "App cannot be opened because the developer cannot be verified"?

If macOS complains that the app is damaged or can't be opened (because we haven't paid Apple $99/year yet), run this command in Terminal:

```bash
xattr -dr com.apple.quarantine /Applications/TransPop.app
```

Then try opening it again.

## 🏃‍♂️ How to Run (For Developers)

Want to run this bad boy locally? Here you go:

```bash
# 1. Clone the repo (duh)
git clone https://github.com/ufolux/TransPop.git

# 2. Go to the macos folder
cd macos

# 3. Run it! 🚀
swift run
```

## 📦 Build

Want to build a release version?

```bash
cd macos
swift build -c release
```

## ⚙️ Configuration

Access the **Settings** via the gear icon in the Full View.

### General
*   **Language**: Change the app interface language.
*   **Theme**: Toggle between Light, Dark, or System theme.
*   **Close Action**: Choose what happens when you close the window (Ask, Minimize, or Quit).

### Translation API
*   **Provider**: Switch between "Google (Free)" and "OpenAI Compatible".
*   **OpenAI Compatible Settings**:
    *   **API URL**: Default is `http://127.0.0.1:11434/v1/chat/completions` (perfect for Ollama).
    *   **API Key**: Optional for local LLMs.
    *   **Model**: Specify the model name (e.g., `llama3`, `gpt-4o`, `zongwei/gemma3-translator:1b` I tried this one, works perfectly for me).

## 🤝 Contributing

*Made with ❤️ and too much caffeine by ufolux*

