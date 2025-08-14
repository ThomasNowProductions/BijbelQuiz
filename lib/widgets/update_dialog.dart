import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/update_service.dart';
import '../widgets/top_snackbar.dart';
import '../l10n/strings_nl.dart' as strings;

class UpdateDialog extends StatelessWidget {
  final UpdateInfo updateInfo;
  
  const UpdateDialog({super.key, required this.updateInfo});
  
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return AlertDialog(
      title: Row(
        children: [
          Icon(Icons.system_update, color: colorScheme.primary),
          const SizedBox(width: 12),
          Text(
            'Update Beschikbaar',
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Er is een nieuwe versie van BijbelQuiz beschikbaar!',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            _buildVersionInfo(context, 'Huidige versie:', updateInfo.currentVersion),
            _buildVersionInfo(context, 'Nieuwe versie:', updateInfo.newVersion),
            const SizedBox(height: 16),
            Text(
              'Wat is er nieuw:',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                updateInfo.releaseNotes,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Later'),
        ),
        FilledButton(
          onPressed: () => _downloadUpdate(context),
          child: const Text('Download Nu'),
        ),
      ],
    );
  }
  
  Widget _buildVersionInfo(BuildContext context, String label, String value) {
    return Row(
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
  
  void _downloadUpdate(BuildContext context) async {
    final url = Uri.parse(
      'https://bijbelquiz.vercel.app/download_update.html?'
      'platform=${updateInfo.platform}'
      '&current=${updateInfo.currentVersion}'
    );
    
    if (await launchUrl(url)) {
      if (context.mounted) {
        Navigator.of(context).pop();
      }
    } else {
      if (context.mounted) {
        Navigator.of(context).pop();
        showTopSnackBar(
          context,
          strings.AppStrings.couldNotOpenDownloadPage,
          style: TopSnackBarStyle.error,
        );
      }
    }
  }
}