# ADD these packages to pubspec.yaml under dependencies:

dependencies:
  flutter:
    sdk: flutter
  shared_preferences: ^2.0.0
  fl_chart: ^0.68.0
  google_fonts: ^6.0.0
  audioplayers: ^6.0.0
  image_picker: ^1.0.0
  
  # ADD THESE 4 NEW PACKAGES:
  flutter_local_notifications: ^17.0.0
  timezone: ^0.9.0
  in_app_review: ^2.0.0
  url_launcher: ^6.0.0


# ALSO add to android/app/src/main/AndroidManifest.xml
# Inside <manifest> tag, add these permissions:

    <uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED"/>
    <uses-permission android:name="android.permission.VIBRATE" />
    <uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>
    <uses-permission android:name="android.permission.SCHEDULE_EXACT_ALARM"/>
    <uses-permission android:name="android.permission.USE_EXACT_ALARM"/>

# ALSO inside <application> tag add:
    <receiver android:exported="false" android:name="com.dexterous.flutterlocalnotifications.ScheduledNotificationReceiver"/>
    <receiver android:exported="false" android:name="com.dexterous.flutterlocalnotifications.ScheduledNotificationBootReceiver">
        <intent-filter>
            <action android:name="android.intent.action.BOOT_COMPLETED"/>
            <action android:name="android.intent.action.MY_PACKAGE_REPLACED"/>
            <action android:name="android.intent.action.QUICKBOOT_POWERON"/>
        </intent-filter>
    </receiver>
