# 📄 PDF Master Pro — Flutter Android App

A beautiful, fully-featured PDF toolkit Android app built with **Flutter + Dart**.

---

## ✅ Why this is Flutter (not Python/Kivy)

This project uses **Flutter** — to run it use `flutter run`, NOT `python main.py`.

---

## 🚀 Quick Start

### 1. Prerequisites
```
- Flutter SDK 3.x  →  https://flutter.dev/docs/get-started/install
- Android Studio   →  https://developer.android.com/studio
- Android SDK API 21+
- A connected device or emulator
```

### 2. Install Flutter (Windows)
```powershell
# Download from https://flutter.dev
# Add flutter/bin to your PATH, then:
flutter doctor        # check everything is OK
flutter doctor --android-licenses   # accept licenses
```

### 3. Run the app
```bash
cd pdf_master_pro          # the project folder (with pubspec.yaml)
flutter pub get            # install dependencies
flutter run                # run on connected device/emulator
```

### 4. Build APK
```bash
flutter build apk --release
# Output: build/app/outputs/flutter-apk/app-release.apk
```

### 5. Build App Bundle (for Play Store)
```bash
flutter build appbundle --release
# Output: build/app/outputs/bundle/release/app-release.aab
```

---

## 📁 Project Structure

```
pdf_master_pro/
├── pubspec.yaml                    ← Flutter project config ⭐
├── lib/
│   ├── main.dart                   ← App entry point
│   ├── core/
│   │   ├── app_state.dart          ← State + all translations (8 languages)
│   │   └── theme.dart              ← Dark/Light themes
│   ├── screens/
│   │   ├── splash_screen.dart      ← Animated splash
│   │   ├── main_shell.dart         ← Bottom navigation shell
│   │   ├── home_screen.dart        ← Home tab
│   │   ├── tools_screen.dart       ← All tools list + search
│   │   ├── history_screen.dart     ← Recent files
│   │   ├── settings_screen.dart    ← Language, theme, preferences
│   │   └── tool_screen.dart        ← Individual tool UI
│   └── widgets/
│       └── common.dart             ← Reusable widgets
├── android/
│   └── app/
│       ├── build.gradle
│       └── src/main/AndroidManifest.xml
└── README.md
```

---

## 🌐 Languages (8 supported)

| Code | Language |
|------|----------|
| en   | 🇬🇧 English (default) |
| ar   | 🇸🇦 العربية |
| fr   | 🇫🇷 Français |
| es   | 🇪🇸 Español |
| de   | 🇩🇪 Deutsch |
| zh   | 🇨🇳 中文 |
| tr   | 🇹🇷 Türkçe |
| pt   | 🇧🇷 Português |

Change in Settings → Language.

---

## 🛠️ 13 PDF Tools

| Tool | Icon | Description |
|------|------|-------------|
| Merge PDF | 🔗 | Combine multiple PDFs |
| Split PDF | ✂️ | Divide into files |
| Compress PDF | 🗜️ | Reduce file size |
| Watermark | 💧 | Add text watermark |
| Protect PDF | 🔐 | Password encryption |
| Unlock PDF | 🔓 | Remove password |
| Rotate Pages | 🔄 | 90°/180°/270° |
| Extract Text | 📋 | Pull all text |
| File Info | ℹ️ | View metadata |
| Convert PDF | 🔁 | PDF→Word/PNG/Excel |
| Sign PDF | ✍️ | Digital signature |
| OCR Scan | 🔍 | Make searchable |
| Organize Pages | 📑 | Reorder & delete |

---

## 🎨 Design Features

- ✅ Dark & Light theme
- ✅ Smooth animations & transitions
- ✅ Bottom navigation bar
- ✅ Gradient buttons
- ✅ Progress indicators
- ✅ RTL support (Arabic)
- ✅ Material 3 design

---

## ⚠️ Common Errors

| Error | Solution |
|-------|----------|
| `No pubspec.yaml file found` | Make sure you're in the `pdf_master_pro` folder |
| `flutter: command not found` | Add Flutter to PATH |
| `No devices found` | Start an emulator or connect a phone with USB debugging |
| `SDK not found` | Run `flutter doctor` and follow instructions |

---

Made with ❤️ using Flutter & Dart
