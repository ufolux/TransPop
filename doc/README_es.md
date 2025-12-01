# TransPop 🚀
> **Haz la Traducción Simple de Nuevo** ✨

<img width="562" height="712" alt="image" src="https://github.com/user-attachments/assets/c6787432-79fd-4f2f-8908-926065c8289c" />

¿Cansado del ciclo `Cmd+C` -> Abrir Navegador -> Escribir "Google Translate" -> `Cmd+V` -> Llorar -> Repetir?

Sí, nosotros también. Por eso construimos **TransPop**. Es como tener un pez Babel en tu barra de menú, pero menos viscoso.

## ¿Por qué TransPop? 🧐

Porque la vida es demasiado corta para copiar y pegar texto manualmente en una pestaña del navegador.

### 🌟 Características que te harán decir "Wow"

*   **La Magia del "Doble Toque"**: Presiona `Cmd+C` dos veces (Doble Copia). ¡Boom! Aparece la traducción. Es como invocar a un genio, pero de idiomas. 🧞‍♂️
*   **Modo Mini Popup**: La ventana aparece *justo donde está tu cursor*. Lo llamamos "Modo Ninja". Ni siquiera tienes que mover el ratón. 🥷
*   **UI Expandible**: ¿Necesitas más espacio? Haz clic en el botón de expansión (icono de flechas) en la Mini UI para cambiar a ventana completa.
*   **Icono de Bandeja**: Vivimos en tu barra de estado. Siempre observando. Siempre esperando. (De una manera no espeluznante). 👀
*   **Múltiples Proveedores**: 
    *   **Google Translate (Gratis)**: Funciona de inmediato. No requiere configuración.
    *   **OpenAI / Ollama**: Conéctate a tu LLM local (vía Ollama) o API compatible con OpenAI para traducciones más inteligentes.
*   **Intercambio de Idioma**: Un clic para invertir el flujo. `Inglés -> Chino` se convierte en `Chino -> Inglés`. Alucinante. 🤯
*   **Cierre Inteligente**: Elige si minimizar a la bandeja o salir de la aplicación al cerrar la ventana. Incluso puedes decirle "No volver a preguntar".
*   **Modo Oscuro**: Porque somos desarrolladores y el modo claro nos quema las retinas. 😎

## 🛠 Tech Stack (La cosa nerd)

Construido con **Swift** y **SwiftUI** puros y sin adulterar. Sin Electron. Sin instancias de Chrome comiendo tu RAM. Solo rendimiento nativo puro. 🍏

*   **SwiftUI**: UI declarativa que se ve bien en macOS.
*   **AppKit**: Para la gestión de ventanas y la magia de la barra de estado.
*   **Combine**: Para la gestión reactiva del estado.

## 📥 Cómo Instalar

¿No quieres compilar desde el código fuente? Te cubrimos.

1.  Ve a la página de [Releases](https://github.com/ufolux/TransPop/releases).
2.  Descarga el último archivo `.zip`.
3.  Descomprímelo y arrastra `TransPop.app` a tu carpeta `/Applications`.

### ⚠️ "¿La aplicación no se puede abrir porque no se puede verificar al desarrollador"?

Si macOS se queja de que la aplicación está dañada o no se puede abrir (porque aún no hemos pagado a Apple $99/año), ejecuta este comando en la Terminal:

```bash
xattr -dr com.apple.quarantine /Applications/TransPop.app
```

Luego intenta abrirla de nuevo.

## 🏃‍♂️ Cómo Ejecutar (Para Desarrolladores)

¿Quieres ejecutar este chico malo localmente? Aquí tienes:

```bash
# 1. Clonar el repo (duh)
git clone https://github.com/ufolux/TransPop.git

# 2. Ir a la carpeta macos
cd macos

# 3. ¡Ejecutar! 🚀
swift run
```

## 📦 Compilar

¿Quieres compilar una versión de lanzamiento?

```bash
cd macos
swift build -c release
```

## ⚙️ Configuración

Accede a la **Configuración** a través del icono de engranaje en la Vista Completa.

### General
*   **Idioma**: Cambia el idioma de la interfaz de la aplicación.
*   **Tema**: Alterna entre tema Claro, Oscuro o Sistema.
*   **Acción de Cierre**: Elige qué sucede cuando cierras la ventana (Preguntar, Minimizar o Salir).

### API de Traducción
*   **Proveedor**: Alterna entre "Google (Gratis)" y "Compatible con OpenAI".
*   **Configuración Compatible con OpenAI**:
    *   **URL de API**: El valor predeterminado es `http://127.0.0.1:11434/v1/chat/completions` (perfecto para Ollama).
    *   **Clave API**: Opcional para LLMs locales.
    *   **Modelo**: Especifica el nombre del modelo (por ejemplo, `llama3`, `gpt-4o`, `zongwei/gemma3-translator:1b` Probé este y funciona perfectamente para mí).

## 🤝 Contribuir

¿Encontraste un error? ¿Quieres agregar soporte para Klingon? ¡Los PR son bienvenidos! Solo no rompas la función "Doble Toque", o nos amotinamos.

---
*Hecho con ❤️ y demasiada cafeína por ufolux*
