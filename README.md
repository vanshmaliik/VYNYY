# 🎵 VYNL — Feel The Vibe

[![Flutter](https://img.shields.io/badge/Flutter-v3.27+-02569B?logo=flutter&logoColor=white)](https://flutter.dev)
[![Platform](https://img.shields.io/badge/Platform-Android%20%7C%20iOS%20%7C%20Windows%20%7C%20macOS%20%7C%20Linux-brightgreen)](#-getting-started)
[![Music Engines](https://img.shields.io/badge/Engines-JioSaavn%20%2B%20YouTube-red)](#-music-sources--streaming-engines)
[![License](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![Author](https://img.shields.io/badge/Author-Vansh%20Malik-38BDF8)](https://github.com/vanshmaliik)

**VYNL** is an ultra-modern, cross-platform music streaming player designed for pure immersion and aesthetic elegance. Powered by a dual streaming engine (JioSaavn + YouTube), a sculpted **Fluid Curve Dock** taskbar, an airy **Light Bluish** design palette, and the signature origami **V** logo, VYNL lets you stream any song seamlessly.

> *"feel the vibe"*

---

## ✨ Key Features & Highlights

### 🎨 Signature VYNL Aesthetic & Branding
- **Origami Geometric "V" Logo**: A sleek, multifaceted geometric logo featured on the app icon, launcher mipmaps, and custom vector painter.
- **Light Bluish Color Theme**: Crisp ice-blue (`#EEF5FB`), soft slate-blue surfaces (`#E0EDF8`), and electric sky-blue accents (`#38BDF8`) for maximum visual clarity.
- **Smooth Splash Intro**: When the app opens, the logo descends smoothly from upward with an ambient light-blue halo, settling above the tagline **"feel the vibe"**.
- **Minimal Clean Header**: Clutter-free top bar without repetitive greetings, featuring bold `VYNL` branding alongside audio routing and nearby share capsules.

### 🟢 VYNL Fluid Curve Dock (Taskbar)
- **Scooped Notch**: A smooth concave curve carved into the dock background.
- **Floating Circular Pill**: An elevated, animated active button in vibrant accent colors that glides smoothly between tabs with haptic feedback.
- **Customizable Styles**: Toggle between **VYNL Fluid Curve Dock 🟢**, **Floating Glass Capsule ✨**, and **OS Native Style 📱** (iOS 26 Liquid Glass / Android 16 Material 3) directly in Settings.

### 🎧 Dual-Engine Music Sources (JioSaavn + YouTube)
- **Hybrid Streaming**: Searches JioSaavn and YouTube simultaneously, interleaving and deduplicating tracks. If a song is missing on JioSaavn, YouTube supplies it automatically.
- **Innertube & Mirror Resolvers**: High-speed audio stream resolution via YouTube Innertube with Piped and Invidious fallbacks.
- **Flexible Modes**: Switch between **Hybrid (Recommended)**, **YouTube Only**, or **JioSaavn Only** directly inside Settings.

### 🔗 Playlist Sharing & Importing
- **Deep Link Generation**: Generate shareable `vynl://` or `vynl-playlist://` deep links and web URLs.
- **One-Click Playlist Import**: Share playlists directly to WhatsApp, Telegram, or Messages. Tapping a shared link automatically imports the full playlist into the recipient's VYNL Library.
- **🟢 Spotify Playlist Importer**: Paste any public Spotify playlist URL into VYNL to convert and import all songs into your library.

### 🎙️ Native Siri & Google Assistant Voice Commands
- **iOS Siri Integration**: Speak naturally to Siri (*"Play Punjabi song in VYNL"*, *"Play Diljit Dosanjh in VYNL"*) to start playback immediately.
- **Android Media Actions**: Google Assistant media intent handling for hands-free voice search and playback.

### 🤖 AI Lyrics Interpretation & Summaries
- **🔤 Multi-Language Support**: Generate AI summaries and line-by-line lyric breakdowns in **English**, **Hindi (हिंदी)**, or **Hinglish**.
- **💡 Line-by-Line Lyric Explanations**: Understand hidden metaphors, mood, and storytelling behind individual lyric lines.
- **📜 Full Narrative Summaries**: Comprehensive narrative analysis covering theme, emotional progression, message, and cultural context.

### 📊 Waveform Seeking & Visual Progress Bars
- **On-Device Waveform Extractor**: Interactive voice-note style waveform visuals rendered from audio sample amplitudes.
- **6 Progress Bar Styles**: Waveform, Android 16 Wave, Material Rounded, Snake, Zigzag, and Neon Glow.

### 🔊 Multi-Device Synced Playback & Audio Routing
- **Wi-Fi Multi-Room Sync**: Discover and synchronize music playback across multiple nearby devices on the same Wi-Fi network.
- **Audio Output Routing**: Dynamically switch audio output between Built-in Speaker, Bluetooth Headphones, and AirPlay/Cast routes.

### 💾 Smart Offline Mode & Local Cover Art Caching
- **Offline Listening**: Download songs locally for playback without an active internet connection.
- **Cover Art Persistence**: Artwork is saved locally so song covers display offline.

---

## 📲 Downloads & Releases

Pre-built binaries for all major platforms are available on the [Releases](https://github.com/vanshmaliik/VYNYY/releases) page:

| Platform | Format | Status |
|---|---|---|
| **Android** | `.apk` | [Download Release](https://github.com/vanshmaliik/VYNYY/releases) |
| **iOS** | `.ipa` | [Download Release](https://github.com/vanshmaliik/VYNYY/releases) |
| **Windows** | `.zip` (`.exe`) | [Download Release](https://github.com/vanshmaliik/VYNYY/releases) |
| **macOS** | `.zip` (`.app`) | [Download Release](https://github.com/vanshmaliik/VYNYY/releases) |
| **Linux** | `.tar.gz` | [Download Release](https://github.com/vanshmaliik/VYNYY/releases) |

---

## 🛠️ Build & Run from Source

### Prerequisites
- [Flutter SDK](https://docs.flutter.dev/get-started/install) (v3.27 or newer)
- [Dart SDK](https://dart.dev/get-dart)

### 1. Clone & Install
```bash
git clone https://github.com/vanshmaliik/VYNYY.git
cd VYNYY
flutter pub get
```

### 2. Configure Environment API Keys
Create a `.env` file in the project root:
```env
GROQ_KEY="your_groq_api_key"
GROQ_KEY_2="your_second_groq_api_key"
GEMINI_KEY="your_gemini_api_key"
```

### 3. Run Locally
```bash
flutter run
```

### 4. Build Release Bundles
- **Android APK**:
  ```bash
  flutter build apk --release --no-tree-shake-icons
  ```
- **Windows Executable**:
  ```bash
  flutter build windows --release
  ```
- **macOS App**:
  ```bash
  flutter build macos --release --no-codesign
  ```
- **Linux Bundle**:
  ```bash
  flutter build linux --release
  ```

---

## ⚙️ Automated CI/CD Cloud Builds

GitHub Actions workflows are configured under `.github/workflows/`:
- **`apk-build.yml`**: Builds signed Android `.apk` and publishes it to Releases and Workflow Artifacts on every push.
- **`dart.yml`**: Builds and releases iOS `.ipa`.
- **`desktop-builds.yml`**: Builds and releases Windows `.exe` (Zip), macOS `.app` (Zip), and Linux bundle (`.tar.gz`).

---

## 👨‍💻 Author

- **Vansh Malik** — [@vanshmaliik](https://github.com/vanshmaliik)

---

## 📄 License

Distributed under the MIT License. See `LICENSE` for more details.
