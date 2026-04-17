import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:url_launcher/url_launcher.dart';
import '../theme/app_theme.dart';
import '../utils/responsive.dart';
import '../services/notification_service.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter/services.dart';

class AboutScreen extends StatefulWidget {
  const AboutScreen({super.key});

  @override
  State<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen> {
  String? _userPhotoPath;
  String _userName = '';
  int _userAge = 25;
  String _userGender = 'Male';
  String _userEmail = '';
  bool _notificationsEnabled = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final notifEnabled = await NotificationService().areNotificationsEnabled();
    setState(() {
      _userName = prefs.getString('name') ?? 'User';
      _userAge = prefs.getInt('age') ?? 25;
      _userGender = prefs.getString('gender') ?? 'Male';
      _userEmail = prefs.getString('email') ?? '';
      _userPhotoPath = prefs.getString('user_photo_path');
      _notificationsEnabled = notifEnabled;
    });
  }

  Future<void> _pickPhoto() async {
    if (kIsWeb) {
      _showSnack('Photo upload works on Android app!', AppTheme.primaryColor);
      return;
    }
    try {
      final picker = ImagePicker();
      final image = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );
      if (image != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_photo_path', image.path);
        setState(() => _userPhotoPath = image.path);
        _showSnack('Photo updated! 📸', const Color(0xFF4CAF50));
      }
    } catch (e) {}
  }

  void _showSnack(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: GoogleFonts.poppins()),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  // FIX 2: Real Play Store / App Store review
  Future<void> _requestReview() async {
    if (kIsWeb) {
      _showRateDialog(context);
      return;
    }
    try {
      final inAppReview = InAppReview.instance;
      if (await inAppReview.isAvailable()) {
        await inAppReview.requestReview();
      } else {
        if (defaultTargetPlatform == TargetPlatform.iOS) {
          _showSnack('App Store listing coming soon!', AppTheme.primaryColor);
        } else {
          await inAppReview.openStoreListing(
            appStoreId: 'com.pavankumar.sleepwell',
          );
        }
      }
    } catch (e) {
      _showRateDialog(context);
    }
  }

  // KEY FIX: Use Uri.encodeComponent for subject/body separately
  // instead of queryParameters which adds + for spaces

  Future<void> _emailWeeklyReport() async {
    final prefs = await SharedPreferences.getInstance();
    final name = prefs.getString('name') ?? 'Friend';
    final age = prefs.getInt('age') ?? 25;
    final gender = prefs.getString('gender') ?? 'Male';
    final email = prefs.getString('email') ?? '';

    if (email.isEmpty) {
      _showSnack(
        'No email found. Please update your profile.',
        const Color(0xFFFF6B6B),
      );
      return;
    }

    final List<String> dayLines = [];
    double total = 0;
    int count = 0;

    for (int i = 6; i >= 0; i--) {
      final date = DateTime.now().subtract(Duration(days: i));
      final dateStr =
          '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
      final val = prefs.getString('sleep_$dateStr');
      final dayName = _getDayName(date.weekday);

      if (val != null) {
        final parts = val.split('-');
        if (parts.length == 2) {
          final bedParts = parts[0].split(':');
          final wakeParts = parts[1].split(':');
          int bedMin = int.parse(bedParts[0]) * 60 + int.parse(bedParts[1]);
          int wakeMin = int.parse(wakeParts[0]) * 60 + int.parse(wakeParts[1]);
          if (wakeMin <= bedMin) wakeMin += 1440;
          final hours = (wakeMin - bedMin) / 60;
          total += hours;
          count++;
          final emoji = hours >= 7 && hours <= 9
              ? '🟢'
              : hours < 7
              ? '🔴'
              : '🔵';
          dayLines.add('$emoji $dayName: ${hours.toStringAsFixed(1)} hrs');
        }
      } else {
        dayLines.add('⚪ $dayName: Not logged');
      }
    }

    final avg = count > 0 ? total / count : 0.0;
    final avgStatus = avg >= 7 && avg <= 9
        ? 'Great! You met your sleep goal!'
        : avg < 7
        ? 'Below recommended (7-9 hrs)'
        : 'Above recommended (7-9 hrs)';
    final tip = avg < 7
        ? 'Try going to bed 30 mins earlier each night.'
        : avg > 9
        ? 'Set a consistent wake time on weekends.'
        : 'Keep it up! Consistent sleep is the key.';

    final subject = 'SleepWell Report - Week of ${_getWeekRange()}';
    final body =
        'SLEEPWELL WEEKLY REPORT\n'
        '========================\n\n'
        'Hello ${name.split(' ').first}!\n\n'
        'Week of ${_getWeekRange()}\n\n'
        'WEEKLY AVERAGE\n'
        '${avg.toStringAsFixed(1)} hrs/night\n'
        '$avgStatus\n\n'
        'DAILY SLEEP LOG\n'
        '----------------\n'
        '${dayLines.join('\n')}\n\n'
        'YOUR GOAL: 7-9 hrs | Age: $age | $gender\n\n'
        'TIP: $tip\n\n'
        '------------------------\n'
        'Sleep Better. Live Better.\n'
        'SleepWell App by Pavan Kumar Malladi';

    // FIX: Build mailto URL manually to avoid + encoding
    final mailtoUrl =
        'mailto:$email'
        '?subject=${Uri.encodeComponent(subject)}'
        '&body=${Uri.encodeComponent(body)}';

    try {
      final uri = Uri.parse(mailtoUrl);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        _showSnack(
          'No email app found on this device',
          const Color(0xFFFF6B6B),
        );
      }
    } catch (e) {
      _showSnack('Could not open email app', const Color(0xFFFF6B6B));
    }
  }

  String _getDayName(int weekday) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[weekday - 1];
  }

  String _getWeekRange() {
    final now = DateTime.now();
    final start = now.subtract(const Duration(days: 6));
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[start.month - 1]} ${start.day} - ${months[now.month - 1]} ${now.day}';
  }

  // FIX 3: Share - platform aware
  Future<void> _shareApp() async {
    try {
      if (defaultTargetPlatform == TargetPlatform.iOS) {
        await Share.share(
          '🌙 Check out SleepWell!\n\nSleep Better. Live Better.\n\nTrack your sleep, get personalized health insights, ambient music & weekly reports.\n\nComing soon to App Store! 🍎',
          subject: 'Check out SleepWell App! 🌙',
        );
      } else {
        await Share.share(
          '🌙 Check out SleepWell!\n\nSleep Better. Live Better.\n\nTrack your sleep, get personalized health insights, ambient music & weekly reports.\n\n📲 Download free on Google Play:\nhttps://play.google.com/store/apps/details?id=com.pavankumar.sleepwell',
          subject: 'Check out SleepWell App! 🌙',
        );
      }
    } catch (e) {
      _showSnack('Could not open share', const Color(0xFFFF6B6B));
    }
  }

  Future<void> _toggleNotifications(bool value) async {
    if (kIsWeb) {
      _showSnack('Notifications work on Android app!', AppTheme.primaryColor);
      return;
    }
    setState(() => _notificationsEnabled = value);
    if (value) {
      await NotificationService().scheduleDailySleepReminder();
      await NotificationService().scheduleWeeklyReport();
      await NotificationService().showTestNotification();
      _showSnack('Notifications enabled! 🔔', const Color(0xFF4CAF50));
    } else {
      await NotificationService().cancelAll();
      _showSnack('Notifications disabled', AppTheme.textSecondary);
    }
  }

  String get _displayName =>
      _userName.isEmpty ? 'User' : _userName.split(' ').first;

  @override
  Widget build(BuildContext context) {
    R.init(context);
    AppTheme.applyStatusBar();
    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      color: AppTheme.background,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          systemOverlayStyle: AppTheme.currentMode == AppThemeMode.night
              ? SystemUiOverlayStyle.light
              : SystemUiOverlayStyle.dark,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios, color: AppTheme.textPrimary),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            'About SleepWell',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
              fontSize: R.font(18),
            ),
          ),
        ),
        body: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(R.sp(16), 0, R.sp(16), R.sp(20)),
          child: Column(
            children: [
              _buildUserProfileCard(),
              SizedBox(height: R.sp(16)),
              _buildNotificationsCard(),
              SizedBox(height: R.sp(16)),
              _buildEmailReportCard(),
              SizedBox(height: R.sp(16)),
              _buildDeveloperCard(),
              SizedBox(height: R.sp(16)),
              _buildAppInfoCard(),
              SizedBox(height: R.sp(16)),
              _buildRateUsCard(context),
              SizedBox(height: R.sp(16)),
              _buildShareCard(context),
              SizedBox(height: R.sp(16)),
              _buildVersionCard(),
              SizedBox(height: R.sp(20)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUserProfileCard() {
    final initials = _userName.isNotEmpty
        ? _userName
              .trim()
              .split(' ')
              .map((e) => e[0])
              .take(2)
              .join()
              .toUpperCase()
        : 'U';
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(R.sp(20)),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(R.sp(24)),
        border: Border.all(color: AppTheme.primaryColor.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(
            'Your Profile',
            style: GoogleFonts.poppins(
              fontSize: R.font(15),
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          SizedBox(height: R.sp(16)),
          Stack(
            children: [
              GestureDetector(
                onTap: _pickPhoto,
                child: Container(
                  width: R.sp(90),
                  height: R.sp(90),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(colors: AppTheme.gradientColors),
                    border: Border.all(color: AppTheme.primaryColor, width: 3),
                  ),
                  child: ClipOval(
                    child: _userPhotoPath != null && !kIsWeb
                        ? Image.file(
                            File(_userPhotoPath!),
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) =>
                                _initialsWidget(initials),
                          )
                        : _initialsWidget(initials),
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: GestureDetector(
                  onTap: _pickPhoto,
                  child: Container(
                    padding: EdgeInsets.all(R.sp(5)),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: AppTheme.gradientColors),
                      shape: BoxShape.circle,
                      border: Border.all(color: AppTheme.background, width: 2),
                    ),
                    child: Icon(
                      Icons.camera_alt,
                      color: Colors.white,
                      size: R.icon(14),
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: R.sp(12)),
          Text(
            _displayName,
            style: GoogleFonts.poppins(
              fontSize: R.font(18),
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          if (_userEmail.isNotEmpty) ...[
            SizedBox(height: R.sp(4)),
            Text(
              _userEmail,
              style: GoogleFonts.poppins(
                fontSize: R.font(12),
                color: AppTheme.textSecondary,
              ),
            ),
          ],
          SizedBox(height: R.sp(8)),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _profileStat('Age', '$_userAge'),
              SizedBox(width: R.sp(20)),
              _profileStat('Gender', _userGender),
            ],
          ),
          SizedBox(height: R.sp(12)),
          GestureDetector(
            onTap: _pickPhoto,
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: R.sp(20),
                vertical: R.sp(10),
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: AppTheme.gradientColors),
                borderRadius: BorderRadius.circular(R.sp(20)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.camera_alt, color: Colors.white, size: R.icon(16)),
                  SizedBox(width: R.sp(8)),
                  Text(
                    _userPhotoPath != null ? 'Change Photo' : 'Upload Photo',
                    style: GoogleFonts.poppins(
                      fontSize: R.font(13),
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _profileStat(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: R.font(16),
            fontWeight: FontWeight.bold,
            color: AppTheme.primaryColor,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: R.font(11),
            color: AppTheme.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _initialsWidget(String initials) => Container(
    color: Colors.transparent,
    child: Center(
      child: Text(
        initials,
        style: GoogleFonts.poppins(
          fontSize: R.font(32),
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    ),
  );

  Widget _buildNotificationsCard() {
    return Container(
      padding: EdgeInsets.all(R.sp(20)),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(R.sp(24)),
        border: Border.all(color: const Color(0xFF4CAF50).withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(R.sp(10)),
                decoration: BoxDecoration(
                  color: const Color(0xFF4CAF50).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(R.sp(14)),
                ),
                child: Icon(
                  Icons.notifications_active_outlined,
                  color: const Color(0xFF4CAF50),
                  size: R.icon(24),
                ),
              ),
              SizedBox(width: R.sp(14)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Sleep Reminders',
                      style: GoogleFonts.poppins(
                        fontSize: R.font(15),
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    Text(
                      'Daily 8AM + Monday weekly report',
                      style: GoogleFonts.poppins(
                        fontSize: R.font(11),
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Switch(
                value: _notificationsEnabled,
                onChanged: _toggleNotifications,
                activeColor: const Color(0xFF4CAF50),
              ),
            ],
          ),
          if (_notificationsEnabled) ...[
            SizedBox(height: R.sp(12)),
            Container(
              padding: EdgeInsets.all(R.sp(12)),
              decoration: BoxDecoration(
                color: const Color(0xFF4CAF50).withOpacity(0.1),
                borderRadius: BorderRadius.circular(R.sp(12)),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.check_circle,
                    color: const Color(0xFF4CAF50),
                    size: R.icon(16),
                  ),
                  SizedBox(width: R.sp(8)),
                  Expanded(
                    child: Text(
                      '🌙 Daily reminder at 8:00 AM\n📊 Weekly report every Monday',
                      style: GoogleFonts.poppins(
                        fontSize: R.font(11),
                        color: AppTheme.textPrimary,
                        height: 1.6,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildEmailReportCard() {
    return GestureDetector(
      onTap: _emailWeeklyReport,
      child: Container(
        padding: EdgeInsets.all(R.sp(20)),
        decoration: BoxDecoration(
          color: AppTheme.cardColor,
          borderRadius: BorderRadius.circular(R.sp(24)),
          border: Border.all(color: AppTheme.accentColor.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(R.sp(10)),
              decoration: BoxDecoration(
                color: AppTheme.accentColor.withOpacity(0.15),
                borderRadius: BorderRadius.circular(R.sp(14)),
              ),
              child: Icon(
                Icons.email_outlined,
                color: AppTheme.accentColor,
                size: R.icon(24),
              ),
            ),
            SizedBox(width: R.sp(14)),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Email My Weekly Report',
                    style: GoogleFonts.poppins(
                      fontSize: R.font(15),
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  Text(
                    _userEmail.isNotEmpty
                        ? 'Send to: $_userEmail'
                        : 'Add email in onboarding first',
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(
                      fontSize: R.font(11),
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: AppTheme.textSecondary,
              size: R.icon(14),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDeveloperCard() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(R.sp(24)),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(R.sp(24)),
        gradient: LinearGradient(
          colors: AppTheme.gradientColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryColor.withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: R.sp(90),
            height: R.sp(90),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 3),
            ),
            child: ClipOval(
              child: Image.asset(
                'assets/developer.jpeg',
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  color: Colors.white.withOpacity(0.2),
                  child: Icon(
                    Icons.person_rounded,
                    size: R.icon(50),
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: R.sp(14)),
          Text(
            'Pavan Kumar Malladi',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: R.font(20),
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: R.sp(4)),
          Text(
            'Creator & Developer',
            style: GoogleFonts.poppins(
              fontSize: R.font(13),
              color: Colors.white.withOpacity(0.8),
            ),
          ),
          SizedBox(height: R.sp(12)),
          Wrap(
            spacing: R.sp(8),
            runSpacing: R.sp(8),
            alignment: WrapAlignment.center,
            children: [_devBadge('Data Engineer'), _devBadge('App Developer')],
          ),
          SizedBox(height: R.sp(12)),
          Text(
            '"Built with passion to help the world sleep better"',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: R.font(12),
              color: Colors.white.withOpacity(0.8),
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  Widget _devBadge(String label) => Container(
    padding: EdgeInsets.symmetric(horizontal: R.sp(14), vertical: R.sp(7)),
    decoration: BoxDecoration(
      color: Colors.white.withOpacity(0.2),
      borderRadius: BorderRadius.circular(R.sp(20)),
    ),
    child: Text(
      label,
      style: GoogleFonts.poppins(fontSize: R.font(12), color: Colors.white),
    ),
  );

  Widget _buildAppInfoCard() {
    return Container(
      padding: EdgeInsets.all(R.sp(20)),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(R.sp(24)),
        border: Border.all(color: AppTheme.primaryColor.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(R.sp(10)),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: AppTheme.gradientColors),
                  borderRadius: BorderRadius.circular(R.sp(14)),
                ),
                child: Icon(
                  Icons.nightlight_round,
                  color: Colors.white,
                  size: R.icon(22),
                ),
              ),
              SizedBox(width: R.sp(14)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'SleepWell',
                      style: GoogleFonts.poppins(
                        fontSize: R.font(18),
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    Text(
                      'Sleep Better. Live Better.',
                      style: GoogleFonts.poppins(
                        fontSize: R.font(12),
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: R.sp(14)),
          Text(
            'SleepWell helps you track daily sleep patterns and get personalized recommendations based on your age and gender.',
            style: GoogleFonts.poppins(
              fontSize: R.font(13),
              color: AppTheme.textSecondary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRateUsCard(BuildContext context) {
    return GestureDetector(
      onTap: _requestReview,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(R.sp(18)),
        decoration: BoxDecoration(
          color: AppTheme.cardColor,
          borderRadius: BorderRadius.circular(R.sp(24)),
          border: Border.all(color: const Color(0xFFFFD700).withOpacity(0.4)),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(R.sp(10)),
              decoration: BoxDecoration(
                color: const Color(0xFFFFD700).withOpacity(0.15),
                borderRadius: BorderRadius.circular(R.sp(14)),
              ),
              child: Icon(
                Icons.star_rounded,
                color: const Color(0xFFFFD700),
                size: R.icon(26),
              ),
            ),
            SizedBox(width: R.sp(14)),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    defaultTargetPlatform == TargetPlatform.iOS
                        ? 'Rate on App Store'
                        : 'Rate on Play Store',
                    style: GoogleFonts.poppins(
                      fontSize: R.font(15),
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  Text(
                    'Opens official store review',
                    style: GoogleFonts.poppins(
                      fontSize: R.font(11),
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: AppTheme.textSecondary,
              size: R.icon(14),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShareCard(BuildContext context) {
    return GestureDetector(
      onTap: _shareApp,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(R.sp(18)),
        decoration: BoxDecoration(
          color: AppTheme.cardColor,
          borderRadius: BorderRadius.circular(R.sp(24)),
          border: Border.all(color: AppTheme.accentColor.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(R.sp(10)),
              decoration: BoxDecoration(
                color: AppTheme.accentColor.withOpacity(0.15),
                borderRadius: BorderRadius.circular(R.sp(14)),
              ),
              child: Icon(
                Icons.share_rounded,
                color: AppTheme.accentColor,
                size: R.icon(26),
              ),
            ),
            SizedBox(width: R.sp(14)),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Share SleepWell',
                    style: GoogleFonts.poppins(
                      fontSize: R.font(15),
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  Text(
                    'Help friends sleep better too!',
                    style: GoogleFonts.poppins(
                      fontSize: R.font(11),
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: AppTheme.textSecondary,
              size: R.icon(14),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVersionCard() {
    return Container(
      padding: EdgeInsets.all(R.sp(14)),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(R.sp(16)),
      ),
      child: Center(
        child: Text(
          'SleepWell v1.0.0  •  Flutter  •  Pavan Kumar Malladi',
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(
            fontSize: R.font(10),
            color: AppTheme.textSecondary,
          ),
        ),
      ),
    );
  }

  void _showRateDialog(BuildContext context) {
    int selectedStars = 5;
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            padding: EdgeInsets.all(R.sp(24)),
            decoration: BoxDecoration(
              color: AppTheme.cardColor,
              borderRadius: BorderRadius.circular(R.sp(28)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Rate SleepWell',
                  style: GoogleFonts.poppins(
                    fontSize: R.font(20),
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ),
                SizedBox(height: R.sp(6)),
                Text(
                  'How would you rate us?',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: R.font(13),
                    color: AppTheme.textSecondary,
                  ),
                ),
                SizedBox(height: R.sp(20)),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final starSize = ((constraints.maxWidth - 40) / 5).clamp(
                      28.0,
                      42.0,
                    );
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(5, (i) {
                        return GestureDetector(
                          onTap: () => setState(() => selectedStars = i + 1),
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: R.sp(4)),
                            child: Icon(
                              i < selectedStars
                                  ? Icons.star_rounded
                                  : Icons.star_outline_rounded,
                              color: const Color(0xFFFFD700),
                              size: starSize,
                            ),
                          ),
                        );
                      }),
                    );
                  },
                ),
                SizedBox(height: R.sp(8)),
                Text(
                  selectedStars == 5
                      ? 'Amazing! ⭐'
                      : selectedStars == 4
                      ? 'Great! 👍'
                      : selectedStars == 3
                      ? 'Good 👌'
                      : selectedStars == 2
                      ? 'Fair 😐'
                      : 'Poor 😕',
                  style: GoogleFonts.poppins(
                    fontSize: R.font(15),
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryColor,
                  ),
                ),
                SizedBox(height: R.sp(20)),
                GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                    _showSnack(
                      'Thank you for $selectedStars stars! ⭐',
                      const Color(0xFF4CAF50),
                    );
                  },
                  child: Container(
                    width: double.infinity,
                    height: R.sp(50),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: AppTheme.gradientColors),
                      borderRadius: BorderRadius.circular(R.sp(16)),
                    ),
                    child: Center(
                      child: Text(
                        'Submit Review',
                        style: GoogleFonts.poppins(
                          fontSize: R.font(15),
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
