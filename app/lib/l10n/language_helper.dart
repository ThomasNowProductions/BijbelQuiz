import 'strings_nl.dart' as strings_nl;
import 'strings_en.dart' as strings_en;

class LanguageHelper {
  static dynamic getStrings(String language) {
    switch (language) {
      case 'en':
        return strings_en.AppStrings;
      case 'nl':
      default:
        return strings_nl.AppStrings;
    }
  }
}