import 'package:flutter/material.dart';
import 'package:bijbelquiz/l10n/strings_nl.dart' as strings;

class SocialSettingsScreen extends StatefulWidget {
  const SocialSettingsScreen({super.key});

  @override
  _SocialSettingsScreenState createState() => _SocialSettingsScreenState();
}

class _SocialSettingsScreenState extends State<SocialSettingsScreen> {
  String _profileVisibility = 'private';
  bool _realTimeSyncEnabled = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(strings.AppStrings.socialSettings),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            DropdownButtonFormField<String>(
              value: _profileVisibility,
              items: [
                DropdownMenuItem(
                  value: 'private',
                  child: Text(strings.AppStrings.profileVisibilityPrivate),
                ),
                DropdownMenuItem(
                  value: 'mutual',
                  child: Text(strings.AppStrings.profileVisibilityMutual),
                ),
                DropdownMenuItem(
                  value: 'public',
                  child: Text(strings.AppStrings.profileVisibilityPublic),
                ),
              ],
              onChanged: (value) {
                setState(() {
                  _profileVisibility = value!;
                });
                // TODO: Implement API call to update profile visibility
              },
              decoration: InputDecoration(
                labelText: strings.AppStrings.profileVisibility,
              ),
            ),
            const SizedBox(height: 20),
            SwitchListTile(
              title: Text(strings.AppStrings.realTimeSync),
              value: _realTimeSyncEnabled,
              onChanged: (value) {
                setState(() {
                  _realTimeSyncEnabled = value;
                });
                // TODO: Implement API call to update real-time sync
              },
            ),
          ],
        ),
      ),
    );
  }
}
