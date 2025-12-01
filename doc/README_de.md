# TransPop 🚀
> **Übersetzung wieder einfach gemacht** ✨

<img width="562" height="712" alt="image" src="https://github.com/user-attachments/assets/c6787432-79fd-4f2f-8908-926065c8289c" />

Müde vom `Cmd+C` -> Browser öffnen -> "Google Translate" eingeben -> `Cmd+V` -> Weinen -> Wiederholen Zyklus?

Ja, wir auch. Deshalb haben wir **TransPop** gebaut. Es ist wie ein Babelfisch in deiner Menüleiste, aber weniger schleimig.

## Warum TransPop? 🧐

Weil das Leben zu kurz ist, um Text manuell in einen Browser-Tab zu kopieren und einzufügen.

### 🌟 Funktionen, die dich "Wow" sagen lassen

*   **Die "Double Tap" Magie**: Drücke zweimal `Cmd+C` (Doppelklick). Bumm! Übersetzung erscheint. Es ist wie das Beschwören eines Dschinns, aber für Sprachen. 🧞‍♂️
*   **Mini-Popup-Modus**: Das Fenster erscheint *genau dort, wo dein Cursor ist*. Wir nennen es den "Ninja-Modus". Du musst nicht einmal deine Maus bewegen. 🥷
*   **Erweiterbare UI**: Brauchst du mehr Platz? Klicke auf den Erweiterungs-Button (Pfeil-Symbol) in der Mini-UI, um zum Vollbildfenster zu wechseln.
*   **Tray-Icon**: Wir leben in deiner Statusleiste. Immer beobachtend. Immer wartend. (Auf eine nicht gruselige Weise). 👀
*   **Mehrere Anbieter**: 
    *   **Google Translate (Kostenlos)**: Funktioniert sofort. Keine Einrichtung erforderlich.
    *   **OpenAI / Ollama**: Verbinde dich mit deinem lokalen LLM (über Ollama) oder einer OpenAI-kompatiblen API für intelligentere Übersetzungen.
*   **Sprachwechsel**: Ein Klick, um den Fluss umzukehren. `Englisch -> Chinesisch` wird zu `Chinesisch -> Englisch`. Wahnsinn. 🤯
*   **Intelligentes Schließen**: Wähle, ob beim Schließen des Fensters in den Tray minimiert oder die App beendet werden soll. Du kannst sogar sagen "Nicht mehr fragen".
*   **Dunkelmodus**: Weil wir Entwickler sind und der helle Modus unsere Netzhäute verbrennt. 😎

## 🛠 Tech Stack (Der Nerd-Kram)

Gebaut mit reinem, unverfälschtem **Swift** und **SwiftUI**. Kein Electron. Keine Chrome-Instanzen, die deinen RAM fressen. Nur reine, native Leistung. 🍏

*   **SwiftUI**: Deklarative UI, die auf macOS gut aussieht.
*   **AppKit**: Für das knifflige Fenstermanagement und die Statusleisten-Magie.
*   **Combine**: Für reaktives Zustandsmanagement.

## 📥 Installation

Willst du nicht aus dem Quellcode bauen? Wir haben dich abgedeckt.

1.  Gehe zur [Releases](https://github.com/ufolux/TransPop/releases) Seite.
2.  Lade die neueste `.zip` Datei herunter.
3.  Entpacke sie und ziehe `TransPop.app` in deinen `/Applications` Ordner.

### ⚠️ "App kann nicht geöffnet werden, da der Entwickler nicht verifiziert werden kann"?

Wenn macOS sich beschwert, dass die App beschädigt ist oder nicht geöffnet werden kann (weil wir Apple noch nicht 99 $/Jahr bezahlt haben), führe diesen Befehl im Terminal aus:

```bash
xattr -dr com.apple.quarantine /Applications/TransPop.app
```

Versuche dann, es erneut zu öffnen.

## 🏃‍♂️ Ausführen (Für Entwickler)

Willst du diesen bösen Buben lokal laufen lassen? Hier bitte:

```bash
# 1. Repo klonen (duh)
git clone https://github.com/ufolux/TransPop.git

# 2. In den macos Ordner gehen
cd macos

# 3. Ausführen! 🚀
swift run
```

## 📦 Bauen

Willst du eine Release-Version bauen?

```bash
cd macos
swift build -c release
```

## ⚙️ Konfiguration

Greife über das Zahnrad-Symbol in der Vollansicht auf die **Einstellungen** zu.

### Allgemein
*   **Sprache**: Ändere die App-Schnittstellensprache.
*   **Thema**: Wechsle zwischen Hell, Dunkel oder Systemthema.
*   **Schließen-Aktion**: Wähle, was passiert, wenn du das Fenster schließt (Fragen, Minimieren oder Beenden).

### Übersetzungs-API
*   **Anbieter**: Wechsle zwischen "Google (Kostenlos)" und "OpenAI Kompatibel".
*   **OpenAI Kompatible Einstellungen**:
    *   **API URL**: Standard ist `http://127.0.0.1:11434/v1/chat/completions` (perfekt für Ollama).
    *   **API Key**: Optional für lokale LLMs.
    *   **Modell**: Gib den Modellnamen an (z.B. `llama3`, `gpt-4o`).

## 🤝 Mitwirken

Einen Fehler gefunden? Willst du Klingonisch-Unterstützung hinzufügen? PRs sind willkommen! Mach nur nicht die "Double Tap" Funktion kaputt, sonst gibt es einen Aufstand.

---
*Gemacht mit ❤️ und zu viel Koffein von [Your Name/Team]*
