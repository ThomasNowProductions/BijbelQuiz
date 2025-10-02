import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/bible_chat_conversation.dart';
import '../providers/bible_chat_provider.dart';
import '../services/logger.dart';

/// Screen for displaying conversation history and management
class ConversationHistoryScreen extends StatefulWidget {
  const ConversationHistoryScreen({super.key});

  @override
  State<ConversationHistoryScreen> createState() => _ConversationHistoryScreenState();
}

class _ConversationHistoryScreenState extends State<ConversationHistoryScreen> {
  BibleChatProvider? _chatProvider;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _chatProvider = Provider.of<BibleChatProvider>(context, listen: false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Conversation History'),
        backgroundColor: Theme.of(context).colorScheme.surface,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
        elevation: 0,
      ),
      body: Consumer<BibleChatProvider>(
        builder: (context, chatProvider, child) {
          if (chatProvider.isLoading) {
            return _buildLoadingView();
          }

          final conversations = chatProvider.activeConversations;

          if (conversations.isEmpty) {
            return _buildEmptyView();
          }

          return _buildConversationsList(conversations);
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _createNewConversation,
        tooltip: 'Start New Conversation',
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildLoadingView() {
    return Container(
      color: Theme.of(context).colorScheme.surface,
      child: const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  Widget _buildEmptyView() {
    return Container(
      color: Theme.of(context).colorScheme.surface,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.chat_bubble_outline,
              size: 80,
              color: Theme.of(context).colorScheme.outline.withAlpha((0.5 * 255).round()),
            ),
            const SizedBox(height: 24),
            Text(
              'No conversations yet',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withAlpha((0.7 * 255).round()),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Start a new conversation to begin chatting with the Bible bot',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withAlpha((0.6 * 255).round()),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildConversationsList(List<BibleChatConversation> conversations) {
    return Container(
      color: Theme.of(context).colorScheme.surface,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: conversations.length,
        itemBuilder: (context, index) {
          final conversation = conversations[index];
          return _buildConversationCard(conversation);
        },
      ),
    );
  }

  Widget _buildConversationCard(BibleChatConversation conversation) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _openConversation(conversation),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          conversation.title ?? 'Untitled Conversation',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${conversation.messageCount} messages • ${_formatDuration(conversation.duration)}',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurface.withAlpha((0.6 * 255).round()),
                          ),
                        ),
                      ],
                    ),
                  ),
                  PopupMenuButton<String>(
                    onSelected: (value) => _handleConversationAction(value, conversation),
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'delete',
                        child: Text('Delete'),
                      ),
                    ],
                    child: Icon(
                      Icons.more_vert,
                      color: colorScheme.onSurface.withAlpha((0.6 * 255).round()),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Started ${_formatDateTime(conversation.startTime)}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurface.withAlpha((0.5 * 255).round()),
                ),
              ),
              if (conversation.lastActivity != conversation.startTime) ...[
                const SizedBox(height: 4),
                Text(
                  'Last activity ${_formatDateTime(conversation.lastActivity)}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurface.withAlpha((0.5 * 255).round()),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays == 0) {
      return 'today at ${_formatTime(dateTime)}';
    } else if (difference.inDays == 1) {
      return 'yesterday at ${_formatTime(dateTime)}';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago at ${_formatTime(dateTime)}';
    } else {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year} at ${_formatTime(dateTime)}';
    }
  }

  String _formatTime(DateTime dateTime) {
    return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  String _formatDuration(Duration duration) {
    if (duration.inMinutes < 1) {
      return '< 1 min';
    } else if (duration.inHours < 1) {
      return '${duration.inMinutes} min';
    } else if (duration.inDays < 1) {
      return '${duration.inHours} hour${duration.inHours > 1 ? 's' : ''}';
    } else {
      return '${duration.inDays} day${duration.inDays > 1 ? 's' : ''}';
    }
  }

  Future<void> _createNewConversation() async {
    if (_chatProvider == null) return;

    try {
      final conversation = await _chatProvider!.createConversation(
        title: 'Nieuwe Conversatie',
      );

      if (mounted) {
        Navigator.of(context).pop(conversation);
      }
    } catch (e) {
      AppLogger.error('Failed to create new conversation', e);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to create conversation: ${e.toString()}'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  void _openConversation(BibleChatConversation conversation) {
    Navigator.of(context).pop(conversation);
  }

  Future<void> _handleConversationAction(String action, BibleChatConversation conversation) async {
    if (_chatProvider == null) return;

    switch (action) {
      case 'delete':
        final confirmed = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Delete Conversation'),
            content: Text('Are you sure you want to delete "${conversation.title ?? 'this conversation'}"? This action cannot be undone.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: TextButton.styleFrom(
                  foregroundColor: Theme.of(context).colorScheme.error,
                ),
                child: const Text('Delete'),
              ),
            ],
          ),
        );

        if (confirmed == true) {
          try {
            await _chatProvider!.deleteConversation(conversation.id);
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Conversation deleted'),
                ),
              );
            }
          } catch (e) {
            AppLogger.error('Failed to delete conversation', e);
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Failed to delete conversation: ${e.toString()}'),
                  backgroundColor: Theme.of(context).colorScheme.error,
                ),
              );
            }
          }
        }
        break;
    }
  }
}