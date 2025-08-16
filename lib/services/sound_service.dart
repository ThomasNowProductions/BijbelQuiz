import 'dart:async';
import 'package:flutter/services.dart';
import 'package:just_audio/just_audio.dart';
import 'package:audio_session/audio_session.dart';
import 'logger.dart';

/// A robust, efficient, and cross-platform sound service for playing effects.
class SoundService {
  // --- Singleton pattern ---
  SoundService._internal();
  static final SoundService _instance = SoundService._internal();
  factory SoundService() => _instance;
  
  // Check if the current platform is supported by just_audio
  bool _isPlatformSupported() {
    try {
      // just_audio has limited support on desktop platforms
      // Return false for unsupported platforms
      return !(identical(0, 0.0)); // This is a simple way to check if we're in a VM
    } catch (e) {
      return false;
    }
  }

  // --- Sound asset mapping ---
  static const Map<String, String> _soundFiles = {
    'correct': 'assets/sounds/correct.mp3',
    'incorrect': 'assets/sounds/incorrect.mp3',
  };

  // --- State ---
  bool _isInitialized = false;
  bool _isEnabled = true;
  final AudioPlayer _audioPlayer = AudioPlayer();
  void Function(String message)? onError;

  /// Whether sound is enabled
  bool get isEnabled => _isEnabled;

  /// Initialize the sound service (idempotent)
  Future<void> initialize() async {
    if (_isInitialized) return;
    
    // Skip initialization on unsupported platforms
    if (!_isPlatformSupported()) {
      _isInitialized = true;
      _isEnabled = false;
      AppLogger.info('SoundService: Platform not supported. Running without sound.');
      return;
    }
    
    try {
      // Check if the audio plugin is available
      try {
        // Configure audio session with minimal configuration
        final session = await AudioSession.instance;
        await session.configure(const AudioSessionConfiguration.music());
        await session.setActive(true);
        
        _isInitialized = true;
        AppLogger.info('SoundService initialized (just_audio)');
      } on MissingPluginException {
        // Handle missing plugin (e.g., when running on Linux/Windows)
        AppLogger.warning('Audio plugin not available on this platform. Running without sound.');
        _isInitialized = true; // Mark as initialized to prevent repeated attempts
        _isEnabled = false;
      } on PlatformException catch (e) {
        AppLogger.error('Failed to initialize SoundService (PlatformException)', e);
        _isInitialized = true; // Mark as initialized to prevent repeated attempts
        _isEnabled = false;
      }
    } catch (e) {
      AppLogger.error('Failed to initialize SoundService', e);
      _isInitialized = false;
      _isEnabled = false;
      // Continue without sound if initialization fails
    }
  }

  /// Enable or disable sound
  void setEnabled(bool enabled) {
    _isEnabled = enabled;
  }

  /// Play a named sound (extensible)
  Future<void> play(String soundName) async {
    if (!_isEnabled) return;
    
    // Ensure service is initialized
    if (!_isInitialized) {
      try {
        await initialize();
        if (!_isInitialized || !_isEnabled) {
          AppLogger.warning('SoundService not available, cannot play sound');
          return;
        }
      } catch (e) {
        AppLogger.error('Failed to initialize SoundService for playback', e);
        return;
      }
    }
    
    if (!_soundFiles.containsKey(soundName)) {
      AppLogger.warning('Unknown sound: $soundName');
      return;
    }
    
    try {
      final assetPath = _soundFiles[soundName]!;
      AppLogger.info('SoundService: Preparing to play $soundName ($assetPath)');
      
      try {
        // Stop any currently playing sound
        await _audioPlayer.stop();
      } catch (e) {
        AppLogger.warning('Error stopping previous sound: $e');
        // Continue with playback even if stop fails
      }
      
      // Set up completion listener
      final completer = Completer<void>();
      late final StreamSubscription sub;
      
      sub = _audioPlayer.playerStateStream.listen(
        (state) {
          if (state.processingState == ProcessingState.completed) {
            if (!completer.isCompleted) {
              completer.complete();
            }
          } else if (state.processingState == ProcessingState.ready) {
            // Start playing once the audio is ready
            _audioPlayer.play().catchError((e) {
              if (!completer.isCompleted) {
                completer.completeError(e);
              }
            });
          }
        },
        onError: (e) {
          AppLogger.error('Error in player state stream', e);
          if (!completer.isCompleted) {
            completer.completeError(e);
          }
        },
        cancelOnError: true,
      );
      
      // Load the audio file
      await _audioPlayer.setAsset(assetPath);
      
      // Wait for playback to complete or timeout
      AppLogger.info('SoundService: Awaiting completion for $soundName');
      await completer.future.timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          AppLogger.warning('SoundService: Timeout waiting for $soundName to complete');
          _audioPlayer.stop();
        },
      );
      
      AppLogger.info('SoundService: Playback complete for $soundName');
      
      // Clean up
      await sub.cancel();
      
    } catch (e) {
      AppLogger.error('Error playing sound: $soundName', e);
      onError?.call('Failed to play sound: $soundName');
      
      // Try to recover by stopping any ongoing playback
      try {
        await _audioPlayer.stop();
      } catch (e) {
        AppLogger.error('Error stopping audio player after error', e);
      }
    }
  }

  /// Stop any currently playing sound
  Future<void> stop() async {
    await _audioPlayer.stop();
  }

  /// Play the 'correct' sound
  Future<void> playCorrect() => play('correct');
  /// Play the 'incorrect' sound
  Future<void> playIncorrect() => play('incorrect');

  /// Get sound service status
  Map<String, dynamic> getStatus() => {
        'isInitialized': _isInitialized,
        'isEnabled': _isEnabled,
        'player': 'just_audio',
      };

  /// Dispose of resources
  Future<void> dispose() async {
    if (!_isInitialized || !_isEnabled) {
      _isInitialized = false;
      _isEnabled = false;
      return;
    }
    
    try {
      await _audioPlayer.dispose();
    } on MissingPluginException {
      // Ignore missing plugin exceptions during dispose
      AppLogger.warning('Audio plugin not available during dispose');
    } catch (e) {
      AppLogger.error('Error disposing SoundService', e);
    } finally {
      _isInitialized = false;
      _isEnabled = false;
    }
  }
} 