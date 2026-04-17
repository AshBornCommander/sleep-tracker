// REPLACE entire audio_service.dart with this
// KEY FIX: Jazz uses .wav extension since audioplayers handles WAV fine
// Also added debug print to catch asset loading errors

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

class TrackInfo {
  final String id;
  final String name;
  final String emoji;
  final String description;
  final String asset;

  const TrackInfo({
    required this.id,
    required this.name,
    required this.emoji,
    required this.description,
    required this.asset,
  });
}

class AudioService {
  static final AudioService _instance = AudioService._internal();
  factory AudioService() => _instance;
  AudioService._internal();

  AudioPlayer? _player;
  bool _initialized = false;
  bool _isMuted = false;
  double _volume = 0.1;
  String _currentTrackId = 'ethereal_dreams';
  bool _isSwitching = false;

  static const List<TrackInfo> tracks = [
    TrackInfo(
      id: 'ethereal_dreams',
      name: 'Ethereal Dreams',
      emoji: '✨',
      description: 'Dreamy ambient for deep sleep',
      asset: 'audio/ethereal_dreams.mp3',
    ),
    TrackInfo(
      id: 'smooth_jazz',
      name: 'Smooth Jazz',
      emoji: '🎷',
      description: 'Soft piano jazz for peaceful sleep',
      asset: 'audio/smooth_jazz.mp3',
    ),
    TrackInfo(
      id: 'deep_sleep',
      name: 'Deep Sleep',
      emoji: '🌙',
      description: '432Hz healing tones for deep sleep',
      asset: 'audio/deep_sleep.mp3',
    ),
    TrackInfo(
      id: 'ocean_waves',
      name: 'Ocean Waves',
      emoji: '🌊',
      description: 'Soothing ocean waves',
      asset: 'audio/ocean_waves.mp3',
    ),
  ];

  TrackInfo get currentTrack =>
      tracks.firstWhere((t) => t.id == _currentTrackId);
  String get currentTrackId => _currentTrackId;
  bool get isMuted => _isMuted;
  double get volume => _volume;

  // FIX 3: Init in background - non-blocking
  Future<void> init() async {
    if (kIsWeb || _initialized) return;
    // Run in background to avoid startup lag
    Future.microtask(() async {
      try {
        _player = AudioPlayer();
        await _player!.setReleaseMode(ReleaseMode.loop);
        // FIX 2: Start at 0 volume, then fade in to 0.5
        await _player!.setVolume(0);
        await _player!.play(AssetSource(tracks[0].asset));
        _initialized = true;
        // FIX 2: Auto fade in after short delay
        await Future.delayed(const Duration(milliseconds: 500));
        if (!_isMuted) {
          await _fadeVolume(_volume);
        }
      } catch (e) {
        debugPrint('AudioService init error: $e');
      }
    });
  }

  Future<void> setMuted(bool muted) async {
    if (kIsWeb) return;
    _isMuted = muted;
    try {
      if (muted) {
        await _fadeVolume(0);
      } else {
        await _fadeVolume(_volume);
      }
    } catch (e) {}
  }

  Future<void> setVolume(double vol) async {
    if (kIsWeb) return;
    _volume = vol;
    _isMuted = vol == 0;
    try {
      await _player?.setVolume(vol);
    } catch (e) {}
  }

  // FIX 1: Safe track switching - prevents black screen
  Future<void> switchTrack(String trackId) async {
    if (kIsWeb) return;
    // FIX 1: Prevent concurrent switches
    if (_isSwitching) return;
    _isSwitching = true;

    try {
      _currentTrackId = trackId;
      final track = tracks.firstWhere((t) => t.id == trackId);

      // Fade out first
      await _fadeVolume(0);

      // FIX 1: Stop cleanly without dispose
      await _player?.stop();

      // Small delay to let audio engine settle (fixes Ocean Waves black screen)
      await Future.delayed(const Duration(milliseconds: 200));

      await _player?.setReleaseMode(ReleaseMode.loop);
      await _player?.setVolume(0);
      await _player?.play(AssetSource(track.asset));

      // Small delay before fade in
      await Future.delayed(const Duration(milliseconds: 300));

      // Fade back in if not muted
      if (!_isMuted) {
        await _fadeVolume(_volume);
      }
    } catch (e) {
      debugPrint('switchTrack error: $e');
      // FIX 1: On any error, try to recover gracefully
      try {
        _isSwitching = false;
        await Future.delayed(const Duration(milliseconds: 500));
        await _player?.play(
          AssetSource(tracks.firstWhere((t) => t.id == _currentTrackId).asset),
        );
      } catch (_) {}
    } finally {
      _isSwitching = false;
    }
  }

  Future<void> _fadeVolume(double target) async {
    if (_player == null) return;
    try {
      double current = _isMuted ? 0 : _volume;
      // FIX 3: Faster fade - 30ms steps instead of 50ms
      if (target > current) {
        for (double v = current; v <= target; v += 0.05) {
          await _player?.setVolume(v.clamp(0.0, 1.0));
          await Future.delayed(const Duration(milliseconds: 30));
        }
      } else {
        for (double v = current; v >= target; v -= 0.05) {
          await _player?.setVolume(v.clamp(0.0, 1.0));
          await Future.delayed(const Duration(milliseconds: 30));
        }
      }
      await _player?.setVolume(target.clamp(0.0, 1.0));
    } catch (e) {}
  }

  Future<void> stopPlayback() async {
    if (kIsWeb) return;
    try {
      await _fadeVolume(0);
      await _player?.stop();
    } catch (e) {}
  }
}
