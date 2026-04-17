# 🌙 SleepWell — Sleep Better. Live Better.

A Flutter app for **Android & iOS** that helps you track daily sleep patterns, get personalized health insights, and improve your sleep quality.

[![Flutter](https://img.shields.io/badge/Flutter-3.41.7-blue?logo=flutter)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.11.4-blue?logo=dart)](https://dart.dev)
[![Android](https://img.shields.io/badge/Android-6.0+-green?logo=android)](https://android.com)
[![iOS](https://img.shields.io/badge/iOS-13.0+-black?logo=apple)](https://apple.com)
[![Play Store](https://img.shields.io/badge/Google%20Play-Available-brightgreen?logo=google-play)](https://play.google.com/store/apps/details?id=com.pavankumar.sleepwell)
[![License](https://img.shields.io/badge/License-MIT-purple)](LICENSE)

---

## 📱 Screenshots

| Home Screen | Sleep Calendar | Weekly Report | About Screen |
|:-----------:|:--------------:|:-------------:|:------------:|
| ![Home](assets/screenshots/home.jpg) | ![Calendar](assets/screenshots/calendar.jpg) | ![Report](assets/screenshots/report.jpg) | ![About](assets/screenshots/about.jpg) |

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
- ✨ Ethereal Dreams — default dreamy ambient
- 🎷 Smooth Jazz — soft piano jazz
- 🌙 Deep Sleep — 432Hz healing tones
- 🌊 Ocean Waves — soothing ocean sounds
- Smooth fade in/out, volume control, mute toggle

### 🎨 Themes
- 3 themes: Morning (warm), Midday (blue), Night (dark)
- Auto-detects time of day
- Status bar adapts to theme on all screens

### 🔔 Notifications
- Daily 8AM sleep log reminder
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
| Notifications | flutter_local_notifications |
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

# iOS (requires Mac + Xcode)
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
│   └── responsive.dart          # R class - all responsive sizing
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

## 🎨 Design System

```
Background:  #0A0E21  (midnight blue - night)
Card:        #1D1E33  (dark navy)
Primary:     #6C63FF  (purple)
Accent:      #00D2FF  (cyan)
Font:        Poppins (Google Fonts)
```

---

## 📦 Dependencies

```yaml
dependencies:
  google_fonts: ^6.0.0
  shared_preferences: ^2.0.0
  fl_chart: ^0.68.0
  audioplayers: ^6.0.0
  image_picker: ^1.0.0
  flutter_local_notifications: ^17.0.0
  timezone: ^0.9.0
  in_app_review: ^2.0.0
  url_launcher: ^6.0.0
  share_plus: ^10.0.0
```

---

## 📲 Platform Support

| Platform | Status | Store |
|----------|--------|-------|
| Android  | ✅ Live | [Google Play](https://play.google.com/store/apps/details?id=com.pavankumar.sleepwell) |
| iOS      | 🔄 Coming Soon | App Store |

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
| [Live Docs](https://ashborncommander.github.io/sleep-tracker/) | Full documentation index |
| [Privacy Policy](https://ashborncommander.github.io/sleep-tracker/privacy-policy.html) | Data handling |
| [Dev Log](DEVLOG.md) | Development history and lessons |
| [FlutterForge Agent](FlutterForge_Agent_Prompt.md) | AI prompt for building Flutter apps |

---

## 👨‍💻 Developer

**Pavan Kumar Malladi**
Data Engineer & App Developer — Phoenix, Arizona

- GitHub: [@AshBornCommander](https://github.com/AshBornCommander)
- Email: pavankumarmalladi7@gmail.com

---

*Built with ❤️ using Flutter — Android & iOS from a single codebase!* 🚀
