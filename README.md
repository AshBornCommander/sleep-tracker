# 🌙 SleepWell — Sleep Better. Live Better.

A Flutter Android app for tracking daily sleep patterns, getting personalized health insights, and improving sleep quality.

[![Flutter](https://img.shields.io/badge/Flutter-3.41.6-blue?logo=flutter)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.11.4-blue?logo=dart)](https://dart.dev)
[![Android](https://img.shields.io/badge/Android-6.0+-green?logo=android)](https://android.com)
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
- Email your weekly report directly to yourself

### 📅 Sleep Calendar
- Monthly view with color-coded sleep quality
- Tap any past date to log or edit sleep
- Visual legend (Critical / Low / Good / High)

### 🎵 Ambient Music
- 3 built-in tracks: Deep Sleep, Rain Sounds, Ocean Waves
- Smooth fade in/out transitions
- Volume slider + mute toggle
- Continuous loop playback

### 🎨 Themes
- 3 beautiful themes: Morning, Midday, Night
- Auto-detects time of day
- Manual toggle from home screen

### 🔔 Notifications
- Daily 8AM sleep log reminder
- Monday weekly report notification
- Toggle on/off from About screen

### 👤 User Profile
- Personalized onboarding (name, age, gender, email)
- Profile photo upload
- All data stored locally — full privacy

---

## 🛠️ Tech Stack

| Category | Technology |
|----------|-----------|
| Framework | Flutter 3.41.6 |
| Language | Dart 3.11.4 |
| Storage | SharedPreferences (local) |
| Charts | fl_chart |
| Audio | audioplayers |
| Fonts | Google Fonts (Poppins) |
| Notifications | flutter_local_notifications |
| Review | in_app_review |
| Email | url_launcher |

---

## 🚀 Getting Started

### Prerequisites
```bash
# Install Flutter
https://docs.flutter.dev/get-started/install

# Verify installation
flutter doctor
```

### Clone & Run
```bash
# Clone the repo
git clone https://github.com/AshBornCommander/sleep-tracker.git
cd sleep-tracker

# Install dependencies
flutter pub get

# Run on connected device
flutter run

# Build release APK
flutter build appbundle --release
```

---

## 📂 Project Structure

```
lib/
├── main.dart                    # App entry point
├── theme/
│   └── app_theme.dart           # Colors, gradients, theme modes
├── utils/
│   └── responsive.dart          # R class - responsive sizing
├── screens/
│   ├── splash_screen.dart       # Animated splash
│   ├── onboarding_screen.dart   # User setup flow
│   ├── home_screen.dart         # Main sleep logging screen
│   ├── calendar_screen.dart     # Monthly sleep calendar
│   ├── report_screen.dart       # Weekly reports & analytics
│   └── about_screen.dart        # Profile & settings
├── widgets/
│   └── music_control_widget.dart # Ambient music player
└── services/
    ├── audio_service.dart        # Music playback management
    └── notification_service.dart # Local notifications
```

---

## 🎨 Design System

```
Primary:    #6C63FF  (Purple)
Accent:     #00D2FF  (Cyan)
Background: #0A0E21  (Midnight Blue)
Card:       #1D1E33  (Dark Navy)
Font:       Poppins (Google Fonts)
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
```

---

## 🔒 Privacy

SleepWell takes privacy seriously:
- ✅ All data stored **locally on device only**
- ✅ No data transmitted to external servers
- ✅ No ads, no tracking, no analytics
- ✅ Uninstalling the app deletes all data

[Read full Privacy Policy](https://ashborncommander.github.io/sleep-tracker/privacy-policy.html)

---

## 📖 Documentation

| Document | Description |
|----------|-------------|
| [Privacy Policy](https://ashborncommander.github.io/sleep-tracker/privacy-policy.html) | Data handling and user rights |
| [Dev Log](DEVLOG.md) | Complete development history and lessons learned |
| [Music Setup](MUSIC_SETUP.md) | How ambient music was generated |
| [FlutterForge Agent](FlutterForge_Agent_Prompt.md) | AI prompt for building Flutter apps |

---

## 🏪 Download

<a href="https://play.google.com/store/apps/details?id=com.pavankumar.sleepwell">
  <img src="https://play.google.com/intl/en_us/badges/static/images/badges/en_badge_web_generic.png" width="200"/>
</a>

---

## 👨‍💻 Developer

**Pavan Kumar Malladi**  
Data Engineer & App Developer  
Phoenix, Arizona

- GitHub: [@AshBornCommander](https://github.com/AshBornCommander)
- Email: pavankumarmalladi7@gmail.com

---

## 📄 License

This project is licensed under the MIT License.

---

*Built with ❤️ using Flutter — From zero mobile experience to Google Play Store!* 🚀