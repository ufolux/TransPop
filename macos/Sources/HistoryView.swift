import SwiftUI

struct HistoryView: View {
    @ObservedObject var historyManager = HistoryManager.shared
    @ObservedObject var localization = LocalizationManager.shared
    @Binding var isPresented: Bool
    @State private var selectedItem: HistoryItem?
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("history.title".localized)
                    .font(.system(.headline, design: .rounded))
                    .fontWeight(.bold)
                
                Spacer()
                
                Button(action: {
                    historyManager.clearAll()
                }) {
                    Image(systemName: "trash")
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                }
                .buttonStyle(.plain)
                .help("history.clear_all".localized)
                .disabled(historyManager.items.isEmpty)
                
                Button(action: {
                    withAnimation {
                        isPresented = false
                    }
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 16))
                        .foregroundColor(.secondary.opacity(0.8))
                }
                .buttonStyle(.plain)
                .padding(.leading, 8)
            }
            .padding()
            .background(Color(NSColor.controlBackgroundColor))
            
            Divider()
            
            // List
            if historyManager.items.isEmpty {
                VStack {
                    Spacer()
                    Image(systemName: "clock.arrow.circlepath")
                        .font(.system(size: 40))
                        .foregroundColor(.secondary.opacity(0.3))
                        .padding(.bottom, 8)
                    Text("history.empty".localized)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Spacer()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color(NSColor.windowBackgroundColor))
            } else {
                ScrollViewReader { proxy in
                    List {
                        ForEach(historyManager.items) { item in
                            HistoryItemView(item: item, onDelete: {
                                historyManager.delete(id: item.id)
                            })
                            .contentShape(Rectangle())
                            .onTapGesture {
                                selectedItem = item
                            }
                            .id(item.id)
                        }
                    }
                    .listStyle(PlainListStyle())
                    .onChange(of: historyManager.items.first?.id) { newId in
                        if let newId = newId {
                            withAnimation {
                                proxy.scrollTo(newId, anchor: .top)
                            }
                        }
                    }
                }
            }
        }
        .frame(width: 250)
        .background(Color(NSColor.windowBackgroundColor))
        .overlay(
            HStack {
                Divider()
                Spacer()
            }
        )
        .popover(item: $selectedItem, arrowEdge: .trailing) { item in
            HistoryDetailView(item: item)
        }
    }
}

struct HistoryItemView: View {
    let item: HistoryItem
    let onDelete: () -> Void
    @State private var isHovering = false
    @ObservedObject var localization = LocalizationManager.shared
    
    var body: some View {
        HStack(spacing: 8) {
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(languageName(for: item.sourceLang) + " → " + languageName(for: item.targetLang))
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    Spacer()
                    Text(item.timestamp, style: .time)
                        .font(.caption2)
                        .foregroundColor(.secondary.opacity(0.7))
                }
                
                Text(item.sourceText)
                    .font(.callout)
                    .lineLimit(2)
                    .foregroundColor(.primary)
                
                Text(item.targetText)
                    .font(.callout)
                    .lineLimit(2)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            if isHovering {
                Button(action: onDelete) {
                    Image(systemName: "trash")
                        .font(.system(size: 12))
                        .foregroundColor(.red.opacity(0.8))
                        .padding(4)
                        .background(Color.red.opacity(0.1))
                        .clipShape(Circle())
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.vertical, 4)
        .contentShape(Rectangle())
        .onHover { hovering in
            isHovering = hovering
        }
    }
    
    func languageName(for code: String) -> String {
        return "lang.\(code)".localized
    }
}

struct HistoryDetailView: View {
    let item: HistoryItem
    @ObservedObject var localization = LocalizationManager.shared
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Source
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(languageName(for: item.sourceLang))
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Spacer()
                    Button(action: {
                        NSPasteboard.general.clearContents()
                        NSPasteboard.general.setString(item.sourceText, forType: .string)
                    }) {
                        Image(systemName: "doc.on.doc")
                            .font(.caption)
                    }
                    .buttonStyle(.plain)
                }
                
                ScrollView {
                    Text(item.sourceText)
                        .font(.body)
                        .textSelection(.enabled)
                }
                .frame(maxHeight: 150)
            }
            
            Divider()
            
            // Target
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(languageName(for: item.targetLang))
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Spacer()
                    Button(action: {
                        NSPasteboard.general.clearContents()
                        NSPasteboard.general.setString(item.targetText, forType: .string)
                    }) {
                        Image(systemName: "doc.on.doc")
                            .font(.caption)
                    }
                    .buttonStyle(.plain)
                }
                
                ScrollView {
                    Text(item.targetText)
                        .font(.body)
                        .textSelection(.enabled)
                }
                .frame(maxHeight: 150)
            }
        }
        .padding()
        .frame(width: 300)
    }
    
    func languageName(for code: String) -> String {
        return "lang.\(code)".localized
    }
}
