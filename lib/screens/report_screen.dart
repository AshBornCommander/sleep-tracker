import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fl_chart/fl_chart.dart';
import '../theme/app_theme.dart';

class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key});

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  List<double> _weeklyHours = List.filled(7, 0);
  double _avgHours = 0;
  int _age = 25;
  String _gender = 'Male';
  String _name = '';
  List<String> _risks = [];
  List<String> _tips = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    _age = prefs.getInt('age') ?? 25;
    _gender = prefs.getString('gender') ?? 'Male';
    _name = prefs.getString('name') ?? 'Friend';

    final List<double> hours = [];
    for (int i = 6; i >= 0; i--) {
      final date = DateTime.now().subtract(Duration(days: i));
      final dateStr =
          '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
      final val = prefs.getString('sleep_$dateStr');
      if (val != null) {
        final parts = val.split('-');
        if (parts.length == 2) {
          final bedParts = parts[0].split(':');
          final wakeParts = parts[1].split(':');
          int bedMin = int.parse(bedParts[0]) * 60 + int.parse(bedParts[1]);
          int wakeMin = int.parse(wakeParts[0]) * 60 + int.parse(wakeParts[1]);
          if (wakeMin <= bedMin) wakeMin += 1440;
          hours.add((wakeMin - bedMin) / 60);
        } else {
          hours.add(0);
        }
      } else {
        hours.add(0);
      }
    }

    final logged = hours.where((h) => h > 0).toList();
    final avg = logged.isEmpty ? 0.0 : logged.reduce((a, b) => a + b) / logged.length;

    setState(() {
      _weeklyHours = hours;
      _avgHours = avg;
      _risks = _analyzeRisks(hours, avg);
      _tips = _generateTips(hours, avg);
    });
  }

  String _getRecommended() {
    if (_age >= 6 && _age <= 12) return '9-12';
    if (_age >= 13 && _age <= 17) return '8-10';
    if (_age >= 18 && _age <= 64) return '7-9';
    return '7-8';
  }

  double _getMinRecommended() => double.parse(_getRecommended().split('-')[0]);
  double _getMaxRecommended() => double.parse(_getRecommended().split('-')[1]);

  List<String> _analyzeRisks(List<double> hours, double avg) {
    final risks = <String>[];
    final logged = hours.where((h) => h > 0).toList();
    if (logged.isEmpty) return ['Log at least 3 days to see risk analysis'];
    if (avg < _getMinRecommended()) {
      risks.add('🔴 Chronic sleep deprivation — avg ${avg.toStringAsFixed(1)}h vs ${_getRecommended()}h recommended');
    }
    if (avg > _getMaxRecommended()) {
      risks.add('🟡 Oversleeping detected — may indicate health issues');
    }
    final maxH = hours.where((h) => h > 0).fold(0.0, (a, b) => a > b ? a : b);
    final minH = hours.where((h) => h > 0).fold(24.0, (a, b) => a < b ? a : b);
    if (maxH - minH > 2.5) {
      risks.add('🟠 Irregular schedule — ${(maxH - minH).toStringAsFixed(1)}h variation');
    }
    if (_gender == 'Female' && avg < 7.5) {
      risks.add('🔴 Women need 7.5-8.5h — you may be undersleeping');
    }
    if (_age >= 65 && avg < 7) risks.add('🟡 Seniors need 7-8h — try earlier bedtime');
    if (_age <= 17 && avg < 8) risks.add('🔴 Teens need 8-10h for healthy development');
    if (risks.isEmpty) risks.add('✅ Your sleep looks healthy this week!');
    return risks;
  }

  List<String> _generateTips(List<double> hours, double avg) {
    final tips = <String>[];
    if (avg < _getMinRecommended()) {
      tips.add('💡 Try going to bed 30 mins earlier each night');
      tips.add('💡 Avoid screens 1 hour before bed');
    }
    if (avg > _getMaxRecommended()) tips.add('💡 Set consistent wake time on weekends');
    tips.add('💡 Keep bedroom cool (65-68°F / 18-20°C)');
    tips.add('💡 Avoid caffeine after 2 PM');
    if (_gender == 'Female') tips.add('💡 Track monthly hormonal sleep patterns');
    return tips;
  }

  // FIX 11: Show first name only
  String get _displayName {
    if (_name.isEmpty) return 'Friend';
    return _name.split(' ').first;
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      color: AppTheme.background,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios, color: AppTheme.textPrimary),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text('Weekly Report',
              style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSummaryCard(),
              const SizedBox(height: 16),
              _buildChart(),
              const SizedBox(height: 16),
              _buildRisksCard(),
              const SizedBox(height: 16),
              _buildTipsCard(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
            colors: AppTheme.gradientColors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight),
        boxShadow: [
          BoxShadow(
              color: AppTheme.primaryColor.withOpacity(0.4),
              blurRadius: 20,
              offset: const Offset(0, 10))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // FIX 7: Use first name only, no overflow
          Text("${_displayName}'s Weekly Summary",
              style: GoogleFonts.poppins(
                  fontSize: 14, color: Colors.white.withOpacity(0.8))),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                _avgHours == 0 ? '--' : _avgHours.toStringAsFixed(1),
                style: GoogleFonts.poppins(
                    fontSize: 52,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    height: 1),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 8, left: 6),
                child: Text('avg hrs/night',
                    style: GoogleFonts.poppins(
                        fontSize: 14, color: Colors.white.withOpacity(0.8))),
              ),
            ],
          ),
          Text('Recommended: ${_getRecommended()} hrs for age $_age',
              style: GoogleFonts.poppins(
                  fontSize: 11, color: Colors.white.withOpacity(0.7))),
        ],
      ),
    );
  }

  Widget _buildChart() {
    final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final reordered = [
      _weeklyHours[1], _weeklyHours[2], _weeklyHours[3],
      _weeklyHours[4], _weeklyHours[5], _weeklyHours[6], _weeklyHours[0],
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppTheme.primaryColor.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Sleep This Week',
              style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary)),
          const SizedBox(height: 16),
          SizedBox(
            height: 180,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: 12,
                minY: 0,
                barTouchData: BarTouchData(enabled: false),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 28,
                      getTitlesWidget: (val, meta) => Text('${val.toInt()}h',
                          style: GoogleFonts.poppins(
                              fontSize: 9, color: AppTheme.textSecondary)),
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (val, meta) => Text(days[val.toInt()],
                          style: GoogleFonts.poppins(
                              fontSize: 10, color: AppTheme.textSecondary)),
                    ),
                  ),
                  topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                ),
                gridData: FlGridData(
                  show: true,
                  getDrawingHorizontalLine: (val) => FlLine(
                      color: AppTheme.textSecondary.withOpacity(0.1),
                      strokeWidth: 1),
                  drawVerticalLine: false,
                ),
                borderData: FlBorderData(show: false),
                barGroups: List.generate(7, (i) {
                  final h = reordered[i];
                  final isGood =
                      h >= _getMinRecommended() && h <= _getMaxRecommended();
                  return BarChartGroupData(
                    x: i,
                    barRods: [
                      BarChartRodData(
                        toY: h == 0 ? 0.3 : h,
                        width: 18,
                        borderRadius: BorderRadius.circular(5),
                        gradient: LinearGradient(
                          colors: h == 0
                              ? [AppTheme.cardColor, AppTheme.cardColor]
                              : isGood
                                  ? [const Color(0xFF4CAF50), const Color(0xFF00D2FF)]
                                  : [const Color(0xFFFF6B6B), const Color(0xFFFF6B6B)],
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                        ),
                      ),
                    ],
                  );
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // FIX 8: Risk cards with proper wrapping
  Widget _buildRisksCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFFF6B6B).withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.warning_amber_outlined,
                  color: Color(0xFFFF6B6B), size: 22),
              const SizedBox(width: 8),
              Text('Sleep Risk Analysis',
                  style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary)),
            ],
          ),
          const SizedBox(height: 12),
          ..._risks.map((risk) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.background,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(risk,
                      style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: AppTheme.textPrimary,
                          height: 1.5)),
                ),
              )),
        ],
      ),
    );
  }

  // FIX 9: Tips cards with proper wrapping
  Widget _buildTipsCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFF4CAF50).withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.lightbulb_outline,
                  color: Color(0xFF4CAF50), size: 22),
              const SizedBox(width: 8),
              Text('Personalized Tips',
                  style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary)),
            ],
          ),
          const SizedBox(height: 12),
          ..._tips.map((tip) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.background,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(tip,
                      style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: AppTheme.textPrimary,
                          height: 1.5)),
                ),
              )),
        ],
      ),
    );
  }
}
