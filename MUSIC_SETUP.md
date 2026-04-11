# ══════════════════════════════════════════
# STEP 1: Add audioplayers to pubspec.yaml
# ══════════════════════════════════════════
# Under dependencies: section, add:

dependencies:
  flutter:
    sdk: flutter
  shared_preferences: ^2.0.0
  fl_chart: ^0.68.0
  google_fonts: ^6.0.0
  animated_text_kit: ^4.2.2
  audioplayers: ^6.0.0      # <-- ADD THIS LINE

# ══════════════════════════════════════════
# STEP 2: Add assets to pubspec.yaml
# ══════════════════════════════════════════
# Under flutter: section add:

flutter:
  uses-material-design: true
  assets:
    - assets/developer.jpeg
    - assets/audio/ambient_sleep.mp3    # <-- ADD THIS LINE

# ══════════════════════════════════════════
# STEP 3: Run in terminal after editing:
# ══════════════════════════════════════════
# flutter pub get
