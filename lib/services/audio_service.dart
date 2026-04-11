import 'package:audioplayers/audioplayers.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';

class TrackInfo {
  final String id;
  final String name;
  final String emoji;
  final String description;

  const TrackInfo({
    required this.id,
    required this.name,
    required this.emoji,
    required this.description,
  });
}

class AudioService {
  static final AudioService _instance = AudioService._internal();
  factory AudioService() => _instance;
  AudioService._internal();

  AudioPlayer? _player;
  bool _isMuted = false;
  bool _isPlaying = false;
  double _volume = 0.4;
  String _currentTrackId = 'deep_sleep';

  bool get isMuted => _isMuted;
  bool get isPlaying => _isPlaying;
  double get volume => _volume;
  String get currentTrackId => _currentTrackId;

  static const List<TrackInfo> tracks = [
    TrackInfo(
      id: 'deep_sleep',
      name: 'Deep Sleep',
      emoji: '🌙',
      description: '432Hz calming drone',
    ),
    TrackInfo(
      id: 'rain_sounds',
      name: 'Rain Sounds',
      emoji: '🌧️',
      description: 'Gentle rainfall',
    ),
    TrackInfo(
      id: 'ocean_waves',
      name: 'Ocean Waves',
      emoji: '🌊',
      description: 'Soft ocean rhythm',
    ),
  ];

  TrackInfo get currentTrack =>
      tracks.firstWhere((t) => t.id == _currentTrackId,
          orElse: () => tracks[0]);

  Future<void> init() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _isMuted = prefs.getBool('music_muted') ?? false;
      _volume = prefs.getDouble('music_volume') ?? 0.4;
      _currentTrackId = prefs.getString('music_track') ?? 'deep_sleep';

      // Skip on web — no dart:js dependency
      if (kIsWeb) return;

      _player = AudioPlayer();
      await _player!.setReleaseMode(ReleaseMode.loop);
      await _player!.setVolume(0);
      if (!_isMuted) await _startPlaying();
    } catch (e) {
      // Silently fail
    }
  }

  Future<void> startAudio() async {
    if (kIsWeb) return;
    if (!_isPlaying) await _startPlaying();
  }

  Future<void> _startPlaying() async {
    if (kIsWeb || _player == null) return;
    try {
      await _player!.play(AssetSource('audio/${_currentTrackId}.mp3'));
      _isPlaying = true;
      await _fadeIn();
    } catch (e) {
      _isPlaying = false;
    }
  }

  Future<void> switchTrack(String trackId) async {
    _currentTrackId = trackId;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('music_track', trackId);
    if (kIsWeb || _player == null) return;
    await _fadeOut();
    await _player!.stop();
    _isPlaying = false;
    if (!_isMuted) await _startPlaying();
  }

  Future<void> setMuted(bool muted) async {
    _isMuted = muted;
    if (!kIsWeb && _player != null) {
      if (_isMuted) {
        await _fadeOut();
      } else {
        if (!_isPlaying) await _startPlaying();
        else await _fadeIn();
      }
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('music_muted', _isMuted);
  }

  Future<void> setVolume(double volume) async {
    _volume = volume.clamp(0.0, 1.0);
    if (!kIsWeb && _player != null && !_isMuted) {
      try { await _player!.setVolume(_volume); } catch (_) {}
    }
    if (_volume == 0) _isMuted = true;
    else if (_isMuted) _isMuted = false;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('music_volume', _volume);
    await prefs.setBool('music_muted', _isMuted);
  }

  Future<void> _fadeIn() async {
    if (kIsWeb || _player == null) return;
    for (int i = 0; i <= 20; i++) {
      await Future.delayed(const Duration(milliseconds: 100));
      try { await _player!.setVolume((_volume * i / 20).clamp(0.0, 1.0)); } catch (_) {}
    }
  }

  Future<void> _fadeOut() async {
    if (kIsWeb || _player == null) return;
    for (int i = 20; i >= 0; i--) {
      await Future.delayed(const Duration(milliseconds: 40));
      try { await _player!.setVolume(_volume * i / 20); } catch (_) {}
    }
  }
}
