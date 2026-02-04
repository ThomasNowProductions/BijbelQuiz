import 'package:flutter/material.dart';
import 'package:bijbelquiz/l10n/app_localizations.dart';

class AppConfig {
  // App Identity - these need to be accessed via context
  static String appName(BuildContext context) =>
      AppLocalizations.of(context)!.appName;
  static String appDescription(BuildContext context) =>
      AppLocalizations.of(context)!.appDescription;
  static const String packageName = 'app.bijbelquiz.play';
  static const String iosBundleId = 'app.bijbelquiz.play';
}
