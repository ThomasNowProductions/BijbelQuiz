import 'dart:math';
import '../l10n/strings_nl.dart' as strings;

class GreetingService {
  static final GreetingService _instance = GreetingService._internal();
  factory GreetingService() => _instance;
  GreetingService._internal();

  final _random = Random();

  String getRandomGreeting() {
    final greetings = strings.AppStrings.greetings;
    return greetings[_random.nextInt(greetings.length)];
  }
}
