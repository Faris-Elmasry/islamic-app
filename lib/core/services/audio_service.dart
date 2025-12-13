import 'package:just_audio/just_audio.dart';
import 'package:flutter_application_6/core/constants/adhan_options.dart';
import 'package:flutter_application_6/core/services/storage_service.dart';

/// Service for handling audio playback (Adhan sounds)
class AudioService {
  static final AudioPlayer _player = AudioPlayer();
  static bool _isInitialized = false;

  /// Initialize audio service
  static Future<void> init() async {
    if (_isInitialized) return;
    _isInitialized = true;
  }

  /// Play adhan sound
  static Future<bool> playAdhan({String? adhanId}) async {
    try {
      // Get adhan ID from parameter or storage
      final selectedId = adhanId ?? StorageService.getSelectedAdhan();
      final adhan =
          AdhanOptions.getById(selectedId) ?? AdhanOptions.defaultAdhan;

      // Stop any currently playing audio
      await stop();

      // Load and play
      await _player.setAsset(adhan.assetPath);
      await _player.play();
      return true;
    } catch (e) {
      print('Error playing adhan: $e');
      print('Make sure audio files are placed in: assets/audio/');
      return false;
    }
  }

  /// Preview adhan sound (for settings page)
  static Future<bool> previewAdhan(String adhanId) async {
    try {
      final adhan = AdhanOptions.getById(adhanId);
      if (adhan == null) return false;

      await stop();
      await _player.setAsset(adhan.assetPath);
      await _player.play();

      // Stop preview after 10 seconds
      Future.delayed(const Duration(seconds: 10), () {
        if (_player.playing) {
          stop();
        }
      });
      return true;
    } catch (e) {
      print('Error previewing adhan: $e');
      print(
          'Audio file not found: ${AdhanOptions.getById(adhanId)?.assetPath}');
      print('Please add MP3 files to: assets/audio/');
      return false;
    }
  }

  /// Stop audio playback
  static Future<void> stop() async {
    try {
      await _player.stop();
    } catch (e) {
      print('Error stopping audio: $e');
    }
  }

  /// Pause audio playback
  static Future<void> pause() async {
    try {
      await _player.pause();
    } catch (e) {
      print('Error pausing audio: $e');
    }
  }

  /// Resume audio playback
  static Future<void> resume() async {
    try {
      await _player.play();
    } catch (e) {
      print('Error resuming audio: $e');
    }
  }

  /// Check if audio is playing
  static bool get isPlaying => _player.playing;

  /// Get player state stream
  static Stream<PlayerState> get playerStateStream => _player.playerStateStream;

  /// Dispose audio player
  static Future<void> dispose() async {
    await _player.dispose();
    _isInitialized = false;
  }
}
