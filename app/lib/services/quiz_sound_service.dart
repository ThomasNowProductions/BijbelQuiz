import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/settings_provider.dart';
import 'sound_service.dart';
import '../utils/automatic_error_reporter.dart';

/// Shared service for handling quiz-related sounds with mute support
class QuizSoundService {
  final SoundService _soundService;

  QuizSoundService(this._soundService);

  /// Play correct answer sound with mute check
  Future<void> playCorrectAnswerSound(BuildContext context) async {
    final settings = Provider.of<SettingsProvider>(context, listen: false);
    if (settings.mute) return;

    try {
      await _soundService.playCorrect();
    } catch (e) {
      // Report error to automatic error tracking system
      await AutomaticErrorReporter.reportAudioError(
        message: 'Failed to play correct answer sound: ${e.toString()}',
        soundType: 'correct_answer',
        additionalInfo: {'context': 'quiz_sound_service'},
      );
      debugPrint('Error playing correct sound: $e');
    }
  }

  /// Play incorrect answer sound with mute check
  Future<void> playIncorrectAnswerSound(BuildContext context) async {
    final settings = Provider.of<SettingsProvider>(context, listen: false);
    if (settings.mute) return;

    try {
      await _soundService.playIncorrect();
    } catch (e) {
      // Report error to automatic error tracking system
      await AutomaticErrorReporter.reportAudioError(
        message: 'Failed to play incorrect answer sound: ${e.toString()}',
        soundType: 'incorrect_answer',
        additionalInfo: {'context': 'quiz_sound_service'},
      );
      debugPrint('Error playing incorrect sound: $e');
    }
  }
}
