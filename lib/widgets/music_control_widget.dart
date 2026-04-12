import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/audio_service.dart';
import '../theme/app_theme.dart';
import '../utils/responsive.dart';

class MusicControlWidget extends StatefulWidget {
  const MusicControlWidget({super.key});

  @override
  State<MusicControlWidget> createState() => _MusicControlWidgetState();
}

class _MusicControlWidgetState extends State<MusicControlWidget>
    with SingleTickerProviderStateMixin {
  final AudioService _audio = AudioService();
  late AnimationController _pulseController;
  late Animation<double> _pulseAnim;
  double _sliderVolume = 0.4;

  @override
  void initState() {
    super.initState();
    _sliderVolume = _audio.volume;
    _pulseController = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 1800))
      ..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 0.93, end: 1.07).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut));
  }

  @override
  void dispose() { _pulseController.dispose(); super.dispose(); }

  void _showTrackPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => Container(
        margin: EdgeInsets.all(R.sp(16)),
        padding: EdgeInsets.fromLTRB(R.sp(20), R.sp(16), R.sp(20), R.sp(32)),
        decoration: BoxDecoration(
          color: AppTheme.cardColor,
          borderRadius: BorderRadius.circular(R.sp(28)),
          border: Border.all(color: AppTheme.primaryColor.withOpacity(0.3)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: R.sp(36), height: R.sp(4),
              margin: EdgeInsets.only(bottom: R.sp(16)),
              decoration: BoxDecoration(
                color: AppTheme.textSecondary.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Text('Choose Ambient Music', style: GoogleFonts.poppins(
                fontSize: R.font(17), fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary)),
            SizedBox(height: R.sp(16)),
            ...AudioService.tracks.map((track) {
              final isSelected = _audio.currentTrackId == track.id;
              return GestureDetector(
                onTap: () async {
                  await _audio.switchTrack(track.id);
                  Navigator.pop(context);
                  setState(() {});
                },
                child: Container(
                  margin: EdgeInsets.only(bottom: R.sp(10)),
                  padding: EdgeInsets.all(R.sp(14)),
                  decoration: BoxDecoration(
                    color: isSelected ? AppTheme.primaryColor.withOpacity(0.15)
                        : AppTheme.background,
                    borderRadius: BorderRadius.circular(R.sp(14)),
                    border: Border.all(
                      color: isSelected ? AppTheme.primaryColor
                          : AppTheme.primaryColor.withOpacity(0.1),
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: R.sp(46), height: R.sp(46),
                        decoration: BoxDecoration(
                          gradient: isSelected
                              ? LinearGradient(colors: AppTheme.gradientColors)
                              : LinearGradient(colors: [
                                  AppTheme.textSecondary.withOpacity(0.3),
                                  AppTheme.textSecondary.withOpacity(0.3)]),
                          borderRadius: BorderRadius.circular(R.sp(12)),
                        ),
                        child: Center(child: Text(track.emoji,
                            style: TextStyle(fontSize: R.font(22)))),
                      ),
                      SizedBox(width: R.sp(14)),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(track.name, style: GoogleFonts.poppins(
                                fontSize: R.font(14), fontWeight: FontWeight.bold,
                                color: AppTheme.textPrimary)),
                            Text(track.description, style: GoogleFonts.poppins(
                                fontSize: R.font(11),
                                color: AppTheme.textSecondary)),
                          ],
                        ),
                      ),
                      if (isSelected)
                        Container(
                          padding: const EdgeInsets.all(3),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(colors: AppTheme.gradientColors),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.check, color: Colors.white,
                              size: R.icon(14)),
                        ),
                    ],
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    ).then((_) => setState(() {}));
  }

  @override
  Widget build(BuildContext context) {
    R.init(context);
    final track = _audio.currentTrack;
    final isMuted = _audio.isMuted;

    return Container(
      padding: EdgeInsets.all(R.sp(16)),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(R.sp(24)),
        border: Border.all(
          color: !isMuted ? AppTheme.primaryColor.withOpacity(0.3)
              : AppTheme.primaryColor.withOpacity(0.1),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              AnimatedBuilder(
                animation: _pulseAnim,
                builder: (context, child) => Transform.scale(
                  scale: !isMuted ? _pulseAnim.value : 1.0,
                  child: Container(
                    width: R.sp(44), height: R.sp(44),
                    decoration: BoxDecoration(
                      gradient: !isMuted
                          ? LinearGradient(colors: AppTheme.gradientColors)
                          : LinearGradient(colors: [
                              AppTheme.textSecondary.withOpacity(0.4),
                              AppTheme.textSecondary.withOpacity(0.4)]),
                      borderRadius: BorderRadius.circular(R.sp(12)),
                    ),
                    child: Center(child: Text(isMuted ? '🔇' : track.emoji,
                        style: TextStyle(fontSize: R.font(20)))),
                  ),
                ),
              ),
              SizedBox(width: R.sp(10)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(track.name, overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.poppins(fontSize: R.font(13),
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textPrimary)),
                    Text(isMuted ? 'Tap Unmute' : 'Playing softly...',
                        style: GoogleFonts.poppins(fontSize: R.font(10),
                            color: AppTheme.textSecondary)),
                  ],
                ),
              ),
              SizedBox(width: R.sp(8)),
              GestureDetector(
                onTap: _showTrackPicker,
                child: Container(
                  padding: EdgeInsets.symmetric(
                      horizontal: R.sp(8), vertical: R.sp(6)),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(R.sp(10)),
                    border: Border.all(
                        color: AppTheme.primaryColor.withOpacity(0.3)),
                  ),
                  child: Text('Change', style: GoogleFonts.poppins(
                      fontSize: R.font(10), fontWeight: FontWeight.bold,
                      color: AppTheme.primaryColor)),
                ),
              ),
            ],
          ),
          SizedBox(height: R.sp(12)),
          Row(
            children: [
              GestureDetector(
                onTap: () async {
                  await _audio.setMuted(true);
                  setState(() => _sliderVolume = 0);
                },
                child: Icon(Icons.volume_mute_rounded,
                    color: isMuted ? AppTheme.primaryColor : AppTheme.textSecondary,
                    size: R.icon(20)),
              ),
              SizedBox(width: R.sp(4)),
              Expanded(
                child: SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    activeTrackColor: AppTheme.primaryColor,
                    inactiveTrackColor: AppTheme.primaryColor.withOpacity(0.15),
                    thumbColor: AppTheme.primaryColor,
                    thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 7),
                    overlayColor: AppTheme.primaryColor.withOpacity(0.2),
                    trackHeight: 3,
                    overlayShape: const RoundSliderOverlayShape(overlayRadius: 14),
                  ),
                  child: Slider(
                    value: isMuted ? 0 : _sliderVolume,
                    min: 0, max: 1,
                    onChanged: (val) async {
                      setState(() => _sliderVolume = val);
                      await _audio.setVolume(val);
                      setState(() {});
                    },
                  ),
                ),
              ),
              SizedBox(width: R.sp(4)),
              GestureDetector(
                onTap: () async {
                  setState(() => _sliderVolume = 1.0);
                  await _audio.setVolume(1.0);
                  await _audio.setMuted(false);
                  setState(() {});
                },
                child: Icon(Icons.volume_up_rounded,
                    color: (!isMuted && _sliderVolume > 0.6)
                        ? AppTheme.primaryColor : AppTheme.textSecondary,
                    size: R.icon(20)),
              ),
              SizedBox(width: R.sp(8)),
              GestureDetector(
                onTap: () async {
                  await _audio.setMuted(!isMuted);
                  if (!isMuted) setState(() => _sliderVolume = _audio.volume);
                  setState(() {});
                },
                child: Container(
                  padding: EdgeInsets.symmetric(
                      horizontal: R.sp(10), vertical: R.sp(6)),
                  decoration: BoxDecoration(
                    color: isMuted
                        ? AppTheme.primaryColor.withOpacity(0.15)
                        : const Color(0xFFFF6B6B).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(R.sp(10)),
                    border: Border.all(
                      color: isMuted
                          ? AppTheme.primaryColor.withOpacity(0.3)
                          : const Color(0xFFFF6B6B).withOpacity(0.3),
                    ),
                  ),
                  child: Text(isMuted ? 'Unmute' : 'Mute',
                      style: GoogleFonts.poppins(
                          fontSize: R.font(11), fontWeight: FontWeight.bold,
                          color: isMuted ? AppTheme.primaryColor
                              : const Color(0xFFFF6B6B))),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
