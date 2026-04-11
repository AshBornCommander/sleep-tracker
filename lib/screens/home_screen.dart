import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/app_theme.dart';
import '../widgets/music_control_widget.dart';
import 'calendar_screen.dart';
import 'report_screen.dart';
import 'about_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  String _name = '';
  int _age = 25;
  String _gender = 'Male';
  TimeOfDay? _bedTime;
  TimeOfDay? _wakeTime;
  double _hoursSlept = 0;
  late AnimationController _cardController;
  late Animation<double> _cardFade;

  @override
  void initState() {
    super.initState();
    AppTheme.currentMode = AppTheme.getAutoTheme();
    _cardController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _cardFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _cardController, curve: Curves.easeOut),
    );
    _loadUserData();
    _cardController.forward();
  }

  @override
  void dispose() {
    _cardController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _name = prefs.getString('name') ?? 'Friend';
      _age = prefs.getInt('age') ?? 25;
      _gender = prefs.getString('gender') ?? 'Male';
    });
  }

  void _switchTheme() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _buildThemePicker(),
    );
  }

  Widget _buildThemePicker() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: AppTheme.primaryColor.withOpacity(0.3)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Choose Theme',
              style: GoogleFonts.poppins(
                  fontSize: 18, fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary)),
          const SizedBox(height: 20),
          Row(
            children: [
              _themeOption(mode: AppThemeMode.morning,
                  icon: Icons.wb_sunny_rounded, label: 'Morning',
                  gradient: [const Color(0xFFFF8C42), const Color(0xFFFFD700)]),
              const SizedBox(width: 10),
              _themeOption(mode: AppThemeMode.afternoon,
                  icon: Icons.wb_cloudy_rounded, label: 'Midday',
                  gradient: [const Color(0xFF4A90E2), const Color(0xFF00C9FF)]),
              const SizedBox(width: 10),
              _themeOption(mode: AppThemeMode.night,
                  icon: Icons.nightlight_round, label: 'Night',
                  gradient: [const Color(0xFF6C63FF), const Color(0xFF00D2FF)]),
            ],
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _themeOption({required AppThemeMode mode, required IconData icon,
      required String label, required List<Color> gradient}) {
    final isSelected = AppTheme.currentMode == mode;
    return Expanded(
      child: GestureDetector(
        onTap: () { setState(() => AppTheme.currentMode = mode); Navigator.pop(context); },
        child: Container(
          height: 86,
          clipBehavior: Clip.hardEdge,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(colors: gradient,
                begin: Alignment.topLeft, end: Alignment.bottomRight),
            border: isSelected ? Border.all(color: Colors.white, width: 2.5) : null,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.white, size: 24),
              const SizedBox(height: 4),
              Text(label, style: GoogleFonts.poppins(
                  fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white)),
              if (isSelected) const Icon(Icons.check_circle, color: Colors.white, size: 13),
            ],
          ),
        ),
      ),
    );
  }

  String _getRecommendedHours() {
    if (_age >= 6 && _age <= 12) return '9-12';
    if (_age >= 13 && _age <= 17) return '8-10';
    if (_age >= 18 && _age <= 64) return '7-9';
    return '7-8';
  }

  String _getSleepStatus() {
    if (_hoursSlept == 0) return 'Log your sleep below';
    final parts = _getRecommendedHours().split('-');
    final min = double.parse(parts[0]);
    final max = double.parse(parts[1]);
    if (_hoursSlept < min) return 'Below recommended';
    if (_hoursSlept > max) return 'Above recommended';
    return 'Great sleep!';
  }

  ThemeData _timePickerTheme() => ThemeData.dark().copyWith(
    colorScheme: const ColorScheme.dark(
      primary: Color(0xFF6C63FF), onPrimary: Colors.white,
      surface: Color(0xFF1D1E33), onSurface: Colors.white,
    ),
    timePickerTheme: const TimePickerThemeData(
      backgroundColor: Color(0xFF1D1E33),
      hourMinuteTextColor: Colors.white,
      dayPeriodTextColor: Colors.white,
      dialHandColor: Color(0xFF6C63FF),
      dialTextColor: Colors.white,
    ),
  );

  Future<void> _pickBedTime() async {
    final time = await showTimePicker(
      context: context, initialTime: const TimeOfDay(hour: 22, minute: 0),
      builder: (context, child) => Theme(data: _timePickerTheme(), child: child!),
    );
    if (time != null) setState(() { _bedTime = time; _calculateHours(); });
  }

  Future<void> _pickWakeTime() async {
    final time = await showTimePicker(
      context: context, initialTime: const TimeOfDay(hour: 6, minute: 0),
      builder: (context, child) => Theme(data: _timePickerTheme(), child: child!),
    );
    if (time != null) setState(() { _wakeTime = time; _calculateHours(); });
  }

  void _calculateHours() {
    if (_bedTime != null && _wakeTime != null) {
      int bedMin = _bedTime!.hour * 60 + _bedTime!.minute;
      int wakeMin = _wakeTime!.hour * 60 + _wakeTime!.minute;
      if (wakeMin <= bedMin) wakeMin += 1440;
      setState(() => _hoursSlept = (wakeMin - bedMin) / 60);
    }
  }

  Future<void> _saveSleepLog() async {
    if (_bedTime == null || _wakeTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Please set both times', style: GoogleFonts.poppins()),
        backgroundColor: AppTheme.primaryColor, behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ));
      return;
    }
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now().toIso8601String().split('T')[0];
    await prefs.setString('sleep_$today',
        '${_bedTime!.hour}:${_bedTime!.minute}-${_wakeTime!.hour}:${_wakeTime!.minute}');
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Sleep logged! 🌙', style: GoogleFonts.poppins()),
        backgroundColor: const Color(0xFF4CAF50), behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ));
    }
  }

  String _formatHour(TimeOfDay? time) {
    if (time == null) return '--:--';
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  String _formatPeriod(TimeOfDay? time) {
    if (time == null) return '';
    return time.period == DayPeriod.am ? 'AM' : 'PM';
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      color: AppTheme.background,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: FadeTransition(
            opacity: _cardFade,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  const SizedBox(height: 20),
                  _buildSleepScoreCard(),
                  const SizedBox(height: 16),
                  _buildSleepLogCard(),
                  const SizedBox(height: 16),
                  _buildQuickStats(),
                  const SizedBox(height: 16),
                  _buildSaveButton(),
                  const SizedBox(height: 16),
                  _buildNavigationCards(),
                  const SizedBox(height: 16),
                  MusicControlWidget(),
                  const SizedBox(height: 16),
                  _buildAboutButton(),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final hour = DateTime.now().hour;
    String greeting = hour < 12 ? 'Good Morning' : hour < 17 ? 'Good Afternoon' : 'Good Evening';
    String emoji = hour < 12 ? '☀️' : hour < 17 ? '🌤️' : '🌙';
    String displayName = _name.isEmpty ? 'Friend' : _name.split(' ').first;
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('$greeting $emoji', style: GoogleFonts.poppins(
                  fontSize: 13, color: AppTheme.textSecondary)),
              Text(displayName, overflow: TextOverflow.ellipsis, maxLines: 1,
                  style: GoogleFonts.poppins(fontSize: 26,
                      fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
            ],
          ),
        ),
        const SizedBox(width: 8),
        GestureDetector(
          onTap: _switchTheme,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 400),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: AppTheme.gradientColors),
              borderRadius: BorderRadius.circular(14),
              boxShadow: [BoxShadow(color: AppTheme.primaryColor.withOpacity(0.4),
                  blurRadius: 10, offset: const Offset(0, 4))],
            ),
            child: Icon(
              AppTheme.currentMode == AppThemeMode.morning ? Icons.wb_sunny_rounded
                  : AppTheme.currentMode == AppThemeMode.afternoon ? Icons.wb_cloudy_rounded
                  : Icons.nightlight_round,
              color: Colors.white, size: 24,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSleepScoreCard() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(colors: AppTheme.gradientColors,
            begin: Alignment.topLeft, end: Alignment.bottomRight),
        boxShadow: [BoxShadow(color: AppTheme.primaryColor.withOpacity(0.4),
            blurRadius: 20, offset: const Offset(0, 10))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Tonight's Sleep", style: GoogleFonts.poppins(
              fontSize: 13, color: Colors.white.withOpacity(0.8))),
          const SizedBox(height: 6),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(_hoursSlept == 0 ? '--' : _hoursSlept.toStringAsFixed(1),
                  style: GoogleFonts.poppins(fontSize: 52,
                      fontWeight: FontWeight.bold, color: Colors.white, height: 1)),
              Padding(
                padding: const EdgeInsets.only(bottom: 8, left: 6),
                child: Text('hrs', style: GoogleFonts.poppins(
                    fontSize: 18, color: Colors.white.withOpacity(0.8))),
              ),
            ],
          ),
          Text(_getSleepStatus(), style: GoogleFonts.poppins(
              fontSize: 13, color: Colors.white, fontWeight: FontWeight.w500)),
          Text('Recommended: ${_getRecommendedHours()} hrs for age $_age',
              style: GoogleFonts.poppins(fontSize: 11,
                  color: Colors.white.withOpacity(0.6))),
        ],
      ),
    );
  }

  Widget _buildSleepLogCard() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppTheme.cardColor, borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppTheme.primaryColor.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Log Your Sleep', style: GoogleFonts.poppins(
              fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
          const SizedBox(height: 14),
          Row(
            children: [
              // FIX 1,2,3: Fixed height box, time never wraps
              Expanded(child: _buildTimeButton(
                label: 'Bed Time', hour: _formatHour(_bedTime),
                period: _formatPeriod(_bedTime),
                icon: Icons.bedtime_outlined, color: AppTheme.primaryColor,
                onTap: _pickBedTime,
              )),
              const SizedBox(width: 12),
              Expanded(child: _buildTimeButton(
                label: 'Wake Time', hour: _formatHour(_wakeTime),
                period: _formatPeriod(_wakeTime),
                icon: Icons.wb_sunny_outlined, color: AppTheme.accentColor,
                onTap: _pickWakeTime,
              )),
            ],
          ),
        ],
      ),
    );
  }

  // FIX 1,2,3: Precise fixed container - no flex, no column overflow
  Widget _buildTimeButton({
    required String label, required String hour, required String period,
    required IconData icon, required Color color, required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 100,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Label row
            Row(
              children: [
                Icon(icon, color: color, size: 16),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(label, overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(
                          fontSize: 10, color: AppTheme.textSecondary)),
                ),
              ],
            ),
            // Time display - hour on one line, period on next
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(hour,
                    style: GoogleFonts.poppins(
                        fontSize: 22, fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary, height: 1.0)),
                if (period.isNotEmpty)
                  Text(period,
                      style: GoogleFonts.poppins(
                          fontSize: 11, color: color,
                          fontWeight: FontWeight.w600, height: 1.0)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickStats() {
    return Row(
      children: [
        Expanded(child: _buildStatCard(label: 'Age Group',
            value: _age <= 17 ? 'Teen' : _age <= 64 ? 'Adult' : 'Senior',
            icon: Icons.person_outline, color: AppTheme.primaryColor)),
        const SizedBox(width: 10),
        Expanded(child: _buildStatCard(label: 'Gender', value: _gender,
            icon: Icons.wc_outlined, color: AppTheme.accentColor)),
        const SizedBox(width: 10),
        Expanded(child: _buildStatCard(label: 'Target',
            value: '${_getRecommendedHours()}h',
            icon: Icons.flag_outlined, color: const Color(0xFF4CAF50))),
      ],
    );
  }

  Widget _buildStatCard({required String label, required String value,
      required IconData icon, required Color color}) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 6),
      decoration: BoxDecoration(
        color: AppTheme.cardColor, borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 6),
          Text(value, style: GoogleFonts.poppins(fontSize: 13,
              fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
          Text(label, textAlign: TextAlign.center,
              style: GoogleFonts.poppins(fontSize: 9, color: AppTheme.textSecondary)),
        ],
      ),
    );
  }

  Widget _buildSaveButton() {
    return GestureDetector(
      onTap: _saveSleepLog,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 500),
        width: double.infinity, height: 54,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(colors: AppTheme.gradientColors,
              begin: Alignment.centerLeft, end: Alignment.centerRight),
          boxShadow: [BoxShadow(color: AppTheme.primaryColor.withOpacity(0.4),
              blurRadius: 20, offset: const Offset(0, 10))],
        ),
        child: Center(child: Text('Save Sleep Log 🌙',
            style: GoogleFonts.poppins(fontSize: 16,
                fontWeight: FontWeight.bold, color: Colors.white))),
      ),
    );
  }

  Widget _buildNavigationCards() {
    return Row(
      children: [
        Expanded(child: _buildNavCard(label: 'Calendar',
            icon: Icons.calendar_month_outlined, color: AppTheme.primaryColor,
            onTap: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const CalendarScreen()))
                .then((_) => setState(() {})))),
        const SizedBox(width: 12),
        Expanded(child: _buildNavCard(label: 'Weekly Report',
            icon: Icons.bar_chart_outlined, color: AppTheme.accentColor,
            onTap: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const ReportScreen())))),
      ],
    );
  }

  Widget _buildNavCard({required String label, required IconData icon,
      required Color color, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 500),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          color: AppTheme.cardColor, borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(width: 8),
            Flexible(child: Text(label, overflow: TextOverflow.ellipsis,
                style: GoogleFonts.poppins(fontSize: 13,
                    fontWeight: FontWeight.bold, color: AppTheme.textPrimary))),
          ],
        ),
      ),
    );
  }

  Widget _buildAboutButton() {
    return GestureDetector(
      onTap: () => Navigator.push(
          context, MaterialPageRoute(builder: (_) => const AboutScreen())),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 500),
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.cardColor, borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppTheme.primaryColor.withOpacity(0.2)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: AppTheme.gradientColors),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.person_rounded, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('About SleepWell', style: GoogleFonts.poppins(
                      fontSize: 14, fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary)),
                  Text('Meet the developer', style: GoogleFonts.poppins(
                      fontSize: 11, color: AppTheme.textSecondary)),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, color: AppTheme.textSecondary, size: 14),
          ],
        ),
      ),
    );
  }
}
