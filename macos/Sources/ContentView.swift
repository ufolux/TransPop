import SwiftUI
import Cocoa

struct ContentView: View {
    @ObservedObject var appState = AppState.shared
    
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
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Image(systemName: "character.bubble.fill")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.white)
                    .padding(6)
                    .background(Circle().fill(Color.accentColor))
                
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
                    Image(systemName: "globe")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.secondary)
                        .frame(width: 24, height: 24)
                        .contentShape(Rectangle())
                }
                .menuStyle(.borderlessButton)
                .fixedSize()
                .onChange(of: appState.targetLang) {
                    appState.performTranslation()
                }
                
                Spacer()
                
                HStack(spacing: 12) {
                    Button(action: {
                        NotificationCenter.default.post(name: NSNotification.Name("ExpandWindow"), object: nil)
                    }) {
                        Image(systemName: "arrow.up.left.and.arrow.down.right")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(.secondary)
                    }
                    .buttonStyle(.plain)
                    .help("Expand")
                }
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
    }
    
    func languageName(for code: String) -> String {
        switch code {
        case "en": return "English"
        case "zh-CN": return "Chinese (S)"
        case "zh-TW": return "Chinese (T)"
        case "ja": return "Japanese"
        case "ko": return "Korean"
        case "fr": return "French"
        case "de": return "German"
        case "es": return "Spanish"
        default: return code
        }
    }
}

// MARK: - Full View
struct FullView: View {
    @ObservedObject var appState = AppState.shared
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                HStack(spacing: 8) {
                    Image(systemName: "character.bubble.fill")
                        .font(.title3)
                        .foregroundColor(.white)
                        .padding(6)
                        .background(Circle().fill(LinearGradient(colors: [.blue, .purple], startPoint: .topLeading, endPoint: .bottomTrailing)))
                    
                    Text("TransPop")
                        .font(.system(.title3, design: .rounded).weight(.bold))
                }
                
                Spacer()
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
    
    var body: some View {
        VStack(spacing: 0) {
            // Card Header
            HStack {
                Menu {
                    Picker("", selection: $selection) {
                        if isSource {
                            Text("Detect Language").tag("auto")
                        }
                        Text("English").tag("en")
                        Text("Chinese (Simplified)").tag("zh-CN")
                        Text("Chinese (Traditional)").tag("zh-TW")
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
                .onChange(of: selection) { onLangChange() }
                
                Spacer()
                
                if !isSource {
                    HStack(spacing: 12) {
                        if isLoading {
                            ProgressView()
                                .scaleEffect(0.5)
                        }
                        
                        Button(action: {
                            NSPasteboard.general.clearContents()
                            NSPasteboard.general.setString(text, forType: .string)
                        }) {
                            Image(systemName: "doc.on.doc")
                                .font(.system(size: 14))
                                .foregroundColor(.secondary)
                        }
                        .buttonStyle(.plain)
                        .help("Copy")
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
                        Text("Enter text to translate...")
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
                        .background(Color.clear)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 16)
                        .frame(maxHeight: .infinity)
                        .onChange(of: text) {
                            onTextChange?()
                        }
                } else {
                    ScrollView {
                        Text(text.isEmpty ? "Translation will appear here..." : text)
                            .font(.system(.body, design: .rounded))
                            .lineSpacing(4)
                            .foregroundColor(text.isEmpty ? .secondary.opacity(0.5) : .primary)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 16)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .textSelection(.enabled)
                    }
                }
            }
            .background(isSource ? Color(NSColor.textBackgroundColor) : Color(NSColor.controlBackgroundColor).opacity(0.3))
        }
        .frame(maxHeight: .infinity)
    }
    
    func languageName(for code: String) -> String {
        switch code {
        case "auto": return "Detect Language"
        case "en": return "English"
        case "zh-CN": return "Chinese (S)"
        case "zh-TW": return "Chinese (T)"
        case "ja": return "Japanese"
        case "ko": return "Korean"
        case "fr": return "French"
        case "de": return "German"
        case "es": return "Spanish"
        default: return code
        }
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

