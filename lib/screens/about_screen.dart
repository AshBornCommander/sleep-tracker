import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import '../theme/app_theme.dart';

class AboutScreen extends StatefulWidget {
  const AboutScreen({super.key});

  @override
  State<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen> {
  String? _userPhotoPath;
  String _userName = '';

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _userName = prefs.getString('name') ?? 'User';
      _userPhotoPath = prefs.getString('user_photo_path');
    });
  }

  Future<void> _pickPhoto() async {
    if (kIsWeb) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Photo upload works on Android!', style: GoogleFonts.poppins()),
        backgroundColor: AppTheme.primaryColor, behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ));
      return;
    }
    try {
      final picker = ImagePicker();
      final image = await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
      if (image != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_photo_path', image.path);
        setState(() => _userPhotoPath = image.path);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Photo updated! 📸', style: GoogleFonts.poppins()),
            backgroundColor: const Color(0xFF4CAF50), behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ));
        }
      }
    } catch (e) { /* Silently fail */ }
  }

  String get _displayName =>
      _userName.isEmpty ? 'User' : _userName.split(' ').first;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      color: AppTheme.background,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent, elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios, color: AppTheme.textPrimary),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text('About SleepWell', style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
          child: Column(
            children: [
              _buildUserProfileCard(),
              const SizedBox(height: 16),
              _buildDeveloperCard(),
              const SizedBox(height: 16),
              _buildAppInfoCard(),
              const SizedBox(height: 16),
              _buildRateUsCard(context),
              const SizedBox(height: 16),
              _buildShareCard(context),
              const SizedBox(height: 16),
              _buildVersionCard(),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUserProfileCard() {
    final initials = _userName.isNotEmpty
        ? _userName.trim().split(' ').map((e) => e[0]).take(2).join().toUpperCase()
        : 'U';
    return Container(
      width: double.infinity, padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.cardColor, borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppTheme.primaryColor.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text('Your Profile', style: GoogleFonts.poppins(
              fontSize: 15, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
          const SizedBox(height: 16),
          Stack(
            children: [
              GestureDetector(
                onTap: _pickPhoto,
                child: Container(
                  width: 90, height: 90,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(colors: AppTheme.gradientColors),
                    border: Border.all(color: AppTheme.primaryColor, width: 3),
                  ),
                  child: ClipOval(
                    child: _userPhotoPath != null && !kIsWeb
                        ? Image.file(File(_userPhotoPath!), fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => _initialsWidget(initials))
                        : _initialsWidget(initials),
                  ),
                ),
              ),
              Positioned(
                bottom: 0, right: 0,
                child: GestureDetector(
                  onTap: _pickPhoto,
                  child: Container(
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: AppTheme.gradientColors),
                      shape: BoxShape.circle,
                      border: Border.all(color: AppTheme.background, width: 2),
                    ),
                    child: const Icon(Icons.camera_alt, color: Colors.white, size: 14),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(_displayName, style: GoogleFonts.poppins(
              fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: _pickPhoto,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: AppTheme.gradientColors),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.camera_alt, color: Colors.white, size: 16),
                  const SizedBox(width: 8),
                  Text(_userPhotoPath != null ? 'Change Photo' : 'Upload Photo',
                      style: GoogleFonts.poppins(fontSize: 13,
                          fontWeight: FontWeight.bold, color: Colors.white)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _initialsWidget(String initials) => Container(
    color: Colors.transparent,
    child: Center(child: Text(initials, style: GoogleFonts.poppins(
        fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white))),
  );

  Widget _buildDeveloperCard() {
    return Container(
      width: double.infinity, padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(colors: AppTheme.gradientColors,
            begin: Alignment.topLeft, end: Alignment.bottomRight),
        boxShadow: [BoxShadow(color: AppTheme.primaryColor.withOpacity(0.4),
            blurRadius: 20, offset: const Offset(0, 10))],
      ),
      child: Column(
        children: [
          Container(
            width: 90, height: 90,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 3),
            ),
            child: ClipOval(
              child: Image.asset('assets/developer.jpeg', fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    color: Colors.white.withOpacity(0.2),
                    child: const Icon(Icons.person_rounded, size: 50, color: Colors.white),
                  )),
            ),
          ),
          const SizedBox(height: 14),
          Text('Pavan Kumar Malladi', textAlign: TextAlign.center,
              style: GoogleFonts.poppins(fontSize: 20,
                  fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 4),
          Text('Creator & Developer', style: GoogleFonts.poppins(
              fontSize: 13, color: Colors.white.withOpacity(0.8))),
          const SizedBox(height: 12),
          Wrap(spacing: 8, runSpacing: 8, alignment: WrapAlignment.center,
            children: [_devBadge('Data Engineer'), _devBadge('App Developer')],
          ),
          const SizedBox(height: 12),
          Text('"Built with passion to help the world sleep better"',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(fontSize: 12,
                  color: Colors.white.withOpacity(0.8), fontStyle: FontStyle.italic)),
        ],
      ),
    );
  }

  Widget _devBadge(String label) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
    decoration: BoxDecoration(
      color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(20),
    ),
    child: Text(label, style: GoogleFonts.poppins(fontSize: 12, color: Colors.white)),
  );

  Widget _buildAppInfoCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.cardColor, borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppTheme.primaryColor.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: AppTheme.gradientColors),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Icons.nightlight_round, color: Colors.white, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('SleepWell', style: GoogleFonts.poppins(fontSize: 18,
                        fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
                    Text('Sleep Better. Live Better.', style: GoogleFonts.poppins(
                        fontSize: 12, color: AppTheme.textSecondary)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text('SleepWell helps you track daily sleep patterns and get personalized recommendations based on your age and gender.',
              style: GoogleFonts.poppins(fontSize: 13,
                  color: AppTheme.textSecondary, height: 1.5)),
        ],
      ),
    );
  }

  Widget _buildRateUsCard(BuildContext context) {
    return GestureDetector(
      onTap: () => _showRateDialog(context),
      child: Container(
        width: double.infinity, padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppTheme.cardColor, borderRadius: BorderRadius.circular(24),
          border: Border.all(color: const Color(0xFFFFD700).withOpacity(0.4)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFFFD700).withOpacity(0.15),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(Icons.star_rounded, color: Color(0xFFFFD700), size: 26),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Rate SleepWell', style: GoogleFonts.poppins(
                      fontSize: 15, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
                  Text('Enjoying the app? Leave a review!', style: GoogleFonts.poppins(
                      fontSize: 12, color: AppTheme.textSecondary)),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, color: AppTheme.textSecondary, size: 14),
          ],
        ),
      ),
    );
  }

  Widget _buildShareCard(BuildContext context) {
    return GestureDetector(
      onTap: () => ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Sharing coming soon!', style: GoogleFonts.poppins()),
        backgroundColor: AppTheme.primaryColor, behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      )),
      child: Container(
        width: double.infinity, padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppTheme.cardColor, borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppTheme.accentColor.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppTheme.accentColor.withOpacity(0.15),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(Icons.share_rounded, color: AppTheme.accentColor, size: 26),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Share SleepWell', style: GoogleFonts.poppins(
                      fontSize: 15, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
                  Text('Help friends sleep better too!', style: GoogleFonts.poppins(
                      fontSize: 12, color: AppTheme.textSecondary)),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, color: AppTheme.textSecondary, size: 14),
          ],
        ),
      ),
    );
  }

  Widget _buildVersionCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: AppTheme.cardColor, borderRadius: BorderRadius.circular(16)),
      child: Center(child: Text('SleepWell v1.0.0  •  Flutter  •  Pavan Kumar Malladi',
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(fontSize: 10, color: AppTheme.textSecondary))),
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
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppTheme.cardColor, borderRadius: BorderRadius.circular(28),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Rate SleepWell', style: GoogleFonts.poppins(
                    fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
                const SizedBox(height: 6),
                Text('How would you rate us?', textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(fontSize: 13, color: AppTheme.textSecondary)),
                const SizedBox(height: 20),
                // FIX 5: Use LayoutBuilder to ensure stars always fit
                LayoutBuilder(
                  builder: (context, constraints) {
                    // Calculate star size based on available width
                    // 5 stars + 8px padding each side = available / 5 - padding
                    final starSize = (constraints.maxWidth - 40) / 5;
                    final clampedSize = starSize.clamp(28.0, 42.0);
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(5, (i) {
                        return GestureDetector(
                          onTap: () => setState(() => selectedStars = i + 1),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: Icon(
                              i < selectedStars ? Icons.star_rounded : Icons.star_outline_rounded,
                              color: const Color(0xFFFFD700),
                              size: clampedSize,
                            ),
                          ),
                        );
                      }),
                    );
                  },
                ),
                const SizedBox(height: 8),
                Text(
                  selectedStars == 5 ? 'Amazing! ⭐' : selectedStars == 4 ? 'Great! 👍'
                      : selectedStars == 3 ? 'Good 👌' : selectedStars == 2 ? 'Fair 😐' : 'Poor 😕',
                  style: GoogleFonts.poppins(fontSize: 15,
                      fontWeight: FontWeight.bold, color: AppTheme.primaryColor),
                ),
                const SizedBox(height: 20),
                GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text('Thank you for $selectedStars stars! ⭐',
                          style: GoogleFonts.poppins()),
                      backgroundColor: const Color(0xFF4CAF50),
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ));
                  },
                  child: Container(
                    width: double.infinity, height: 50,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: AppTheme.gradientColors),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Center(child: Text('Submit Review',
                        style: GoogleFonts.poppins(fontSize: 15,
                            fontWeight: FontWeight.bold, color: Colors.white))),
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
