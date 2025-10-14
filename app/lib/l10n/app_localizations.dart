import 'dart:async';
import 'package:flutter/material.dart';
import 'strings_en.dart' as strings_en;
import 'strings_nl.dart' as strings_nl;

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  dynamic get strings {
    switch (locale.languageCode) {
      case 'en':
        return strings_en.AppStrings;
      case 'nl':
        return strings_nl.AppStrings;
      default:
        return strings_en.AppStrings;
    }
  }
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['en', 'nl'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) {
    return Future.value(AppLocalizations(locale));
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
