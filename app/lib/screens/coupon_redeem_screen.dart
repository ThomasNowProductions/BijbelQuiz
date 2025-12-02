import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:math';
import '../providers/game_stats_provider.dart';
import '../providers/settings_provider.dart';
import '../services/coupon_service.dart';
import '../l10n/strings_nl.dart' as strings;
import '../utils/theme_utils.dart';
import '../widgets/common_widgets.dart';

class CouponRedeemScreen extends StatefulWidget {
  const CouponRedeemScreen({super.key});

  @override
  State<CouponRedeemScreen> createState() => _CouponRedeemScreenState();
}

class _CouponRedeemScreenState extends State<CouponRedeemScreen> with SingleTickerProviderStateMixin {
  int _selectedIndex = 0; // 0 for Coupon code, 1 for QR-code
  DateTime? _lastScanTime;
  String? _lastProcessedCode;
  bool _isScanning = true;
  bool _hasCameraPermission = false;
  bool _isPermissionDialogOpen = false;
  bool _showPermissionRationale = false;
  bool _isInitializing = true;
  final bool _showScannerTutorial = false;
  bool _isProcessing = false;

  // Animation controllers
  late AnimationController _scanLineController;
  late Animation<double> _scanLineAnimation;
  late AnimationController _successAnimationController;
  late Animation<double> _successAnimation;
  late AnimationController _errorAnimationController;
  late Animation<double> _errorAnimation;

  // Scanner performance metrics
  int _scanAttempts = 0;
  int _successfulScans = 0;
  DateTime? _lastPerformanceReset;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _checkCameraPermission();
    _initializePerformanceTracking();
  }

  @override
  void dispose() {
    _scanLineController.dispose();
    _successAnimationController.dispose();
    _errorAnimationController.dispose();
    super.dispose();
  }

  void _initializeAnimations() {
    // Scan line animation (moving line)
    _scanLineController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _scanLineAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _scanLineController,
        curve: Curves.easeInOut,
      ),
    );

    // Success animation
    _successAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _successAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _successAnimationController,
        curve: Curves.easeInOut,
      ),
    );

    // Error animation
    _errorAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _errorAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _errorAnimationController,
        curve: Curves.easeInOut,
      ),
    );
  }

  void _initializePerformanceTracking() {
    _lastPerformanceReset = DateTime.now();
    // Reset metrics if it's been more than 24 hours
    if (_scanAttempts > 1000) {
      _scanAttempts = 0;
      _successfulScans = 0;
    }
  }

  Future<void> _checkCameraPermission() async {
    try {
      // Check if we're on a mobile platform
      final isMobile = Theme.of(context).platform == TargetPlatform.android ||
                       Theme.of(context).platform == TargetPlatform.iOS;

      if (!isMobile) {
        setState(() {
          _hasCameraPermission = false;
          _isInitializing = false;
        });
        return;
      }

      // Check current permission status
      final status = await Permission.camera.status;

      if (status.isGranted) {
        setState(() {
          _hasCameraPermission = true;
          _isInitializing = false;
        });
      } else if (status.isPermanentlyDenied) {
        setState(() {
          _hasCameraPermission = false;
          _isInitializing = false;
          _showPermissionRationale = true;
        });
      } else {
        // Request permission
        final result = await Permission.camera.request();
        setState(() {
          _hasCameraPermission = result.isGranted;
          _isInitializing = false;
          _showPermissionRationale = result.isPermanentlyDenied;
        });
      }
    } catch (e) {
      setState(() {
        _hasCameraPermission = false;
        _isInitializing = false;
      });
    }
  }

  Future<void> _requestCameraPermissionWithRationale() async {
    if (_isPermissionDialogOpen) return;

    setState(() {
      _isPermissionDialogOpen = true;
    });

    try {
      final result = await Permission.camera.request();
      setState(() {
        _hasCameraPermission = result.isGranted;
        _showPermissionRationale = result.isPermanentlyDenied;
        _isPermissionDialogOpen = false;
      });

      if (result.isGranted && mounted) {
        setState(() {
          _selectedIndex = 1; // Switch to QR tab
        });
      }
    } catch (e) {
      setState(() {
        _isPermissionDialogOpen = false;
      });
    }
  }

  void _showPermissionSettingsDialog() {
    if (_isPermissionDialogOpen) return;

    setState(() {
      _isPermissionDialogOpen = true;
    });

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(strings.AppStrings.permissionDenied),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(strings.AppStrings.qrCode),
            const SizedBox(height: 8),
            Text(
              'Camera toegang is vereist om QR-codes te scannen. Je kunt dit inschakelen in de app-instellingen.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                _isPermissionDialogOpen = false;
              });
              Navigator.pop(context);
            },
            child: Text(strings.AppStrings.cancel),
          ),
          TextButton(
            onPressed: () async {
              setState(() {
                _isPermissionDialogOpen = false;
              });
              Navigator.pop(context);
              await openAppSettings();
            },
            child: Text(strings.AppStrings.openStatusPage),
          ),
        ],
      ),
    ).then((_) {
      setState(() {
        _isPermissionDialogOpen = false;
      });
    });
  }

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
                        onTap: () {
                          if (_hasCameraPermission) {
                            setState(() => _selectedIndex = 1);
                          } else {
                            _requestCameraPermissionWithRationale();
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: _selectedIndex == 1
                                ? Colors.teal.withValues(alpha: 0.1)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Center(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  strings.AppStrings.qrCode,
                                  style: textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: _selectedIndex == 1
                                        ? Colors.teal
                                        : colorScheme.onSurface.withValues(alpha: 0.6),
                                  ),
                                ),
                                if (!_hasCameraPermission) ...[
                                  const SizedBox(width: 4),
                                  Icon(
                                    Icons.lock_rounded,
                                    size: 14,
                                    color: colorScheme.onSurface.withValues(alpha: 0.6),
                                  ),
                                ],
                              ],
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

    if (_isInitializing) {
      return const Center(child: CircularProgressIndicator());
    }

    if (!_hasCameraPermission) {
      return _buildPermissionRequestView(context);
    }

    return _buildScannerView(context);
  }

  Widget _buildPermissionRequestView(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.camera_alt_rounded,
            size: 64,
            color: colorScheme.primary,
          ),
          const SizedBox(height: 24),
          Text(
            'Camera toegang vereist',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              'Om QR-codes te kunnen scannen, heeft de app toegang nodig tot je camera. Deze toestemming wordt alleen gebruikt voor het scannen van coupons.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
          ),
          const SizedBox(height: 32),
          FilledButton(
            onPressed: _requestCameraPermissionWithRationale,
            child: const Text('Camera toestemming verlenen'),
          ),
          if (_showPermissionRationale) ...[
            const SizedBox(height: 16),
            TextButton(
              onPressed: _showPermissionSettingsDialog,
              child: Text(
                'Instellingen openen',
                style: TextStyle(color: colorScheme.primary),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildScannerView(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width < 400;

    // Calculate scanner size based on screen dimensions
    final scannerSize = min(screenSize.width * 0.8, screenSize.height * 0.4);

    return Stack(
      children: [
        // Camera preview
        Positioned.fill(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: MobileScanner(
              controller: MobileScannerController(
                detectionSpeed: DetectionSpeed.normal,
                facing: CameraFacing.back,
                torchEnabled: false,
                returnImage: false,
              ),
              onDetect: (capture) => _handleBarcodeDetection(capture),
              errorBuilder: (context, error, child) {
                return _buildScannerErrorView(context, error);
              },
              placeholderBuilder: (context, child) {
                return _buildScannerPlaceholderView(context, child);
              },
            ),
          ),
        ),

        // Scanner overlay with animated scan line
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(
                color: Colors.teal.withValues(alpha: 0.5),
                width: 2,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Stack(
              children: [
                // Semi-transparent overlay with cutout
                Center(
                  child: Container(
                    width: scannerSize,
                    height: scannerSize,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.8),
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Stack(
                      children: [
                        // Corner decorations
                        Positioned(
                          top: 0,
                          left: 0,
                          child: Container(
                            width: 30,
                            height: 30,
                            decoration: BoxDecoration(
                              border: Border(
                                top: BorderSide(
                                  color: Colors.teal,
                                  width: 3,
                                ),
                                left: BorderSide(
                                  color: Colors.teal,
                                  width: 3,
                                ),
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          top: 0,
                          right: 0,
                          child: Container(
                            width: 30,
                            height: 30,
                            decoration: BoxDecoration(
                              border: Border(
                                top: BorderSide(
                                  color: Colors.teal,
                                  width: 3,
                                ),
                                right: BorderSide(
                                  color: Colors.teal,
                                  width: 3,
                                ),
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          left: 0,
                          child: Container(
                            width: 30,
                            height: 30,
                            decoration: BoxDecoration(
                              border: Border(
                                bottom: BorderSide(
                                  color: Colors.teal,
                                  width: 3,
                                ),
                                left: BorderSide(
                                  color: Colors.teal,
                                  width: 3,
                                ),
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            width: 30,
                            height: 30,
                            decoration: BoxDecoration(
                              border: Border(
                                bottom: BorderSide(
                                  color: Colors.teal,
                                  width: 3,
                                ),
                                right: BorderSide(
                                  color: Colors.teal,
                                  width: 3,
                                ),
                              ),
                            ),
                          ),
                        ),

                        // Animated scan line
                        Positioned(
                          top: _scanLineAnimation.value * (scannerSize - 4),
                          left: 2,
                          right: 2,
                          child: Container(
                            height: 2,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.transparent,
                                  Colors.teal.withValues(alpha: 0.8),
                                  Colors.transparent,
                                ],
                                stops: const [0.0, 0.5, 1.0],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Instructions
                Positioned(
                  bottom: 16,
                  left: 0,
                  right: 0,
                  child: Column(
                    children: [
                      Text(
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
                      const SizedBox(height: 8),
                      if (_showScannerTutorial)
                        Text(
                          'Houd de QR-code binnen het kader voor automatische detectie',
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.white.withValues(alpha: 0.8),
                            shadows: [
                              Shadow(
                                offset: const Offset(0, 1),
                                blurRadius: 2.0,
                                color: Colors.black.withValues(alpha: 0.5),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),

                // Flashlight toggle (for future implementation)
                Positioned(
                  top: 16,
                  right: 16,
                  child: IconButton(
                    icon: Icon(
                      Icons.flash_off_rounded,
                      color: Colors.white.withValues(alpha: 0.8),
                      size: 24,
                    ),
                    onPressed: () {
                      // TODO: Implement flashlight toggle
                    },
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.black.withValues(alpha: 0.3),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        // Performance indicator (for debugging)
        if (false) // Set to true for debugging
          Positioned(
            top: 16,
            left: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Scans: $_scanAttempts | Success: $_successfulScans',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: Colors.white,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildScannerErrorView(BuildContext context, Object error) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline_rounded,
            size: 48,
            color: colorScheme.error,
          ),
          const SizedBox(height: 16),
          Text(
            'Camera fout',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              'Er is een fout opgetreden bij het initialiseren van de camera: ${error.toString()}',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
          ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: () {
              setState(() {
                _isInitializing = true;
              });
              _checkCameraPermission();
            },
            child: const Text('Opnieuw proberen'),
          ),
        ],
      ),
    );
  }

  Widget _buildScannerPlaceholderView(BuildContext context, Widget? child) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text(
            'Camera initialiseren...',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }

  void _handleBarcodeDetection(BarcodeCapture capture) {
    if (!_isScanning || _isProcessing) return;

    _scanAttempts++;

    final List<Barcode> barcodes = capture.barcodes;
    for (final barcode in barcodes) {
      final String? code = barcode.rawValue;
      if (code != null && code.isNotEmpty) {
        _handleScannedCode(code);
        break; // Only handle the first valid code
      }
    }
  }

  void _handleScannedCode(String code) {
    if (!_isScanning || _isProcessing) return;

    // Debouncing: prevent rapid successive scans
    final now = DateTime.now();
    if (_lastScanTime != null && now.difference(_lastScanTime!) < const Duration(seconds: 2)) {
      return;
    }
    if (code == _lastProcessedCode) return;

    _lastScanTime = now;
    _lastProcessedCode = code;
    _isProcessing = true;

    // Validate URL format: bijbelquiz.app?coupon=CODE
    String urlToParse = code;
    if (!urlToParse.contains('://')) {
      urlToParse = 'https://$urlToParse';
    }

    final uri = Uri.tryParse(urlToParse);
    if (uri == null) {
      _showInvalidQRMessage();
      _isProcessing = false;
      return;
    }

    // Check host (allow www. and without)
    final isValidHost = uri.host == 'bijbelquiz.app' || uri.host == 'www.bijbelquiz.app';
    if (!isValidHost) {
      _showInvalidQRMessage();
      _isProcessing = false;
      return;
    }

    final couponCode = uri.queryParameters['coupon'];
    if (couponCode != null && couponCode.isNotEmpty) {
      setState(() {
        _isScanning = false;
      });

      _redeemCoupon(couponCode).then((_) {
        _successfulScans++;
        if (mounted) {
          setState(() {
            _isScanning = true;
            _isProcessing = false;
          });
        }
      }).catchError((_) {
        if (mounted) {
          setState(() {
            _isScanning = true;
            _isProcessing = false;
          });
        }
      });
    } else {
      _showInvalidQRMessage();
      _isProcessing = false;
    }
  }

  void _showInvalidQRMessage() {
    if (!mounted) return;

    // Trigger error animation
    _errorAnimationController.forward().then((_) {
      _errorAnimationController.reverse();
    });

    _showResultDialog(context, strings.AppStrings.invalidQRCode, isSuccess: false);
  }

  void _showResultDialog(BuildContext context, String message, {bool isSuccess = true, VoidCallback? onDismiss}) {
    if (isSuccess) {
      // Trigger success animation
      _successAnimationController.forward().then((_) {
        _successAnimationController.reverse();
      });
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        insetPadding: EdgeInsets.zero,
        child: Container(
          width: double.infinity,
          height: double.infinity,
          color: Theme.of(context).colorScheme.surface,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (isSuccess)
                  Icon(
                    Icons.check_circle,
                    size: 64,
                    color: Colors.green,
                  )
                else
                  Icon(
                    Icons.error,
                    size: 64,
                    color: Colors.red,
                  ),
                const SizedBox(height: 16),
                Text(
                  message,
                  style: Theme.of(context).textTheme.headlineSmall,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    onDismiss?.call();
                  },
                  child: const Text('OK'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
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
      if (!mounted) return;
      _showResultDialog(localContext, strings.AppStrings.couponAlreadyRedeemed, isSuccess: false);
      return;
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
      _showResultDialog(localContext, message, isSuccess: true, onDismiss: () => Navigator.pop(localContext));
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(localContext); // Dismiss loading

      String errorMessage = e.toString();
      if (errorMessage.startsWith('Exception: ')) {
        errorMessage = errorMessage.substring(11);
      }

      // Map to localized messages
      if (errorMessage == 'Invalid coupon code') {
        errorMessage = strings.AppStrings.couponInvalid;
      } else if (errorMessage == 'This coupon has expired') {
        errorMessage = strings.AppStrings.couponExpired;
      } else if (errorMessage == 'This coupon is no longer valid (maximum uses reached)') {
        errorMessage = strings.AppStrings.couponMaxUsed;
      } else if (errorMessage == 'This coupon has already been redeemed') {
        errorMessage = strings.AppStrings.couponAlreadyRedeemed;
      } else if (errorMessage == 'Maximum of 5 coupons can be redeemed per day') {
        errorMessage = strings.AppStrings.couponMaxPerDay;
      }

      _showResultDialog(localContext, errorMessage, isSuccess: false, onDismiss: () {
        if (mounted) {
          setState(() {
            _isScanning = true;
          });
        }
      });
    }
  }
}