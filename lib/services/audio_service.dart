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
  double _volume = 0.5;
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
      id: 'rain_sounds',
      name: 'Rain Sounds',
      emoji: '🌧️',
      description: 'Gentle rain for peaceful sleep',
      asset: 'audio/rain_sounds.mp3',
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

  Future<void> init() async {
    if (kIsWeb || _initialized) return;
    try {
      _player = AudioPlayer();
      _player!.onLog.listen((msg) => debugPrint('AudioPlayer: $msg'));
      await _player!.setReleaseMode(ReleaseMode.loop);
      await _player!.setVolume(0);
      await _player!.play(AssetSource(tracks[0].asset));
      _initialized = true;
      debugPrint('AudioService initialized with ${tracks[0].asset}');
    } catch (e) {
      debugPrint('AudioService init error: $e');
    }
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
    } catch (e) {
      debugPrint('setMuted error: $e');
    }
  }

  Future<void> setVolume(double vol) async {
    if (kIsWeb) return;
    _volume = vol;
    _isMuted = vol == 0;
    try {
      await _player?.setVolume(vol);
    } catch (e) {
      debugPrint('setVolume error: $e');
    }
  }

  Future<void> switchTrack(String trackId) async {
    if (kIsWeb) return;
    if (_isSwitching) return;
    _isSwitching = true;
    try {
      _currentTrackId = trackId;
      final track = tracks.firstWhere((t) => t.id == trackId);
      debugPrint('Switching to: ${track.asset}');
      await _fadeVolume(0);
      await _player?.stop();
      await _player?.setReleaseMode(ReleaseMode.loop);
      await _player?.setVolume(0);
      await _player?.play(AssetSource(track.asset));
      if (!_isMuted) {
        await _fadeVolume(_volume);
      }
      debugPrint('Switched to: ${track.name}');
    } catch (e) {
      debugPrint('switchTrack error: $e');
    } finally {
      _isSwitching = false;
    }
  }

  Future<void> _fadeVolume(double target) async {
    if (_player == null) return;
    try {
      double current = _isMuted ? 0 : _volume;
      if (target > current) {
        for (double v = current; v <= target; v += 0.05) {
          await _player?.setVolume(v.clamp(0.0, 1.0));
          await Future.delayed(const Duration(milliseconds: 50));
        }
      } else {
        for (double v = current; v >= target; v -= 0.05) {
          await _player?.setVolume(v.clamp(0.0, 1.0));
          await Future.delayed(const Duration(milliseconds: 50));
        }
      }
      await _player?.setVolume(target.clamp(0.0, 1.0));
    } catch (e) {
      debugPrint('fadeVolume error: $e');
    }
  }

  Future<void> stopPlayback() async {
    if (kIsWeb) return;
    try {
      await _fadeVolume(0);
      await _player?.stop();
    } catch (e) {}
  }
}
