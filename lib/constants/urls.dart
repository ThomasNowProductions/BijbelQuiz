/// URL constants for the BijbelQuiz app
/// Central location for all URLs to make updates easier

class AppUrls {
  // Base domain
  static const String baseDomain = 'https://bijbelquiz.app';
  static const String baseDomainAPI = 'https://backend.bijbelquiz.app/api';

  // Homepage
  static const String homepage = '$baseDomain';

  // API endpoints
  static const String emergencyApi = '$baseDomainAPI/emergency.ts';

  // App-specific URLs
  static const String donateUrl = '$baseDomain/donate.html';
  static const String updateUrl = '$baseDomain/download.html';
}