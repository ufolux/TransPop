# TransPop 🚀
> **La Traduction Redevient Simple** ✨

<img width="562" height="712" alt="image" src="https://github.com/user-attachments/assets/c6787432-79fd-4f2f-8908-926065c8289c" />

Fatigué du cycle `Cmd+C` -> Ouvrir le navigateur -> Taper "Google Traduction" -> `Cmd+V` -> Pleurer -> Répéter ?

Ouais, nous aussi. C'est pourquoi nous avons créé **TransPop**. C'est comme avoir un Babel fish dans votre barre de menu, mais en moins gluant.

## Pourquoi TransPop ? 🧐

Parce que la vie est trop courte pour copier-coller manuellement du texte dans un onglet de navigateur.

### 🌟 Des fonctionnalités qui vous feront dire "Wow"

*   **La Magie du "Double Tap"** : Appuyez deux fois sur `Cmd+C` (Double Copie). Boum ! La traduction apparaît. C'est comme invoquer un génie, mais pour les langues. 🧞‍♂️
*   **Mode Mini Popup** : La fenêtre apparaît *juste là où se trouve votre curseur*. Nous l'appelons le "Mode Ninja". Vous n'avez même pas besoin de bouger votre souris. 🥷
*   **UI Extensible** : Besoin de plus d'espace ? Cliquez sur le bouton d'extension (icône flèches) dans l'interface Mini pour passer en fenêtre pleine taille.
*   **Icône de la barre d'état** : Nous vivons dans votre barre d'état. Toujours à regarder. Toujours à attendre. (D'une manière non effrayante). 👀
*   **Fournisseurs Multiples** : 
    *   **Google Traduction (Gratuit)** : Fonctionne immédiatement. Aucune configuration requise.
    *   **OpenAI / Ollama** : Connectez-vous à votre LLM local (via Ollama) ou à une API compatible OpenAI pour des traductions plus intelligentes.
*   **Échange de Langue** : Un clic pour inverser le flux. `Anglais -> Chinois` devient `Chinois -> Anglais`. Époustouflant. 🤯
*   **Fermeture Intelligente** : Choisissez de réduire dans la barre d'état ou de quitter l'application lorsque vous fermez la fenêtre. Vous pouvez même lui dire de "Ne plus demander".
*   **Mode Sombre** : Parce que nous sommes des développeurs et que le mode clair nous brûle les rétines. 😎

## 🛠 Tech Stack (Le truc de geek)

Construit avec du **Swift** et **SwiftUI** purs et non frelatés. Pas d'Electron. Pas d'instances Chrome qui mangent votre RAM. Juste de la performance native pure. 🍏

*   **SwiftUI** : UI déclarative qui a fière allure sur macOS.
*   **AppKit** : Pour la gestion des fenêtres et la magie de la barre d'état.
*   **Combine** : Pour la gestion réactive de l'état.

## 📥 Comment Installer

Vous ne voulez pas compiler depuis la source ? On s'occupe de vous.

1.  Allez sur la page [Releases](https://github.com/ufolux/TransPop/releases).
2.  Téléchargez le dernier fichier `.zip`.
3.  Décompressez-le et faites glisser `TransPop.app` dans votre dossier `/Applications`.

### ⚠️ "L'application ne peut pas être ouverte car le développeur ne peut pas être vérifié" ?

Si macOS se plaint que l'application est endommagée ou ne peut pas être ouverte (parce que nous n'avons pas encore payé 99 $/an à Apple), exécutez cette commande dans le Terminal :

```bash
xattr -dr com.apple.quarantine /Applications/TransPop.app
```

Puis essayez de l'ouvrir à nouveau.

## 🏃‍♂️ Comment Exécuter (Pour les Développeurs)

Vous voulez faire tourner ce mauvais garçon localement ? Voici :

```bash
# 1. Cloner le repo (duh)
git clone https://github.com/ufolux/TransPop.git

# 2. Aller dans le dossier macos
cd macos

# 3. Lancer ! 🚀
swift run
```

## 📦 Compiler

Vous voulez compiler une version release ?

```bash
cd macos
swift build -c release
```

## ⚙️ Configuration

Accédez aux **Paramètres** via l'icône d'engrenage dans la Vue Complète.

### Général
*   **Langue** : Changer la langue de l'interface de l'application.
*   **Thème** : Basculer entre le thème Clair, Sombre ou Système.
*   **Action de Fermeture** : Choisir ce qui se passe lorsque vous fermez la fenêtre (Demander, Réduire, ou Quitter).

### API de Traduction
*   **Fournisseur** : Basculer entre "Google (Gratuit)" et "Compatible OpenAI".
*   **Paramètres Compatible OpenAI** :
    *   **URL de l'API** : La valeur par défaut est `http://127.0.0.1:11434/v1/chat/completions` (parfait pour Ollama).
    *   **Clé API** : Optionnel pour les LLM locaux.
    *   **Modèle** : Spécifier le nom du modèle (par ex., `llama3`, `gpt-4o`, `zongwei/gemma3-translator:1b` J'ai essayé celui-ci, il fonctionne parfaitement pour moi).

## 🤝 Contribuer

Trouvé un bug ? Vous voulez ajouter le support du Klingon ? Les PR sont les bienvenues ! Ne cassez juste pas la fonctionnalité "Double Tap", ou c'est l'émeute.

---
*Fait avec ❤️ et trop de caféine par ufolux*
