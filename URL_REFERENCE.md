# URL Reference Guide

This file contains all the URLs used in the BijbelQuiz app for easy reference and updates.

## Current URLs (bijbelquiz.app)

### Base Domain
- **Base Domain**: `https://bijbelquiz.app`
- **Homepage**: `https://bijbelquiz.app/`

### API Endpoints
- **API Base**: `https://bijbelquiz.app/api`
- **Emergency API**: `https://bijbelquiz.app/api/emergency`

### App-Specific URLs
- **Donate URL**: `https://bijbelquiz.app/donate.html`
- **Update URL**: `https://bijbelquiz.app/update.php`

## Legacy URLs (for reference)

### Old Base Domain
- **Old Base Domain**: `https://bijbelquiz.vercel.app`
- **Old Homepage**: `https://bijbelquiz.vercel.app/`

### Old API Endpoints
- **Old API Base**: `https://backendbijbelquiz.vercel.app/api`
- **Old Emergency API**: `https://backendbijbelquiz.vercel.app/api/emergency`

### Old App-Specific URLs
- **Old Donate URL**: `https://bijbelquiz.vercel.app/donate.html`
- **Old Update URL**: `https://bijbelquiz.vercel.app/update.php`

## Files Updated

The following files have been updated to use the new URLs:

### Flutter/Dart Files
- `lib/constants/urls.dart` - Central URL constants
- `lib/services/emergency_service.dart` - Uses AppUrls.apiBase
- `lib/screens/guide_screen.dart` - Uses AppUrls.donateUrl
- `lib/screens/feature_test_screen.dart` - Uses AppUrls.updateUrl and AppUrls.homepage
- `lib/settings_screen.dart` - Uses AppUrls.donateUrl

### Configuration Files
- `pubspec.yaml` - Updated homepage
- `web/index.html` - Updated meta tags
- `android/app/src/main/res/xml/network_security_config.xml` - Updated domain
- `LOCAL_DEVELOPMENT.md` - Updated documentation
- `EMERGENCY_SYSTEM.md` - Updated documentation

### Tools and Scripts
- `emergency_message_tool.py` - Updated API URL
- `test_emergency_api.js` - Updated API URL

## How to Update URLs

1. **For Dart files**: Update the constants in `lib/constants/urls.dart`
2. **For HTML files**: Manually update the hardcoded URLs
3. **For Python/JavaScript files**: Manually update the hardcoded URLs
4. **For configuration files**: Update as needed

## Migration Summary

- **Old Domain**: bijbelquiz.vercel.app → **New Domain**: bijbelquiz.app
- **Old API Domain**: backendbijbelquiz.vercel.app → **New API Domain**: bijbelquiz.app/api
- **Total files updated**: 11 files
- **URLs centralized**: Yes (for Dart files via constants)

This centralization makes future URL updates much easier - just change the constants in `lib/constants/urls.dart` and rebuild the app.