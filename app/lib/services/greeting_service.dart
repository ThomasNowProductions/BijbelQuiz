import 'dart:math';
import 'package:flutter/material.dart';
import 'package:bijbelquiz/l10n/app_localizations.dart';

class GreetingService {
  static final GreetingService _instance = GreetingService._internal();
  factory GreetingService() => _instance;
  GreetingService._internal();

  final _random = Random();

  /// Gets a random greeting based on time of day
  String getRandomGreeting(BuildContext context) {
    final hour = DateTime.now().hour;
    final l10n = AppLocalizations.of(context)!;

    // Select greeting list based on time of day
    List<String> greetings;
    if (hour < 12) {
      greetings = [l10n.goodMorning, l10n.welcomeBack];
    } else if (hour < 18) {
      greetings = [l10n.goodAfternoon, l10n.welcomeBack];
    } else {
      greetings = [l10n.goodEvening, l10n.welcomeBack];
    }

    return greetings[_random.nextInt(greetings.length)];
  }
}
