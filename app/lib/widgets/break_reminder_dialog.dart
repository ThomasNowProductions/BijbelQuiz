import 'package:flutter/material.dart';
import 'package:bijbelquiz/l10n/app_localizations.dart';
import '../services/break_reminder_service.dart';

class BreakReminderDialog extends StatelessWidget {
  const BreakReminderDialog({super.key});

  void _handleDismiss(BuildContext context) {
    if (!context.mounted) return;
    try {
      BreakReminderService.instance.markBreakShown();
      Navigator.of(context).pop();
    } catch (e) {
      debugPrint('Error dismissing break reminder dialog: $e');
      if (context.mounted) {
        Navigator.of(context).pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(AppLocalizations.of(context)!.breakReminderTitle),
      content: Text(AppLocalizations.of(context)!.breakReminderMessage),
      actions: [
        TextButton(
          onPressed: () => _handleDismiss(context),
          child: Text(AppLocalizations.of(context)!.breakReminderOk),
        ),
        TextButton(
          onPressed: () => _handleDismiss(context),
          child: Text(AppLocalizations.of(context)!.breakReminderContinue),
        ),
      ],
    );
  }
}
