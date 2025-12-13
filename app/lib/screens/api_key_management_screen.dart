import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import '../models/api_key.dart';
import '../services/api_key_manager.dart';
import '../services/tracking_service.dart';
import '../widgets/top_snackbar.dart';
import '../l10n/strings_nl.dart' as strings;

/// Screen for managing API keys with full CRUD functionality
class ApiKeyManagementScreen extends StatefulWidget {
  const ApiKeyManagementScreen({super.key});

  @override
  State<ApiKeyManagementScreen> createState() => _ApiKeyManagementScreenState();
}

class _ApiKeyManagementScreenState extends State<ApiKeyManagementScreen> {
  final ApiKeyManager _apiKeyManager = ApiKeyManager();
  late Future<List<ApiKey>> _apiKeysFuture;
  final TextEditingController _nameController = TextEditingController();
  String? _selectedKeyId;

  @override
  void initState() {
    super.initState();
    _refreshApiKeys();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final trackingService = TrackingService();
      trackingService.screen(context, 'ApiKeyManagementScreen');
      trackingService.trackApiKeyManagementAccess(context);
    });
  }

  Future<void> _refreshApiKeys() async {
    _apiKeysFuture = _apiKeyManager.getAllApiKeys();
    await _apiKeysFuture; // Wait for the operation to complete
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _createNewApiKey() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      showTopSnackBar(context, 'Please enter a name for your API key', 
          style: TopSnackBarStyle.error);
      return;
    }

    try {
      final newKey = ApiKey(
        id: 'api_${DateTime.now().millisecondsSinceEpoch}',
        key: ApiKeyManager.generateApiKey(),
        name: name,
        createdAt: DateTime.now(),
      );

      final success = await _apiKeyManager.saveApiKey(newKey);
      if (success) {
        await _refreshApiKeys();
        setState(() {}); // Force rebuild to update the UI immediately
        _nameController.clear();
        TrackingService().trackApiKeyCreated(context);
        showTopSnackBar(context, strings.AppStrings.apiKeyCreatedSuccessfully,
            style: TopSnackBarStyle.success);
      } else {
        showTopSnackBar(context, strings.AppStrings.failedToCreateApiKey,
            style: TopSnackBarStyle.error);
      }
    } catch (e) {
      showTopSnackBar(context, 'Error creating API key: $e', 
          style: TopSnackBarStyle.error);
    }
  }

  Future<void> _renameApiKey(String id, String currentName) async {
    final newName = await showDialog<String>(
      context: context,
      builder: (ctx) {
        final controller = TextEditingController(text: currentName);
        return AlertDialog(
          title: Text(strings.AppStrings.renameApiKey),
          content: TextField(
            controller: controller,
            decoration: InputDecoration(hintText: strings.AppStrings.enterKeyName),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(strings.AppStrings.cancel),
            ),
            ElevatedButton(
              onPressed: () {
                if (controller.text.trim().isNotEmpty) {
                  Navigator.pop(ctx, controller.text.trim());
                }
              },
              child: Text(strings.AppStrings.ok),
            ),
          ],
        );
      },
    );

    if (newName != null && newName.isNotEmpty) {
      final apiKey = await _apiKeyManager.getApiKeyById(id);
      if (apiKey != null) {
        final updatedKey = apiKey.copyWith(name: newName);
        final success = await _apiKeyManager.updateApiKey(updatedKey);
        if (success) {
          await _refreshApiKeys();
          setState(() {}); // Force rebuild to update the UI immediately
          TrackingService().trackApiKeyEdited(context);
          showTopSnackBar(context, strings.AppStrings.apiKeyRenamedSuccessfully,
              style: TopSnackBarStyle.success);
        } else {
          showTopSnackBar(context, strings.AppStrings.failedToRenameApiKey,
              style: TopSnackBarStyle.error);
        }
      }
    }
  }

  Future<void> _revokeApiKey(String id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(strings.AppStrings.revokeApiKey),
        content: Text(strings.AppStrings.revokeApiKeyMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(strings.AppStrings.revoke),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final success = await _apiKeyManager.revokeApiKey(id);
      if (success) {
        await _refreshApiKeys();
        setState(() {}); // Force rebuild to update the UI immediately
        TrackingService().trackApiKeyRevoked(context);
        showTopSnackBar(context, strings.AppStrings.apiKeyRevokedSuccessfully,
            style: TopSnackBarStyle.success);
      } else {
        showTopSnackBar(context, strings.AppStrings.failedToRevokeApiKey,
            style: TopSnackBarStyle.error);
      }
    }
  }

  Future<void> _activateApiKey(String id) async {
    final success = await _apiKeyManager.activateApiKey(id);
    if (success) {
      await _refreshApiKeys();
      setState(() {}); // Force rebuild to update the UI immediately
      TrackingService().trackApiKeyActivated(context);
      showTopSnackBar(context, strings.AppStrings.apiKeyActivatedSuccessfully,
          style: TopSnackBarStyle.success);
    } else {
      showTopSnackBar(context, strings.AppStrings.failedToActivateApiKey,
          style: TopSnackBarStyle.error);
    }
  }

  Future<void> _deleteApiKey(String id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(strings.AppStrings.deleteApiKey),
        content: Text(strings.AppStrings.deleteApiKeyMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(strings.AppStrings.delete),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final success = await _apiKeyManager.deleteApiKey(id);
      if (success) {
        await _refreshApiKeys();
        setState(() {}); // Force rebuild to update the UI immediately
        TrackingService().trackApiKeyDeleted(context);
        showTopSnackBar(context, strings.AppStrings.apiKeyDeletedSuccessfully,
            style: TopSnackBarStyle.success);
      } else {
        showTopSnackBar(context, strings.AppStrings.failedToDeleteApiKey,
            style: TopSnackBarStyle.error);
      }
    }
  }

  Future<void> _copyApiKeyToClipboard(String key) async {
    await Clipboard.setData(ClipboardData(text: key));
    TrackingService().trackApiKeyCopied(context);
    showTopSnackBar(context, strings.AppStrings.apiKeyCopiedToClipboard,
        style: TopSnackBarStyle.success);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'API Key Management',
          style: textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
            color: colorScheme.onSurface,
          ),
        ),
        backgroundColor: colorScheme.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Create new API key section
            Card(
              elevation: 0,
              color: colorScheme.surfaceContainerHighest,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      strings.AppStrings.createNewApiKey,
                      style: textTheme.headlineMedium?.copyWith(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: strings.AppStrings.keyName,
                        hintText: strings.AppStrings.enterKeyName,
                        border: const OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Align(
                      alignment: Alignment.centerRight,
                      child: ElevatedButton.icon(
                        onPressed: _createNewApiKey,
                        icon: const Icon(Icons.add),
                        label: Text(strings.AppStrings.createNewApiKey),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colorScheme.primary,
                          foregroundColor: colorScheme.onPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // API Keys list header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  strings.AppStrings.apiKeyManagement,
                  style: textTheme.headlineMedium?.copyWith(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                FutureBuilder<List<ApiKey>>(
                  future: _apiKeysFuture,
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      final count = snapshot.data!.length;
                      return Text(
                        '$count ${count == 1 ? strings.AppStrings.apiKey : strings.AppStrings.apiKeys}',
                        style: textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      );
                    }
                    return const Text('');
                  },
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            // API Keys list
            Expanded(
              child: FutureBuilder<List<ApiKey>>(
                future: _apiKeysFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  
                  if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        'Error loading API keys: ${snapshot.error}',
                        style: textTheme.bodyMedium?.copyWith(
                          color: colorScheme.error,
                        ),
                      ),
                    );
                  }
                  
                  final apiKeys = snapshot.data ?? [];
                  
                  if (apiKeys.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.key_off_outlined,
                            size: 64,
                            color: colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            strings.AppStrings.noApiKeysCreated,
                            style: textTheme.bodyLarge,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            strings.AppStrings.createFirstApiKey,
                            style: textTheme.bodyMedium?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                  
                  return RefreshIndicator(
                    onRefresh: () async {
                      _refreshApiKeys();
                      setState(() {}); // Trigger rebuild
                    },
                    child: ListView.separated(
                      itemCount: apiKeys.length,
                      separatorBuilder: (context, index) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final key = apiKeys[index];
                        return _buildApiKeyCard(key);
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildApiKeyCard(ApiKey key) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Card(
      elevation: 0,
      color: colorScheme.surfaceContainerHighest,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: key.isActive 
              ? colorScheme.primary.withValues(alpha: 0.3) 
              : colorScheme.error.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Key name and status
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    key.name,
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: key.isActive 
                        ? colorScheme.primaryContainer 
                        : colorScheme.errorContainer,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    key.isActive ? 'Active' : 'Revoked',
                    style: TextStyle(
                      color: key.isActive 
                          ? colorScheme.primary 
                          : colorScheme.onErrorContainer,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 8),
            
            // Key value
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerLow,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: SelectableText(
                      key.maskedKey,
                      style: textTheme.bodyMedium?.copyWith(
                        fontFamily: 'monospace',
                        fontSize: 12,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.copy,
                      size: 18,
                      color: colorScheme.primary,
                    ),
                    onPressed: () => _copyApiKeyToClipboard(key.key),
                    tooltip: 'Copy API key',
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 12),
            
            // Metadata
            Wrap(
              spacing: 16,
              children: [
                _buildMetadataChip(
                  Icons.date_range,
                  '${strings.AppStrings.apiKeyCreatedOn} ${_formatDate(key.createdAt)}',
                  colorScheme,
                ),
                if (key.lastUsedAt != null)
                  _buildMetadataChip(
                    Icons.access_time,
                    '${strings.AppStrings.lastUsed} ${_formatDate(key.lastUsedAt!)}',
                    colorScheme,
                  ),
                _buildMetadataChip(
                  Icons.http,
                  '${key.requestCount} ${strings.AppStrings.requests}',
                  colorScheme,
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Action buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _renameApiKey(key.id, key.name),
                    icon: Icon(
                      Icons.edit,
                      size: 16,
                      color: colorScheme.onSurfaceVariant,
                    ),
                    label: Text(
                      strings.AppStrings.rename,
                      style: TextStyle(color: colorScheme.onSurfaceVariant),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                if (key.isActive)
                  Expanded(
                    flex: 1,
                    child: OutlinedButton.icon(
                      onPressed: () => _revokeApiKey(key.id),
                      icon: Icon(
                        Icons.block,
                        size: 16,
                        color: colorScheme.error,
                      ),
                      label: Text(
                        strings.AppStrings.revoke,
                        style: TextStyle(color: colorScheme.error),
                      ),
                    ),
                  )
                else
                  Expanded(
                    flex: 1,
                    child: OutlinedButton.icon(
                      onPressed: () => _activateApiKey(key.id),
                      icon: Icon(
                        Icons.check_circle,
                        size: 16,
                        color: colorScheme.primary,
                      ),
                      label: Text(
                        strings.AppStrings.activate,
                        style: TextStyle(color: colorScheme.primary),
                      ),
                    ),
                  ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 1,
                  child: OutlinedButton.icon(
                    onPressed: () => _deleteApiKey(key.id),
                    icon: Icon(
                      Icons.delete,
                      size: 16,
                      color: colorScheme.error,
                    ),
                    label: Text(
                      strings.AppStrings.delete,
                      style: TextStyle(color: colorScheme.error),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetadataChip(IconData icon, String text, ColorScheme colorScheme) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 14,
          color: colorScheme.onSurfaceVariant,
        ),
        const SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(
            fontSize: 12,
            color: colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}