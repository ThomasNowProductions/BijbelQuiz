import 'package:flutter/material.dart';
import '../l10n/strings_nl.dart' as strings;
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
      title: Text(strings.AppStrings.breakReminderTitle),
      content: Text(strings.AppStrings.breakReminderMessage),
      actions: [
        TextButton(
          onPressed: () => _handleDismiss(context),
          child: Text(strings.AppStrings.breakReminderOk),
        ),
        TextButton(
          onPressed: () => _handleDismiss(context),
          child: Text(strings.AppStrings.breakReminderContinue),
        ),
      ],
    );
  }
}
