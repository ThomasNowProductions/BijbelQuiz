import 'dart:math';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:bijbelquiz/services/logger.dart';

class VersionInfo {
  final String latestVersion;
  final String linuxVersion;
  final String androidVersion;
  final String webVersion;

  VersionInfo({
    required this.latestVersion,
    required this.linuxVersion,
    required this.androidVersion,
    required this.webVersion,
  });

  factory VersionInfo.fromMetaTags(Map<String, String> metaTags) {
    return VersionInfo(
      latestVersion: metaTags['app-version'] ?? '',
      linuxVersion: metaTags['app-version-linux'] ?? '',
      androidVersion: metaTags['app-version-android'] ?? '',
      webVersion: metaTags['app-version-web'] ?? '',
    );
  }

  bool isUpdateAvailable(String currentVersion, String platform) {
    String latest;
    switch (platform) {
      case 'linux':
        latest = linuxVersion;
      case 'android':
        latest = androidVersion;
      case 'web':
        latest = webVersion;
      default:
        latest = latestVersion;
    }

    final result = _compareVersions(currentVersion, latest);
    AppLogger.debug(
        'Version check: current=$currentVersion, latest=$latest, update=$result');
    return result < 0;
  }

  int _compareVersions(String a, String b) {
    final aParts = a.split('.').map((e) => int.tryParse(e) ?? 0).toList();
    final bParts = b.split('.').map((e) => int.tryParse(e) ?? 0).toList();
    for (int i = 0; i < max(aParts.length, bParts.length); i++) {
      final aVal = i < aParts.length ? aParts[i] : 0;
      final bVal = i < bParts.length ? bParts[i] : 0;
      if (aVal < bVal) return -1;
      if (aVal > bVal) return 1;
    }
    return 0;
  }
}

class VersionCheckService {
  static const String _baseUrl = 'https://bijbelquiz.app';
  static const String _downloadPath = '/download.html';
  static const String _prefKeyUpdateDismissed = 'update_notification_dismissed';

  Future<VersionInfo?> checkForUpdates() async {
    try {
      AppLogger.debug('Fetching version info from $_baseUrl$_downloadPath');
      final response = await http
          .get(Uri.parse('$_baseUrl$_downloadPath'))
          .timeout(const Duration(seconds: 10));
      if (response.statusCode != 200) {
        AppLogger.error('Version check failed: HTTP ${response.statusCode}');
        return null;
      }

      final metaTags = _parseMetaTags(response.body);
      AppLogger.debug('Parsed meta tags: $metaTags');

      if (metaTags.isEmpty) {
        AppLogger.warning('No version meta tags found');
        return null;
      }

      return VersionInfo.fromMetaTags(metaTags);
    } catch (e) {
      AppLogger.error('Version check error', e);
      return null;
    }
  }

  Map<String, String> _parseMetaTags(String html) {
    final Map<String, String> tags = {};
    final regex =
        RegExp(r'<meta\s+name="app-version[^"]*"\s+content="([^"]+)"');
    final matches = regex.allMatches(html);
    for (final match in matches) {
      final fullMatch = match.group(0) ?? '';
      final nameMatch = RegExp(r'name="([^"]+)"').firstMatch(fullMatch);
      final contentMatch = RegExp(r'content="([^"]+)"').firstMatch(fullMatch);
      if (nameMatch != null && contentMatch != null) {
        tags[nameMatch.group(1)!] = contentMatch.group(1)!;
      }
    }
    return tags;
  }

  Future<bool> shouldShowUpdateNotification(String platform) async {
    AppLogger.debug(
        'Checking for updates on platform: $platform, isLinux: ${Platform.isLinux}, kIsWeb: $kIsWeb');

    if (!kIsWeb && !Platform.isLinux) {
      AppLogger.debug('Skipping update check - not Linux or web');
      return false;
    }

    final prefs = await SharedPreferences.getInstance();
    final dismissedVersion = prefs.getString(_prefKeyUpdateDismissed);

    final versionInfo = await checkForUpdates();
    if (versionInfo == null) return false;

    final packageInfo = await PackageInfo.fromPlatform();
    AppLogger.debug('Current app version: ${packageInfo.version}');

    final isUpdate =
        versionInfo.isUpdateAvailable(packageInfo.version, platform);
    AppLogger.debug('Update available: $isUpdate');

    if (isUpdate && dismissedVersion != packageInfo.version) {
      return true;
    }

    return false;
  }

  Future<void> dismissUpdateNotification() async {
    final prefs = await SharedPreferences.getInstance();
    final packageInfo = await PackageInfo.fromPlatform();
    await prefs.setString(_prefKeyUpdateDismissed, packageInfo.version);
  }
}
