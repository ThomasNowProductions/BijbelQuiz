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
            strings.AppStrings.updateAvailable,
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
              strings.AppStrings.newVersionAvailable,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            _buildVersionInfo(context, strings.AppStrings.currentVersion, updateInfo.currentVersion),
            _buildVersionInfo(context, strings.AppStrings.newVersion, updateInfo.newVersion),
            const SizedBox(height: 16),
            Text(
              strings.AppStrings.whatsNew,
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
          child: Text(strings.AppStrings.later),
        ),
        FilledButton(
          onPressed: () => _downloadUpdate(context),
          child: Text(strings.AppStrings.downloadNow),
        ),
      ],
    );
  }
  
  Widget _buildVersionInfo(BuildContext context, String label, String value) {
    return Row(
      children: [
        Text(
          '$label: ',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
          ),
        ),
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
    final updateService = UpdateService();
    final url = Uri.parse(
      updateService.getDownloadPageUrl(
        platform: updateInfo.platform,
        currentVersion: updateInfo.currentVersion,
      )
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