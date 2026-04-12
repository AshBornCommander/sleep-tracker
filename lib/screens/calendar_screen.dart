import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/app_theme.dart';
import '../utils/responsive.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime _focusedMonth = DateTime.now();
  Map<String, double> _sleepData = {};

  @override
  void initState() { super.initState(); _loadSleepData(); }

  Future<void> _loadSleepData() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys().where((k) => k.startsWith('sleep_'));
    final Map<String, double> data = {};
    for (final key in keys) {
      final val = prefs.getString(key);
      if (val != null) {
        final parts = val.split('-');
        if (parts.length == 2) {
          final bedParts = parts[0].split(':');
          final wakeParts = parts[1].split(':');
          int bedMin = int.parse(bedParts[0]) * 60 + int.parse(bedParts[1]);
          int wakeMin = int.parse(wakeParts[0]) * 60 + int.parse(wakeParts[1]);
          if (wakeMin <= bedMin) wakeMin += 1440;
          data[key.replaceFirst('sleep_', '')] = (wakeMin - bedMin) / 60;
        }
      }
    }
    setState(() => _sleepData = data);
  }

  Color _getColorForHours(double hours) {
    if (hours <= 0) return AppTheme.cardColor;
    if (hours < 6) return const Color(0xFFFF6B6B).withOpacity(0.7);
    if (hours < 7) return const Color(0xFFFFB347).withOpacity(0.7);
    if (hours <= 9) return const Color(0xFF4CAF50).withOpacity(0.7);
    return const Color(0xFF00D2FF).withOpacity(0.7);
  }

  void _onDayTapped(int day) {
    final tappedDate = DateTime(_focusedMonth.year, _focusedMonth.month, day);
    final todayDate = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
    if (tappedDate.isAfter(todayDate)) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Can't log future dates!", style: GoogleFonts.poppins()),
        backgroundColor: const Color(0xFFFF6B6B), behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ));
      return;
    }
    final dateStr =
        '${_focusedMonth.year}-${_focusedMonth.month.toString().padLeft(2, '0')}-${day.toString().padLeft(2, '0')}';
    _showSleepLogDialog(dateStr, day);
  }

  void _showSleepLogDialog(String dateStr, int day) {
    TimeOfDay bedTime = const TimeOfDay(hour: 22, minute: 0);
    TimeOfDay wakeTime = const TimeOfDay(hour: 6, minute: 0);

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          String formatH(TimeOfDay t) {
            final h = t.hourOfPeriod == 0 ? 12 : t.hourOfPeriod;
            final m = t.minute.toString().padLeft(2, '0');
            return '$h:$m';
          }
          String formatP(TimeOfDay t) => t.period == DayPeriod.am ? 'AM' : 'PM';
          int bedMin = bedTime.hour * 60 + bedTime.minute;
          int wakeMin = wakeTime.hour * 60 + wakeTime.minute;
          if (wakeMin <= bedMin) wakeMin += 1440;
          final hours = (wakeMin - bedMin) / 60;

          return Dialog(
            backgroundColor: Colors.transparent,
            child: Container(
              padding: EdgeInsets.all(R.sp(20)),
              decoration: BoxDecoration(
                color: AppTheme.cardColor,
                borderRadius: BorderRadius.circular(R.sp(24)),
                border: Border.all(color: AppTheme.primaryColor.withOpacity(0.3)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(
                        horizontal: R.sp(14), vertical: R.sp(8)),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: AppTheme.gradientColors),
                      borderRadius: BorderRadius.circular(R.sp(12)),
                    ),
                    child: Text('${_getMonthName(_focusedMonth.month)} $day',
                        style: GoogleFonts.poppins(fontSize: R.font(14),
                            fontWeight: FontWeight.bold, color: Colors.white)),
                  ),
                  SizedBox(height: R.sp(16)),
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () async {
                            final t = await showTimePicker(
                              context: context, initialTime: bedTime,
                              builder: (ctx, child) => Theme(
                                data: ThemeData.dark().copyWith(
                                  colorScheme: const ColorScheme.dark(
                                    primary: Color(0xFF6C63FF),
                                    surface: Color(0xFF1D1E33),
                                    onSurface: Colors.white,
                                  ),
                                ),
                                child: child!,
                              ),
                            );
                            if (t != null) setDialogState(() => bedTime = t);
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: R.sp(12), vertical: R.sp(10)),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(R.sp(14)),
                              border: Border.all(
                                  color: AppTheme.primaryColor.withOpacity(0.3)),
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('🌙 Bed', style: GoogleFonts.poppins(
                                    fontSize: R.font(10),
                                    color: AppTheme.textSecondary)),
                                SizedBox(height: R.sp(4)),
                                Text(formatH(bedTime), style: GoogleFonts.poppins(
                                    fontSize: R.font(20),
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.textPrimary, height: 1.0)),
                                Text(formatP(bedTime), style: GoogleFonts.poppins(
                                    fontSize: R.font(10),
                                    color: AppTheme.primaryColor,
                                    fontWeight: FontWeight.w600, height: 1.0)),
                              ],
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: R.sp(10)),
                      Expanded(
                        child: GestureDetector(
                          onTap: () async {
                            final t = await showTimePicker(
                              context: context, initialTime: wakeTime,
                              builder: (ctx, child) => Theme(
                                data: ThemeData.dark().copyWith(
                                  colorScheme: const ColorScheme.dark(
                                    primary: Color(0xFF6C63FF),
                                    surface: Color(0xFF1D1E33),
                                    onSurface: Colors.white,
                                  ),
                                ),
                                child: child!,
                              ),
                            );
                            if (t != null) setDialogState(() => wakeTime = t);
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: R.sp(12), vertical: R.sp(10)),
                            decoration: BoxDecoration(
                              color: AppTheme.accentColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(R.sp(14)),
                              border: Border.all(
                                  color: AppTheme.accentColor.withOpacity(0.3)),
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('☀️ Wake', style: GoogleFonts.poppins(
                                    fontSize: R.font(10),
                                    color: AppTheme.textSecondary)),
                                SizedBox(height: R.sp(4)),
                                Text(formatH(wakeTime), style: GoogleFonts.poppins(
                                    fontSize: R.font(20),
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.textPrimary, height: 1.0)),
                                Text(formatP(wakeTime), style: GoogleFonts.poppins(
                                    fontSize: R.font(10),
                                    color: AppTheme.accentColor,
                                    fontWeight: FontWeight.w600, height: 1.0)),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: R.sp(12)),
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(vertical: R.sp(12)),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: AppTheme.gradientColors),
                      borderRadius: BorderRadius.circular(R.sp(12)),
                    ),
                    child: Center(child: Text('${hours.toStringAsFixed(1)} hrs slept',
                        style: GoogleFonts.poppins(fontSize: R.font(18),
                            fontWeight: FontWeight.bold, color: Colors.white))),
                  ),
                  SizedBox(height: R.sp(12)),
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            height: R.sp(44),
                            decoration: BoxDecoration(
                              color: AppTheme.background,
                              borderRadius: BorderRadius.circular(R.sp(12)),
                              border: Border.all(
                                  color: AppTheme.primaryColor.withOpacity(0.3)),
                            ),
                            child: Center(child: Text('Cancel',
                                style: GoogleFonts.poppins(
                                    color: AppTheme.textSecondary,
                                    fontWeight: FontWeight.w600,
                                    fontSize: R.font(13)))),
                          ),
                        ),
                      ),
                      SizedBox(width: R.sp(10)),
                      Expanded(
                        child: GestureDetector(
                          onTap: () async {
                            final prefs = await SharedPreferences.getInstance();
                            await prefs.setString('sleep_$dateStr',
                                '${bedTime.hour}:${bedTime.minute}-${wakeTime.hour}:${wakeTime.minute}');
                            if (mounted) {
                              Navigator.pop(context);
                              _loadSleepData();
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                content: Text('Logged! 🌙', style: GoogleFonts.poppins()),
                                backgroundColor: const Color(0xFF4CAF50),
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12)),
                              ));
                            }
                          },
                          child: Container(
                            height: R.sp(44),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(colors: AppTheme.gradientColors),
                              borderRadius: BorderRadius.circular(R.sp(12)),
                            ),
                            child: Center(child: Text('Save',
                                style: GoogleFonts.poppins(color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: R.font(13)))),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    R.init(context);
    final firstDay = DateTime(_focusedMonth.year, _focusedMonth.month, 1);
    final daysInMonth = DateTime(_focusedMonth.year, _focusedMonth.month + 1, 0).day;
    final startingWeekday = firstDay.weekday % 7;

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
          title: Text('Sleep Calendar', style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold, color: AppTheme.textPrimary,
              fontSize: R.font(18))),
        ),
        body: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(R.sp(16), 0, R.sp(16), R.sp(20)),
          child: Column(
            children: [
              _buildMonthSelector(),
              SizedBox(height: R.sp(4)),
              Text('Tap any date to log sleep', style: GoogleFonts.poppins(
                  fontSize: R.font(12), color: AppTheme.textSecondary)),
              SizedBox(height: R.sp(12)),
              _buildWeekdayHeaders(),
              SizedBox(height: R.sp(6)),
              _buildCalendarGrid(startingWeekday, daysInMonth),
              SizedBox(height: R.sp(20)),
              _buildLegend(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMonthSelector() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          icon: Icon(Icons.chevron_left, color: AppTheme.textPrimary),
          onPressed: () => setState(() {
            _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month - 1);
          }),
        ),
        Text('${_getMonthName(_focusedMonth.month)} ${_focusedMonth.year}',
            style: GoogleFonts.poppins(fontSize: R.font(18),
                fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
        IconButton(
          icon: Icon(Icons.chevron_right, color: AppTheme.textPrimary),
          onPressed: () => setState(() {
            _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month + 1);
          }),
        ),
      ],
    );
  }

  Widget _buildWeekdayHeaders() {
    final days = ['Su', 'Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa'];
    return Row(
      children: days.map((d) => Expanded(
        child: Center(child: Text(d, style: GoogleFonts.poppins(
            fontSize: R.font(11), color: AppTheme.textSecondary,
            fontWeight: FontWeight.w600))),
      )).toList(),
    );
  }

  Widget _buildCalendarGrid(int startingWeekday, int daysInMonth) {
    final totalCells = startingWeekday + daysInMonth;
    final rows = (totalCells / 7).ceil();
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        childAspectRatio: 0.9,
        crossAxisSpacing: 3, mainAxisSpacing: 3,
      ),
      itemCount: rows * 7,
      itemBuilder: (context, index) {
        if (index < startingWeekday || index >= startingWeekday + daysInMonth) {
          return const SizedBox();
        }
        final day = index - startingWeekday + 1;
        final dateStr =
            '${_focusedMonth.year}-${_focusedMonth.month.toString().padLeft(2, '0')}-${day.toString().padLeft(2, '0')}';
        final hours = _sleepData[dateStr] ?? 0;
        final isToday = DateTime.now().day == day &&
            DateTime.now().month == _focusedMonth.month &&
            DateTime.now().year == _focusedMonth.year;
        final isFuture = DateTime(_focusedMonth.year, _focusedMonth.month, day)
            .isAfter(DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day));

        return GestureDetector(
          onTap: () => _onDayTapped(day),
          child: Opacity(
            opacity: isFuture ? 0.3 : 1.0,
            child: Container(
              decoration: BoxDecoration(
                color: _getColorForHours(hours),
                borderRadius: BorderRadius.circular(6),
                border: isToday ? Border.all(color: AppTheme.primaryColor, width: 2) : null,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('$day', style: GoogleFonts.poppins(
                      fontSize: R.font(11), fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary)),
                  if (hours > 0)
                    Text('${hours.toStringAsFixed(1)}h', style: GoogleFonts.poppins(
                        fontSize: R.font(8),
                        color: AppTheme.textPrimary.withOpacity(0.8))),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildLegend() {
    return Container(
      padding: EdgeInsets.all(R.sp(14)),
      decoration: BoxDecoration(color: AppTheme.cardColor,
          borderRadius: BorderRadius.circular(R.sp(16))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Sleep Quality', style: GoogleFonts.poppins(
              fontSize: R.font(12), fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary)),
          SizedBox(height: R.sp(10)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _legendItem(const Color(0xFFFF6B6B), '< 6h', 'Critical'),
              _legendItem(const Color(0xFFFFB347), '6-7h', 'Low'),
              _legendItem(const Color(0xFF4CAF50), '7-9h', 'Good'),
              _legendItem(const Color(0xFF00D2FF), '> 9h', 'High'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _legendItem(Color color, String hours, String label) {
    return Column(
      children: [
        Container(width: R.sp(26), height: R.sp(26),
            decoration: BoxDecoration(color: color,
                borderRadius: BorderRadius.circular(6))),
        SizedBox(height: R.sp(4)),
        Text(hours, style: GoogleFonts.poppins(fontSize: R.font(10),
            color: AppTheme.textPrimary, fontWeight: FontWeight.bold)),
        Text(label, style: GoogleFonts.poppins(
            fontSize: R.font(9), color: AppTheme.textSecondary)),
      ],
    );
  }

  String _getMonthName(int month) {
    const months = ['January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'];
    return months[month - 1];
  }
}
