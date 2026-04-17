# 🌙 SleepWell — Sleep Better. Live Better.

A Flutter app for **Android & iOS** that helps you track daily sleep patterns, get personalized health insights, and improve your sleep quality.

[![Flutter](https://img.shields.io/badge/Flutter-3.41.7-blue?logo=flutter)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.11.4-blue?logo=dart)](https://dart.dev)
[![Android](https://img.shields.io/badge/Android-6.0+-green?logo=android)](https://android.com)
[![iOS](https://img.shields.io/badge/iOS-13.0+-black?logo=apple)](https://apple.com)
[![Play Store](https://img.shields.io/badge/Google%20Play-Live-brightgreen?logo=google-play)](https://play.google.com/store/apps/details?id=com.pavankumar.sleepwell)
[![App Store](https://img.shields.io/badge/App%20Store-Under%20Review-orange?logo=apple)](https://apps.apple.com)
[![License](https://img.shields.io/badge/License-MIT-purple)](LICENSE)

---

## 📲 Download

| Platform | Status | Link |
|----------|--------|------|
| 🤖 Android | ✅ Live | [Google Play Store](https://play.google.com/store/apps/details?id=com.pavankumar.sleepwell) |
| 🍎 iOS | 🔄 Under Review | App Store — Coming Soon |

---

## ✨ Features

### 😴 Sleep Tracking
- Log bed time and wake time daily
- Personalized sleep recommendations based on age and gender
- Real-time sleep score calculation

### 📊 Analytics & Reports
- Weekly sleep bar chart visualization
- Sleep risk analysis (chronic deprivation detection)
- Personalized tips based on your sleep patterns
- Email your weekly report with beautiful formatting

### 📅 Sleep Calendar
- Monthly view with color-coded sleep quality
- Tap any past date to log or edit sleep
- Visual legend (Critical / Low / Good / High)

### 🎵 Ambient Music (4 Tracks)
- ✨ Ethereal Dreams — default dreamy ambient (90s loop)
- 🎷 Smooth Jazz — soft piano jazz
- 🌙 Deep Sleep — 432Hz healing tones
- 🌊 Ocean Waves — soothing ocean sounds
- Smooth fade in/out, volume control, mute toggle

### 🎨 Themes
- 3 themes: Morning (warm), Midday (blue), Night (dark)
- Auto-detects time of day
- Status bar adapts to theme on all screens

### 🔔 Notifications
- Daily 8:25 AM sleep log reminder
- Monday weekly report notification
- Toggle on/off from About screen

### 👤 User Profile
- Personalized onboarding
- Profile photo upload
- All data stored locally — full privacy

### 📤 Share & Review
- Native share sheet (iOS + Android)
- Real Play Store / App Store review dialog
- Beautiful formatted email weekly report

---

## 🛠️ Tech Stack

| Category | Technology |
|----------|-----------|
| Framework | Flutter 3.41.7 |
| Language | Dart 3.11.4 |
| Storage | SharedPreferences (local) |
| Charts | fl_chart |
| Audio | audioplayers |
| Fonts | Google Fonts (Poppins) |
| Notifications | flutter_local_notifications 17.2.4 |
| Review | in_app_review |
| Email/URLs | url_launcher |
| Share | share_plus |

---

## 🚀 Getting Started

### Prerequisites
```bash
flutter doctor
```

### Clone & Run
```bash
git clone https://github.com/AshBornCommander/sleep-tracker.git
cd sleep-tracker
flutter pub get

# Android
flutter run -d <android_device>

# iOS (requires Mac + Xcode 16+)
cd ios && pod install && cd ..
flutter run -d <ios_device>

# Build for Play Store
flutter build appbundle --release

# Build for App Store
flutter build ipa --release
```

---

## 📂 Project Structure

```
lib/
├── main.dart
├── theme/
│   └── app_theme.dart           # Colors, themes, status bar
├── utils/
│   └── responsive.dart          # R class - responsive sizing
├── screens/
│   ├── splash_screen.dart
│   ├── onboarding_screen.dart
│   ├── home_screen.dart
│   ├── calendar_screen.dart
│   ├── report_screen.dart
│   └── about_screen.dart
├── widgets/
│   └── music_control_widget.dart
└── services/
    ├── audio_service.dart
    └── notification_service.dart
assets/
├── audio/
│   ├── ethereal_dreams.mp3      # Default - dreamy ambient
│   ├── smooth_jazz.mp3          # Soft piano jazz
│   ├── deep_sleep.mp3           # 432Hz tones
│   └── ocean_waves.mp3          # Ocean sounds
└── developer.jpeg
```

---

## 📦 Dependencies

```yaml
dependencies:
  google_fonts: ^8.0.2
  shared_preferences: ^2.5.5
  fl_chart: ^1.2.0
  audioplayers: ^6.6.0
  image_picker: ^1.2.1
  flutter_local_notifications: 17.2.4
  timezone: 0.9.4
  in_app_review: ^2.0.11
  url_launcher: ^6.3.2
  share_plus: ^13.0.0
```

---

## 🎨 Design System

```
Night Background:  #0A0E21  (midnight blue)
Card:              #1D1E33  (dark navy)
Primary:           #6C63FF  (purple)
Accent:            #00D2FF  (cyan)
Morning Background:#FFF8F0  (warm white)
Midday Background: #F0F4FF  (cool white)
Font:              Poppins (Google Fonts)
```

---

## 🏪 Store Information

### Google Play Store
```
Package:     com.pavankumar.sleepwell
Version:     1.0.0
Status:      Live ✅
Link:        https://play.google.com/store/apps/details?id=com.pavankumar.sleepwell
```

### Apple App Store
```
Bundle ID:   com.pavankumar.sleepwell
Version:     1.0.0
Status:      Under Review 🔄
Name:        SleepWell: Sleep Better
Submitted:   April 17, 2026
```

---

## 🔒 Privacy

- ✅ All data stored **locally on device only**
- ✅ No data transmitted to external servers
- ✅ No ads, no tracking, no analytics
- ✅ Uninstalling the app deletes all data

[Read full Privacy Policy](https://ashborncommander.github.io/sleep-tracker/privacy-policy.html)

---

## 📖 Documentation

| Document | Description |
|----------|-------------|
| [Live Docs](https://ashborncommander.github.io/sleep-tracker/) | Full documentation site |
| [Privacy Policy](https://ashborncommander.github.io/sleep-tracker/privacy-policy.html) | Data handling |
| [Dev Log](DEVLOG.md) | Development history |
| [FlutterForge Agent](FlutterForge_Agent_Prompt.md) | AI prompt for Flutter apps |

---

## 👨‍💻 Developer

**Pavan Kumar Malladi**
Data Engineer & App Developer — Peoria, Arizona

- GitHub: [@AshBornCommander](https://github.com/AshBornCommander)
- Email: pavankumarmalladi7@gmail.com

---

*Built with ❤️ using Flutter — Android & iOS from a single codebase!* 🚀
