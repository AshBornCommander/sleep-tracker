import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/audio_service.dart';
import '../theme/app_theme.dart';

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
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 0.93, end: 1.07).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _showTrackPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        decoration: BoxDecoration(
          color: AppTheme.cardColor,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: AppTheme.primaryColor.withOpacity(0.3)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 36, height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: AppTheme.textSecondary.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Text('Choose Ambient Music',
                style: GoogleFonts.poppins(
                    fontSize: 17, fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary)),
            const SizedBox(height: 16),
            ...AudioService.tracks.map((track) {
              final isSelected = _audio.currentTrackId == track.id;
              return GestureDetector(
                onTap: () async {
                  await _audio.switchTrack(track.id);
                  Navigator.pop(context);
                  setState(() {});
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppTheme.primaryColor.withOpacity(0.15)
                        : AppTheme.background,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isSelected
                          ? AppTheme.primaryColor
                          : AppTheme.primaryColor.withOpacity(0.1),
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 46, height: 46,
                        decoration: BoxDecoration(
                          gradient: isSelected
                              ? LinearGradient(colors: AppTheme.gradientColors)
                              : LinearGradient(colors: [
                                  AppTheme.textSecondary.withOpacity(0.3),
                                  AppTheme.textSecondary.withOpacity(0.3),
                                ]),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Text(track.emoji,
                              style: const TextStyle(fontSize: 22)),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(track.name,
                                style: GoogleFonts.poppins(
                                    fontSize: 14, fontWeight: FontWeight.bold,
                                    color: AppTheme.textPrimary)),
                            Text(track.description,
                                style: GoogleFonts.poppins(
                                    fontSize: 11, color: AppTheme.textSecondary)),
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
                          child: const Icon(Icons.check, color: Colors.white, size: 14),
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
    final track = _audio.currentTrack;
    final isMuted = _audio.isMuted;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: !isMuted
              ? AppTheme.primaryColor.withOpacity(0.3)
              : AppTheme.primaryColor.withOpacity(0.1),
        ),
      ),
      child: Column(
        children: [
          // Top row
          Row(
            children: [
              AnimatedBuilder(
                animation: _pulseAnim,
                builder: (context, child) => Transform.scale(
                  scale: !isMuted ? _pulseAnim.value : 1.0,
                  child: Container(
                    width: 44, height: 44,
                    decoration: BoxDecoration(
                      gradient: !isMuted
                          ? LinearGradient(colors: AppTheme.gradientColors)
                          : LinearGradient(colors: [
                              AppTheme.textSecondary.withOpacity(0.4),
                              AppTheme.textSecondary.withOpacity(0.4),
                            ]),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(isMuted ? '🔇' : track.emoji,
                          style: const TextStyle(fontSize: 20)),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              // FIX: Title column with Expanded, no Row inside
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(track.name,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.poppins(
                            fontSize: 13, fontWeight: FontWeight.bold,
                            color: AppTheme.textPrimary)),
                    Text(isMuted ? 'Tap Unmute' : 'Playing softly...',
                        style: GoogleFonts.poppins(
                            fontSize: 10, color: AppTheme.textSecondary)),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // Change button - no Row inside, just icon + text
              GestureDetector(
                onTap: _showTrackPicker,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppTheme.primaryColor.withOpacity(0.3)),
                  ),
                  child: Text('Change',
                      style: GoogleFonts.poppins(
                          fontSize: 10, fontWeight: FontWeight.bold,
                          color: AppTheme.primaryColor)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Volume row
          Row(
            children: [
              GestureDetector(
                onTap: () async {
                  await _audio.setMuted(true);
                  setState(() => _sliderVolume = 0);
                },
                child: Icon(Icons.volume_mute_rounded,
                    color: isMuted ? AppTheme.primaryColor : AppTheme.textSecondary,
                    size: 20),
              ),
              const SizedBox(width: 4),
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
              const SizedBox(width: 4),
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
                    size: 20),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () async {
                  await _audio.setMuted(!isMuted);
                  if (!isMuted) setState(() => _sliderVolume = _audio.volume);
                  setState(() {});
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: isMuted
                        ? AppTheme.primaryColor.withOpacity(0.15)
                        : const Color(0xFFFF6B6B).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isMuted
                          ? AppTheme.primaryColor.withOpacity(0.3)
                          : const Color(0xFFFF6B6B).withOpacity(0.3),
                    ),
                  ),
                  child: Text(isMuted ? 'Unmute' : 'Mute',
                      style: GoogleFonts.poppins(
                        fontSize: 11, fontWeight: FontWeight.bold,
                        color: isMuted ? AppTheme.primaryColor : const Color(0xFFFF6B6B),
                      )),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
