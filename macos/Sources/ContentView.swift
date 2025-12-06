import SwiftUI
import Cocoa

struct ContentView: View {
    @ObservedObject var appState = AppState.shared
    @ObservedObject var localization = LocalizationManager.shared
    @AppStorage("appTheme") private var appTheme: String = "system"
    
    var body: some View {
        Group {
            if appState.viewMode == .mini {
                MiniView()
            } else {
                FullView()
            }
        }

        .edgesIgnoringSafeArea(.top)
    }
}

// MARK: - Mini View
struct MiniView: View {
    @ObservedObject var appState = AppState.shared
    @ObservedObject var localization = LocalizationManager.shared
    @ObservedObject var speechService = SpeechService.shared
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                LogoView(size: 28)
                
                Menu {
                    Picker("", selection: $appState.targetLang) {
                        Text("English").tag("en")
                        Text("Chinese (S)").tag("zh-CN")
                        Text("Chinese (T)").tag("zh-TW")
                        Text("Japanese").tag("ja")
                        Text("Korean").tag("ko")
                        Text("French").tag("fr")
                        Text("German").tag("de")
                        Text("Spanish").tag("es")
                    }
                    .pickerStyle(.inline)
                    .labelsHidden()
                } label: {
                    HStack(spacing: 4) {
                        Text(languageName(for: appState.targetLang))
                            .font(.system(.subheadline, design: .rounded).weight(.bold))
                            .foregroundColor(.secondary)
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(6)
                }
                .menuStyle(.borderlessButton)
                .fixedSize()
                .onChange(of: appState.targetLang) { _ in
                    appState.performTranslation()
                }
                
                Spacer()
                
                // Speak Button
                Button(action: {
                    if speechService.isSpeaking {
                        speechService.stop()
                    } else {
                        speechService.speak(appState.targetText, language: appState.targetLang)
                    }
                }) {
                    Image(systemName: speechService.isSpeaking ? "stop.fill" : "speaker.wave.2")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(speechService.isSpeaking ? .red : .secondary)
                        .padding(6)
                        .background(Color.gray.opacity(0.1))
                        .clipShape(Circle())
                }
                .buttonStyle(.plain)
                .help(speechService.isSpeaking ? "main.stop_speaking".localized : "main.read_aloud".localized)
                .padding(.trailing, 4)
                
                // Copy Button
                Button(action: {
                    NSPasteboard.general.clearContents()
                    NSPasteboard.general.setString(appState.targetText, forType: .string)
                }) {
                    Image(systemName: "doc.on.doc")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.secondary)
                        .padding(6)
                        .background(Color.gray.opacity(0.1))
                        .clipShape(Circle())
                }
                .buttonStyle(.plain)
                .help("main.copy".localized)
                .padding(.trailing, 4)
                
                // Expand Button
                Button(action: {
                    NotificationCenter.default.post(name: NSNotification.Name("ExpandWindow"), object: nil)
                }) {
                    Image(systemName: "arrow.up.left.and.arrow.down.right")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.secondary)
                        .padding(6)
                        .background(Color.gray.opacity(0.1))
                        .clipShape(Circle())
                }
                .buttonStyle(.plain)
                .help("Expand to Full View")
            }
            .padding(.horizontal, 12)
            .padding(.top, 40)
            .padding(.bottom, 10)
            .background(VisualEffectView(material: .hudWindow, blendingMode: .behindWindow))
            
            Divider()
                .opacity(0.5)
            
            // Content
            ZStack(alignment: .bottomTrailing) {
                ScrollView {
                    Text(appState.targetText)
                        .font(.system(.body, design: .rounded))
                        .padding(12)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .textSelection(.enabled)
                        .foregroundColor(.primary)
                }
                
                if appState.isTranslating {
                    ProgressView()
                        .scaleEffect(0.5)
                        .padding(8)
                        .background(Material.ultraThinMaterial, in: Circle())
                        .padding(8)
                }
            }
            .background(Color(NSColor.textBackgroundColor))
        }
        .frame(minWidth: 300, minHeight: 200)
        .cornerRadius(12)
        .background(
            Button("") {
                NSApp.keyWindow?.performClose(nil)
            }
            .keyboardShortcut(.cancelAction)
            .opacity(0)
        )
    }
    
    func languageName(for code: String) -> String {
        return "lang.\(code)".localized
    }
}

// MARK: - Full View
struct FullView: View {
    @ObservedObject var appState = AppState.shared
    @ObservedObject var localization = LocalizationManager.shared
    @State private var showSettings = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                HStack(spacing: 8) {
                    LogoView(size: 32)
                    
                    Text("app.name".localized)
                        .font(.system(.title3, design: .rounded).weight(.bold))
                }
                
                Spacer()
                
                Button(action: {
                    showSettings.toggle()
                }) {
                    Image(systemName: "gearshape.fill")
                        .font(.system(size: 16))
                        .foregroundColor(.secondary)
                        .padding(8)
                        .background(Color.gray.opacity(0.1))
                        .clipShape(Circle())
                }
                .buttonStyle(.plain)
                .popover(isPresented: $showSettings) {
                    SettingsView()
                }
            }
            .padding(.top, 44)
            .padding(.horizontal, 20)
            .padding(.bottom, 16)
            .background(VisualEffectView(material: .headerView, blendingMode: .withinWindow))
            
            // Content Area
            VStack(spacing: 0) {
                // Source Card
                TranslationCard(
                    text: $appState.sourceText,
                    selection: $appState.sourceLang,
                    isSource: true,
                    onLangChange: { appState.performTranslation() },
                    onTextChange: { appState.performTranslation() }
                )
                
                // Swap Button Area
                ZStack {
                    Rectangle()
                        .fill(Color.gray.opacity(0.1))
                        .frame(height: 1)
                    
                    Button(action: {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            let tempLang = appState.sourceLang
                            appState.sourceLang = appState.targetLang
                            appState.targetLang = tempLang == "auto" ? "en" : tempLang
                            
                            let tempText = appState.sourceText
                            appState.sourceText = appState.targetText
                            appState.targetText = tempText
                        }
                    }, label: {
                        Image(systemName: "arrow.up.arrow.down")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.blue)
                            .frame(width: 32, height: 32)
                            .background(Circle().fill(Color(NSColor.windowBackgroundColor)))
                            .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
                            .overlay(Circle().stroke(Color.gray.opacity(0.2), lineWidth: 1))
                    })
                    .buttonStyle(.plain)
                }
                .padding(.vertical, -16) // Overlap cards slightly
                .zIndex(1)
                
                // Target Card
                TranslationCard(
                    text: $appState.targetText,
                    selection: $appState.targetLang,
                    isSource: false,
                    isLoading: appState.isTranslating,
                    onLangChange: { appState.performTranslation() }
                )
            }
            .background(Color(NSColor.windowBackgroundColor))
        }
        .frame(minWidth: 400, minHeight: 500)
    }
}

// MARK: - Components

struct TranslationCard: View {
    @Binding var text: String
    @Binding var selection: String
    var isSource: Bool
    var isLoading: Bool = false
    var onLangChange: () -> Void
    var onTextChange: (() -> Void)? = nil
    @ObservedObject var localization = LocalizationManager.shared
    @ObservedObject var speechService = SpeechService.shared
    
    var body: some View {
        VStack(spacing: 0) {
            // Card Header
            HStack {
                Menu {
                    Picker("", selection: $selection) {
                        if isSource {
                            Text("main.detect_language".localized).tag("auto")
                        }
                        Text("lang.en".localized).tag("en")
                        Text("lang.zh-CN".localized).tag("zh-CN")
                        Text("lang.zh-TW".localized).tag("zh-TW")
                        Text("lang.ja".localized).tag("ja")
                        Text("lang.ko".localized).tag("ko")
                        Text("lang.fr".localized).tag("fr")
                        Text("lang.de".localized).tag("de")
                        Text("lang.es".localized).tag("es")
                    }
                    .pickerStyle(.inline)
                    .labelsHidden()
                } label: {
                    HStack(spacing: 4) {
                        Text(languageName(for: selection))
                            .font(.system(.subheadline, design: .rounded).weight(.semibold))
                            .foregroundColor(.primary)
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(6)
                }
                .menuStyle(.borderlessButton)
                .fixedSize()
                .onChange(of: selection) { _ in onLangChange() }
                
                Spacer()
                
                if !isSource {
                    HStack(spacing: 12) {
                        if isLoading {
                            ProgressView()
                                .scaleEffect(0.5)
                                .frame(width: 16, height: 16)
                        }
                        
                        
                        Button(action: {
                            if speechService.isSpeaking {
                                speechService.stop()
                            } else {
                                speechService.speak(text, language: selection)
                            }
                        }) {
                            Image(systemName: speechService.isSpeaking ? "stop.fill" : "speaker.wave.2")
                                .font(.system(size: 14))
                                .foregroundColor(speechService.isSpeaking ? .red : .secondary)
                        }
                        .buttonStyle(.plain)
                        .help(speechService.isSpeaking ? "main.stop_speaking".localized : "main.read_aloud".localized)
                        
                        Button(action: {
                            NSPasteboard.general.clearContents()
                            NSPasteboard.general.setString(text, forType: .string)
                        }) {
                            Image(systemName: "doc.on.doc")
                                .font(.system(size: 14))
                                .foregroundColor(.secondary)
                        }
                        .buttonStyle(.plain)
                        .help("main.copy".localized)
                    }
                } else if text.isEmpty {
                    Button(action: {
                        // Clear action if needed
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 14))
                            .foregroundColor(.secondary.opacity(0.5))
                    }
                    .buttonStyle(.plain)
                    .opacity(0) // Hidden for now, placeholder for layout
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(Color(NSColor.controlBackgroundColor).opacity(0.5))
            
            Divider()
                .opacity(0.3)
            
            // Text Area
            ZStack(alignment: .topLeading) {
                if isSource {
                    if text.isEmpty {
                        Text("main.placeholder.source".localized)
                            .font(.system(.body, design: .rounded))
                            .foregroundColor(.secondary.opacity(0.5))
                            .padding(.horizontal, 20)
                            .padding(.vertical, 16)
                            .allowsHitTesting(false)
                    }
                    
                    TextEditor(text: $text)
                        .font(.system(.body, design: .rounded))
                        .lineSpacing(4)
                        .scrollContentBackground(.hidden)
                        .scrollIndicators(.never)
                        .background(Color.clear)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 16)
                        .frame(maxHeight: .infinity)
                        .onChange(of: text) { _ in
                            onTextChange?()
                        }
                } else {
                    ScrollView {
                        Text(text.isEmpty ? "main.placeholder.target".localized : text)
                            .font(.system(.body, design: .rounded))
                            .lineSpacing(4)
                            .foregroundColor(text.isEmpty ? .secondary.opacity(0.5) : .primary)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 16)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .textSelection(.enabled)
                    }
                    .scrollIndicators(.never)
                }
            }
            .background(isSource ? Color(NSColor.textBackgroundColor) : Color(NSColor.controlBackgroundColor).opacity(0.3))
        }
        .frame(maxHeight: .infinity)
    }
    
    func languageName(for code: String) -> String {
        if code == "auto" { return "main.detect_language".localized }
        return "lang.\(code)".localized
    }
}

// MARK: - Visual Effect
struct VisualEffectView: NSViewRepresentable {
    let material: NSVisualEffectView.Material
    let blendingMode: NSVisualEffectView.BlendingMode
    
    func makeNSView(context: Context) -> NSVisualEffectView {
        let visualEffectView = NSVisualEffectView()
        visualEffectView.material = material
        visualEffectView.blendingMode = blendingMode
        visualEffectView.state = .active
        return visualEffectView
    }
    
    func updateNSView(_ nsView: NSVisualEffectView, context: Context) {
        nsView.material = material
        nsView.blendingMode = blendingMode
    }
}

struct LogoView: View {
    @Environment(\.colorScheme) var colorScheme
    var size: CGFloat = 32
    
    var body: some View {
        Group {
            if let image = nsImage(for: colorScheme) {
                Image(nsImage: image)
                    .resizable()
                    .interpolation(.high)
                    .antialiased(true)
                    .aspectRatio(contentMode: .fit)
                    .frame(width: size, height: size)
            } else {
                // Fallback
                Image(systemName: "character.bubble.fill")
                    .font(.system(size: size * 0.6))
                    .foregroundColor(.white)
                    .padding(size * 0.2)
                    .background(Circle().fill(LinearGradient(colors: [.blue, .purple], startPoint: .topLeading, endPoint: .bottomTrailing)))
                    .frame(width: size, height: size)
            }
        }
    }
    
    func nsImage(for scheme: ColorScheme) -> NSImage? {
        let name = scheme == .dark ? "dark" : "light"
        if let path = Bundle.main.path(forResource: name, ofType: "png"),
           let image = NSImage(contentsOfFile: path) {
            return image
        }
        return nil
    }
}

