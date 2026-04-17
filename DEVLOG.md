# SleepWell — Complete Development Log
**Developer:** Pavan Kumar Malladi  
**Started:** April 2026  
**Status:** Submitted to Google Play Store ✅  
**Package:** com.pavankumar.sleepwell  
**Play Store Account:** pavankumarmalladi7@gmail.com  
**GitHub:** https://github.com/AshBornCommander/sleep-tracker  

---

## 📱 App Overview

**SleepWell** is a Flutter Android app that helps users track their daily sleep patterns and get personalized health insights based on age and gender.

**Tagline:** Sleep Better. Live Better. 🌙

---

## 🛠️ Tech Stack

```
Framework:     Flutter 3.41.6
Language:      Dart 3.11.4
Android SDK:   36
IDE:           VS Code
Version Control: GitHub (AshBornCommander)
Device Tested: Samsung SM A217F
```

---

## 📦 Packages Used

```yaml
google_fonts: ^6.0.0              # Poppins font throughout
shared_preferences: ^2.0.0        # Local data storage
fl_chart: ^0.68.0                 # Weekly sleep bar chart
audioplayers: ^6.0.0              # Ambient music playback
image_picker: ^1.0.0              # Profile photo upload
flutter_local_notifications: ^17.0.0  # Sleep reminders
timezone: ^0.9.0                  # Notification scheduling
in_app_review: ^2.0.0             # Play Store review dialog
url_launcher: ^6.0.0              # Email reports + share
```

---

## 🎨 Design System

```
Background:    #0A0E21  (midnight blue)
Card:          #1D1E33  (dark navy)
Primary:       #6C63FF  (purple)
Accent:        #00D2FF  (cyan)
Text Primary:  #FFFFFF
Text Secondary:#8A8BB0
Success:       #4CAF50
Warning:       #FF6B6B
Font:          Google Fonts - Poppins
```

---

## 📂 File Structure

```
lib/
  main.dart                          # App entry point + notification init
  theme/
    app_theme.dart                   # Colors, gradients, theme modes
  utils/
    responsive.dart                  # R class - all responsive sizing
  screens/
    splash_screen.dart               # Animated moon + fade in
    onboarding_screen.dart           # Name, age, gender, email collection
    home_screen.dart                 # Main screen - sleep log + stats
    calendar_screen.dart             # Monthly calendar with sleep data
    report_screen.dart               # Weekly bar chart + risk analysis
    about_screen.dart                # Profile, notifications, email, rate
  widgets/
    music_control_widget.dart        # Ambient music player widget
  services/
    audio_service.dart               # Music playback management
    notification_service.dart        # Local notification scheduling
assets/
  app_icon.png                       # 1024x1024 moon icon
  developer.jpeg                     # Pavan's photo for About screen
  audio/
    deep_sleep.mp3                   # 432Hz deep sleep tones
    rain_sounds.mp3                  # Gentle rain ambient
    ocean_waves.mp3                  # Soothing ocean waves
```

---

## ✨ Features Built

### Core Features:
- ✅ **Splash Screen** — Animated moon logo with fade-in
- ✅ **Onboarding** — Name, Age (slider), Gender, Email — 3-page flow
- ✅ **Sleep Logging** — Bed time + Wake time pickers
- ✅ **Sleep Score Card** — Shows hours slept vs recommended
- ✅ **Quick Stats** — Age group, Gender, Target hours

### Calendar:
- ✅ **Monthly Calendar** — Color-coded sleep quality per day
- ✅ **Historical Logging** — Tap any past date to log sleep
- ✅ **Color Legend** — Critical/Low/Good/High sleep indicators

### Reports:
- ✅ **Bar Chart** — 7-day sleep visualization
- ✅ **Sleep Risk Analysis** — Chronic deprivation detection
- ✅ **Personalized Tips** — Based on age, gender, patterns

### Music:
- ✅ **3 Ambient Tracks** — Deep Sleep, Rain, Ocean Waves
- ✅ **Fade In/Out** — Smooth volume transitions
- ✅ **Loop** — Continuous playback
- ✅ **Volume Slider** — Fine control
- ✅ **Mute/Unmute** — Quick toggle

### Themes:
- ✅ **3 Themes** — Morning (orange), Midday (blue), Night (purple)
- ✅ **Auto-detect** — Based on time of day
- ✅ **Manual toggle** — Button in header

### About Screen:
- ✅ **User Profile** — Photo upload, name, age, gender, email
- ✅ **Developer Card** — Pavan's photo + bio
- ✅ **Notifications Toggle** — Daily 8AM + Monday weekly report
- ✅ **Email My Report** — Opens email with weekly sleep summary
- ✅ **Rate on Play Store** — Opens real Google Play review dialog
- ✅ **Share** — App sharing

---

## 📱 Responsive Design

All sizing uses the `R` utility class:

```dart
R.init(context)        // Initialize in every build()
R.font(16)             // Responsive font size
R.sp(20)               // Responsive spacing/padding
R.icon(24)             // Responsive icon size
R.h(12)                // % of screen height
R.w(50)                // % of screen width
```

**Base design width:** 360dp (scales up/down for all devices)

---

## 🔧 Android Configuration

### android/app/build.gradle.kts:
```kotlin
applicationId = "com.pavankumar.sleepwell"
minSdk = 21
targetSdk = 36
compileSdk = 36

compileOptions {
    isCoreLibraryDesugaringEnabled = true
    sourceCompatibility = JavaVersion.VERSION_17
    targetCompatibility = JavaVersion.VERSION_17
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}
```

### AndroidManifest.xml Permissions:
```xml
<uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED"/>
<uses-permission android:name="android.permission.VIBRATE"/>
<uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>
<uses-permission android:name="android.permission.SCHEDULE_EXACT_ALARM"/>
<uses-permission android:name="android.permission.USE_EXACT_ALARM"/>
```

---

## 🐛 Bugs Fixed During Development

### Overflow Errors Fixed:
| Location | Error | Fix Applied |
|----------|-------|-------------|
| Home - Wake Time | Right overflow 14px | Added Expanded to label Row |
| Home - Bed Time | Bottom overflow 6px | Fixed height + height:1.0 on text |
| Home - Theme picker | Bottom overflow 7px | Changed label to "Midday", added clipBehavior |
| Calendar - Dialog | Bottom overflow 41px | Removed fixed height, used mainAxisSize.min |
| Calendar - Today date | Bottom overflow 0.7px | Changed childAspectRatio to 0.9 |
| About - Stars | Right overflow 18px | Used LayoutBuilder for dynamic star size |
| Report - Avg hrs | Right overflow 52px | Used first name only |
| Report - Risk analysis | Overflow 39px | Full width cards with wrapping text |
| Report - Tips | Overflow 15px | Full width cards with wrapping text |
| Music widget | Right overflow 14px | Removed icon from Change button Row |
| Weekly report | Right overflow 8px | Replaced Row labels with simple Text |

### Other Fixes:
| Issue | Fix |
|-------|-----|
| Time picker white text on light theme | Forced dark ThemeData for all time pickers |
| AM/PM dropping to next line | Split time into hour + period on separate lines |
| App name showing as "sleep_tracker" | Changed android:label to "SleepWell" |
| App icon not updating | Replaced all mipmap ic_launcher.png files |
| Notification package compile error | Used v17 API without UILocalNotificationDateInterpretation |
| Desugaring error | Added isCoreLibraryDesugaringEnabled + desugar_jdk_libs:2.1.4 |
| Package name com.example | Changed to com.pavankumar.sleepwell |
| Debug signing error | Created release keystore + key.properties |

---

## 📲 Device Connection (Wireless ADB)

```bash
# Add ADB to PATH
$env:PATH += ";$env:LOCALAPPDATA\Android\Sdk\platform-tools"

# Pair device (one time)
adb pair [IP]:[PAIRING_PORT] [CODE]

# Connect device
adb connect [IP]:[PORT]

# Run app
flutter run -d [IP]:[PORT]

# Run release build
flutter run --release -d [IP]:[PORT]
```

**Note:** Samsung SM A217F IP is usually 192.168.0.237
Get port from: Settings → Developer Options → Wireless Debugging

---

## 🔐 Release Signing

```bash
# Keystore created at:
C:\Users\malla\sleep_tracker\upload-keystore.jks

# Key alias: sleepwell
# Validity: 10,000 days
# Algorithm: RSA 2048

# key.properties location:
android/key.properties
```

**⚠️ IMPORTANT:** Never commit key.properties or upload-keystore.jks to GitHub!

---

## 🏪 Google Play Store

### Account Details:
```
Account:    pavankumarmalladi7@gmail.com
Account ID: 6877684297025348791
App:        SleepWell
Package:    com.pavankumar.sleepwell
Version:    1.0.0 (version code 1)
Status:     In Review (submitted April 2026)
```

### Store Listing:
```
Category:      Health & Fitness
Content Rating: Everyone
Target Audience: 18 and over
Privacy Policy: https://ashborncommander.github.io/sleep-tracker/privacy-policy.html
```

### Closed Testing:
```
Track:    Alpha
Testers:  12 testers (SleepWell Testers list)
Countries: 4 regions selected
Required: 14 days testing before production access
```

### Build Command:
```bash
flutter build appbundle --release
# Output: build/app/outputs/bundle/release/app-release.aab
# Size: ~43MB
```

---

## 📋 Data Storage

All data stored locally using SharedPreferences:

```dart
// User profile
prefs.setString('name', ...)
prefs.setInt('age', ...)
prefs.setString('gender', ...)
prefs.setString('email', ...)
prefs.setBool('isOnboarded', true)

// Sleep logs (keyed by date)
prefs.setString('sleep_2026-04-12', '22:0-6:0')
// Format: 'bedHour:bedMin-wakeHour:wakeMin'

// Settings
prefs.setBool('notifications_enabled', ...)
prefs.setString('user_photo_path', ...)
```

---

## 🚀 Version 2 Roadmap

```
High Priority:
□ Firebase backend — cloud sync across devices
□ User authentication — Google Sign-in
□ Real push notifications — FCM
□ Actual automated weekly emails — SendGrid
□ Share sleep report as image

Medium Priority:
□ Sleep score algorithm (0-100)
□ Sleep debt tracker
□ Bedtime reminder (custom time)
□ Dark/Light theme toggle
□ iPad/tablet optimized layout

Nice to Have:
□ Apple Watch / WearOS integration
□ Sleep sounds with timer (auto-stop)
□ Guided sleep meditation
□ Social — compare with friends
□ iOS version (needs Mac)
□ Widget for home screen
```

---

## 💡 Lessons Learned

1. **Always use R.sp() for all sizes** — hardcoded values cause overflow on different screens
2. **Never use fixed heights for content containers** — use padding + mainAxisSize.min
3. **Rows need Expanded for text** — always wrap Text in Expanded inside Row
4. **Time pickers need dark theme forced** — otherwise white text on white background
5. **Dialog boxes need mainAxisSize.min** — prevents bottom overflow
6. **Star ratings need LayoutBuilder** — dynamic sizing prevents overflow
7. **Test on Chrome too** — different viewport catches different bugs
8. **Package name matters** — change from com.example before first upload
9. **Sign with release keystore** — debug builds rejected by Play Store
10. **Desugaring needed for notifications** — add desugar_jdk_libs:2.1.4
11. **Yahoo emails don't work for Play Store testers** — Gmail only
12. **Privacy policy must be live URL** — GitHub Pages works great

---

## 🔗 Important Links

```
GitHub Repo:      https://github.com/AshBornCommander/sleep-tracker
Privacy Policy:   https://ashborncommander.github.io/sleep-tracker/privacy-policy.html
Play Console:     https://play.google.com/console
Tester Link:      https://play.google.com/apps/testing/com.pavankumar.sleepwell
Flutter Docs:     https://docs.flutter.dev
```

---

## 📞 Support

**Developer:** Pavan Kumar Malladi  
**Email:** pavankumarmalladi7@gmail.com  
**GitHub:** AshBornCommander  

---

*This app was built from scratch with zero prior mobile development experience.*  
*From idea to Google Play Store in one session. 🚀*

---

## 🍎 iOS Development (Added April 2026)

### Environment Setup
```
Mac:          MacBook (friend's) — macOS Sequoia 15.7.5
Xcode:        16.3 (downloaded from developer.apple.com)
CocoaPods:    1.16.2
Flutter:      3.41.7 (installed via Homebrew)
Test Device:  Pavan Kumar's iPhone (iOS 26.4.1)
```

### iOS-Specific Setup Steps:
```bash
brew install --cask flutter
brew install cocoapods
sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer
sudo xcodebuild -runFirstLaunch
cd ios && pod install && cd ..
flutter run -d <iphone_device_id>
```

### iOS Configuration Changes:
```
Bundle ID:     com.pavankumar.sleepwell
Display Name:  SleepWell
Team:          Pavan Kumar Malladi (SPGDYUJ6RB)
Min iOS:       13.0
Signing:       Automatic (Xcode managed)
```

### Info.plist additions:
```xml
<key>LSApplicationQueriesSchemes</key>
<array>
    <string>mailto</string>
    <string>https</string>
    <string>http</string>
</array>
```

### App Icons for iOS:
All sizes generated and placed in:
```
ios/Runner/Assets.xcassets/AppIcon.appiconset/
```
Sizes: 20, 29, 38, 40, 57, 58, 60, 76, 80, 87, 114, 120, 152, 167, 180, 1024

---

## 🎵 Music Updates (April 2026)

### New Tracks Added:
```
ethereal_dreams.mp3  → Default track (90 sec loop)
  - Dreamy Dmaj9 pad layer
  - Floating pentatonic melody
  - Deep bass drone
  - Shimmer layer
  - Reverb simulation

smooth_jazz.mp3      → Track 2
  - Cmaj7/Am7/Fmaj7/G7 progression
  - Piano-style tones
  - Soft bass line
```

### Audio Service Updates:
- Added `_isSwitching` flag to prevent black screen crash
- Never dispose player — use stop() only
- Debug logging added
- Ethereal Dreams set as default

---

## 🔧 Bug Fixes (iOS Session)

| Issue | Fix |
|-------|-----|
| Status bar white on light themes | Added `AppTheme.applyStatusBar()` to all screens |
| AppBar overrides status bar | Added `systemOverlayStyle` to all AppBars |
| Share opening email instead of sheet | Added `share_plus` package |
| Email body showing +++ for spaces | Changed to `Uri.encodeComponent()` |
| Jazz no sound | File was WAV disguised as MP3 - regenerated properly |
| CocoaPods build errors | `flutter clean` + `rm -rf Pods Podfile.lock` + `pod install` |
| Missing imports on screens | Added `services.dart`, `app_theme.dart`, `responsive.dart` |

---

## 📦 New Packages Added

```yaml
share_plus: ^10.0.0  # Native share sheet iOS + Android
```

---

## 🏪 App Store Status

```
Apple Developer Account: pavankumarmalladi7@gmail.com
Enrollment:  $99/year — April 2026
Bundle ID:   com.pavankumar.sleepwell
Status:      In Development — pending submission
```

