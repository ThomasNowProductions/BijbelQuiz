import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/game_stats_provider.dart';
import '../providers/settings_provider.dart';
import '../services/coupon_service.dart';
import '../l10n/strings_nl.dart' as strings;
import '../theme/app_theme.dart';

class CouponRedeemScreen extends StatefulWidget {
  const CouponRedeemScreen({super.key});

  @override
  State<CouponRedeemScreen> createState() => _CouponRedeemScreenState();
}

class _CouponRedeemScreenState extends State<CouponRedeemScreen> {
  int _selectedIndex = 0; // 0 for Coupon code, 1 for QR-code

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.teal.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.confirmation_number_rounded,
                color: Colors.teal,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              strings.AppStrings.couponTitle,
              style: textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
                color: colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
        backgroundColor: colorScheme.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              // Tab selector
              Container(
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: colorScheme.outline.withValues(alpha: 0.2),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _selectedIndex = 0),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: _selectedIndex == 0
                                ? Colors.teal.withValues(alpha: 0.1)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Center(
                            child: Text(
                              strings.AppStrings.couponCodeLabel,
                              style: textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: _selectedIndex == 0
                                    ? Colors.teal
                                    : colorScheme.onSurface.withValues(alpha: 0.6),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _selectedIndex = 1),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: _selectedIndex == 1
                                ? Colors.teal.withValues(alpha: 0.1)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Center(
                            child: Text(
                              strings.AppStrings.qrCode,
                              style: textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: _selectedIndex == 1
                                    ? Colors.teal
                                    : colorScheme.onSurface.withValues(alpha: 0.6),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              // Content based on selection
              Expanded(
                child: _selectedIndex == 0
                    ? _buildCouponCodeView(context)
                    : _buildQRCodeView(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCouponCodeView(BuildContext context) {
    final controller = TextEditingController();
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          strings.AppStrings.couponDialogTitle,
          style: textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w700,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: controller,
          decoration: InputDecoration(
            labelText: strings.AppStrings.couponCodeLabel,
            hintText: strings.AppStrings.couponCodeHint,
            border: const OutlineInputBorder(),
          ),
          textCapitalization: TextCapitalization.characters,
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => Navigator.pop(context),
                child: Text(strings.AppStrings.cancel),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: FilledButton(
                onPressed: () {
                  if (controller.text.isNotEmpty) {
                    _redeemCoupon(controller.text.trim());
                  }
                },
                child: Text(strings.AppStrings.couponRedeem),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQRCodeView(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    // Check if platform is supported (Android or iOS)
    final isMobile = Theme.of(context).platform == TargetPlatform.android || 
                     Theme.of(context).platform == TargetPlatform.iOS;

    if (!isMobile) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.mobile_off_rounded,
              size: 64,
              color: colorScheme.onSurface.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 16),
            Text(
              strings.AppStrings.qrScannerMobileOnly,
              style: theme.textTheme.titleMedium?.copyWith(
                color: colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Stack(
        children: [
          MobileScanner(
            onDetect: (capture) {
              final List<Barcode> barcodes = capture.barcodes;
              for (final barcode in barcodes) {
                final String? code = barcode.rawValue;
                if (code != null) {
                  _handleScannedCode(code);
                  break; // Only handle the first valid code
                }
              }
            },
          ),
          // Overlay
          Container(
            decoration: BoxDecoration(
              border: Border.all(
                color: Colors.teal.withValues(alpha: 0.5),
                width: 2,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          // Scanner line animation or overlay could go here
          Center(
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.8),
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          Positioned(
            bottom: 16,
            left: 0,
            right: 0,
            child: Text(
              strings.AppStrings.qrCodeDescription,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.white,
                shadows: [
                  Shadow(
                    offset: const Offset(0, 1),
                    blurRadius: 3.0,
                    color: Colors.black.withValues(alpha: 0.5),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  bool _isScanning = true;

  void _handleScannedCode(String code) {
    if (!_isScanning) return;

    // Validate URL format: bijbelquiz.app?coupon=CODE
    final uri = Uri.tryParse(code);
    if (uri == null) return;

    // Check host (allow www. and without) and scheme
    final isValidHost = uri.host == 'bijbelquiz.app' || uri.host == 'www.bijbelquiz.app';
    if (!isValidHost) return;

    final couponCode = uri.queryParameters['coupon'];
    if (couponCode != null && couponCode.isNotEmpty) {
      setState(() {
        _isScanning = false;
      });
      _redeemCoupon(couponCode).then((_) {
        // Resume scanning after dialog is closed if needed, 
        // but usually we might want to stay on the success/error screen or go back.
        // For now, let's allow re-scanning if they stay on this tab.
        if (mounted) {
          setState(() {
            _isScanning = true;
          });
        }
      });
    }
  }

  Future<void> _redeemCoupon(String code) async {
    final localContext = context;

    // Anticheat checks
    final prefs = await SharedPreferences.getInstance();
    final normalizedCode = code.trim().toUpperCase();
    final redeemedCodes = prefs.getStringList('redeemed_coupons') ?? [];
    final today = DateTime.now().toIso8601String().substring(0, 10);
    final storedDate = prefs.getString('coupon_redemption_date') ?? '';
    int count = prefs.getInt('coupon_redemption_count') ?? 0;

    if (storedDate != today) {
      count = 0;
      await prefs.setString('coupon_redemption_date', today);
      await prefs.setInt('coupon_redemption_count', 0);
    }

    if (redeemedCodes.contains(normalizedCode)) {
      throw Exception('This coupon has already been redeemed');
    }

    if (count >= 5) {
      throw Exception('Maximum of 5 coupons can be redeemed per day');
    }

    // Show loading
    showDialog(
      context: localContext,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final couponService = CouponService();
      final reward = await couponService.redeemCoupon(code);

      // Apply reward
      if (!mounted) return;
      Navigator.pop(localContext); // Dismiss loading

      String message = '';
      if (reward.type == 'stars') {
        final amount = reward.value as int;
        Provider.of<GameStatsProvider>(localContext, listen: false).addStars(amount);
        message = strings.AppStrings.couponStarsReceived.replaceAll('{amount}', amount.toString());
      } else if (reward.type == 'theme') {
        final themeId = reward.value as String;
        await Provider.of<SettingsProvider>(localContext, listen: false).unlockTheme(themeId);
        message = strings.AppStrings.couponThemeUnlocked;
      }

      // Update anticheat data
      redeemedCodes.add(normalizedCode);
      await prefs.setStringList('redeemed_coupons', redeemedCodes);
      await prefs.setInt('coupon_redemption_count', count + 1);

      if (!mounted) return;
      showDialog(
        context: localContext,
        builder: (dialogContext) => AlertDialog(
          title: Text(strings.AppStrings.couponSuccessTitle),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.celebration, size: 48, color: Colors.orange),
              const SizedBox(height: 16),
              Text(message),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext); // Dismiss success dialog
                Navigator.pop(localContext); // Go back to store screen
              },
              child: Text(strings.AppStrings.ok),
            ),
          ],
        ),
      );
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(localContext); // Dismiss loading

      String errorMessage = e.toString();
      if (errorMessage.startsWith('Exception: ')) {
        errorMessage = errorMessage.substring(11);
      }

      showDialog(
        context: localContext,
        builder: (context) => AlertDialog(
          title: Text(strings.AppStrings.couponErrorTitle),
          content: Text(errorMessage),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(strings.AppStrings.ok),
            ),
          ],
        ),
      );
    }
  }
}