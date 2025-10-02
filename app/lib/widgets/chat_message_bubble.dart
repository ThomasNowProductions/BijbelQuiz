import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:intl/intl.dart';
import '../models/bible_chat_message.dart';
import '../models/bible_reference.dart';
import '../services/logger.dart';
import '../theme/app_theme.dart';

/// Individual message display widget for chat interface.
///
/// Features:
/// - Different styles for user vs bot messages
/// - Support for Bible references and rich text
/// - Timestamp display
/// - Copy/share functionality
class ChatMessageBubble extends StatefulWidget {
  /// The message to display
  final BibleChatMessage message;

  /// Callback when a Bible reference is tapped
  final Function(String reference)? onBibleReferenceTap;

  /// Callback when the message is long-pressed for copy/share
  final VoidCallback? onLongPress;

  /// Whether to show the timestamp
  final bool showTimestamp;

  /// Whether to show the avatar
  final bool showAvatar;

  /// Whether this message represents an error state
  final bool isError;

  const ChatMessageBubble({
    super.key,
    required this.message,
    this.onBibleReferenceTap,
    this.onLongPress,
    this.showTimestamp = true,
    this.showAvatar = true,
    this.isError = false,
  });

  @override
  State<ChatMessageBubble> createState() => _ChatMessageBubbleState();
}

class _ChatMessageBubbleState extends State<ChatMessageBubble>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.elasticOut),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant ChatMessageBubble oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.message.id != widget.message.id) {
      _animationController.reset();
      _animationController.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isUser = widget.message.sender == MessageSender.user;
    final isDark = colorScheme.brightness == Brightness.dark;

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Opacity(
          opacity: _fadeAnimation.value,
          child: Transform.scale(
            scale: _scaleAnimation.value,
            child: _buildMessageRow(isUser, colorScheme, isDark),
          ),
        );
      },
    );
  }

  Widget _buildMessageRow(bool isUser, ColorScheme colorScheme, bool isDark) {
    return Row(
      mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (!isUser && widget.showAvatar) ...[
          _buildAvatar(isUser, colorScheme),
          const SizedBox(width: 12),
        ],
        Flexible(
          child: Column(
            crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: [
              if (!isUser) _buildBotLabel(colorScheme),
              const SizedBox(height: 4),
              _buildMessageBubble(isUser, colorScheme, isDark),
              if (widget.showTimestamp) ...[
                const SizedBox(height: 4),
                _buildTimestamp(colorScheme),
              ],
            ],
          ),
        ),
        if (isUser && widget.showAvatar) ...[
          const SizedBox(width: 12),
          _buildAvatar(isUser, colorScheme),
        ],
      ],
    );
  }

  Widget _buildAvatar(bool isUser, ColorScheme colorScheme) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: widget.isError
          ? LinearGradient(
              colors: [
                colorScheme.errorContainer,
                colorScheme.errorContainer.withAlpha((0.8 * 255).round()),
              ],
            )
          : (isUser
              ? LinearGradient(
                  colors: [
                    colorScheme.primary,
                    colorScheme.primary.withAlpha((0.8 * 255).round()),
                  ],
                )
              : LinearGradient(
                  colors: [
                    colorScheme.secondaryContainer,
                    colorScheme.secondaryContainer.withAlpha((0.8 * 255).round()),
                  ],
                )),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withAlpha((0.1 * 255).round()),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Icon(
        widget.isError ? Icons.error : (isUser ? Icons.person : Icons.smart_toy),
        color: widget.isError
          ? colorScheme.onErrorContainer
          : (isUser ? colorScheme.onPrimary : colorScheme.onSecondaryContainer),
        size: 20,
      ),
    );
  }

  Widget _buildBotLabel(ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: widget.isError
          ? colorScheme.errorContainer.withAlpha((0.7 * 255).round())
          : colorScheme.primaryContainer.withAlpha((0.5 * 255).round()),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        widget.isError ? 'Error' : 'Bible Bot',
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: widget.isError
            ? colorScheme.onErrorContainer
            : colorScheme.onPrimaryContainer,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildMessageBubble(bool isUser, ColorScheme colorScheme, bool isDark) {
    return GestureDetector(
      onLongPress: widget.onLongPress ?? () => _showMessageOptions(context, isUser),
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: widget.isError
            ? colorScheme.errorContainer
            : (isUser ? colorScheme.primary : colorScheme.surfaceContainerHighest),
          borderRadius: BorderRadius.circular(20).copyWith(
            bottomLeft: isUser ? const Radius.circular(20) : const Radius.circular(4),
            bottomRight: isUser ? const Radius.circular(4) : const Radius.circular(20),
          ),
          border: widget.isError
            ? Border.all(
                color: colorScheme.error.withAlpha((0.5 * 255).round()),
                width: 1,
              )
            : null,
          boxShadow: widget.isError
            ? [
                BoxShadow(
                  color: colorScheme.error.withAlpha((0.1 * 255).round()),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ]
            : [
                BoxShadow(
                  color: colorScheme.shadow.withAlpha((0.08 * 255).round()),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildMessageContent(isUser, colorScheme),
            if (widget.message.bibleReferences != null &&
                widget.message.bibleReferences!.isNotEmpty) ...[
              const SizedBox(height: 12),
              _buildBibleReferences(colorScheme),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildMessageContent(bool isUser, ColorScheme colorScheme) {
    final textColor = widget.isError
      ? colorScheme.onErrorContainer
      : (isUser ? colorScheme.onPrimary : colorScheme.onSurface);

    final content = widget.isError
      ? 'Sorry, I encountered an error while processing your question. Please try again.'
      : widget.message.content;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.isError) ...[
          Icon(
            Icons.error_outline,
            size: 18,
            color: colorScheme.onErrorContainer,
          ),
          const SizedBox(width: 8),
        ],
        Expanded(
          child: widget.isError
            ? Text(
                content,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: textColor,
                  height: 1.4,
                  letterSpacing: 0.1,
                ),
              )
            : _buildMarkdownContent(content, textColor),
        ),
      ],
    );
  }

  Widget _buildMarkdownContent(String content, Color textColor) {
    try {
      return MarkdownBody(
        data: content,
        styleSheet: _getMarkdownStyleSheet(textColor),
        onTapLink: (text, href, title) {
          // Handle link taps if needed
          if (href != null) {
            AppLogger.info('Link tapped: $href');
            // You could add URL launcher functionality here if needed
          }
        },
        selectable: true,
      );
    } catch (e) {
      // Fallback to plain text if markdown parsing fails
      AppLogger.warning('Markdown parsing failed, falling back to plain text: $e');
      return Text(
        content,
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
          color: textColor,
          height: 1.4,
          letterSpacing: 0.1,
        ),
      );
    }
  }

  MarkdownStyleSheet _getMarkdownStyleSheet(Color textColor) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return MarkdownStyleSheet(
      p: textTheme.bodyLarge?.copyWith(
        color: textColor,
        height: 1.4,
        letterSpacing: 0.1,
      ),
      h1: textTheme.headlineSmall?.copyWith(
        color: textColor,
        fontWeight: FontWeight.bold,
        height: 1.3,
      ),
      h2: textTheme.titleLarge?.copyWith(
        color: textColor,
        fontWeight: FontWeight.bold,
        height: 1.3,
      ),
      h3: textTheme.titleMedium?.copyWith(
        color: textColor,
        fontWeight: FontWeight.bold,
        height: 1.3,
      ),
      strong: textTheme.bodyLarge?.copyWith(
        color: textColor,
        fontWeight: FontWeight.bold,
      ),
      em: textTheme.bodyLarge?.copyWith(
        color: textColor,
        fontStyle: FontStyle.italic,
      ),
      code: textTheme.bodyMedium?.copyWith(
        color: textColor,
        backgroundColor: colorScheme.surfaceContainerHighest.withAlpha((0.5 * 255).round()),
        fontFamily: 'monospace',
      ),
      blockquote: textTheme.bodyLarge?.copyWith(
        color: textColor.withAlpha((0.8 * 255).round()),
        height: 1.4,
      ),
      blockquoteDecoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withAlpha((0.3 * 255).round()),
        border: Border(
          left: BorderSide(
            color: colorScheme.outline.withAlpha((0.5 * 255).round()),
            width: 4,
          ),
        ),
      ),
      listBullet: textTheme.bodyLarge?.copyWith(
        color: textColor,
      ),
      horizontalRuleDecoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: colorScheme.outline.withAlpha((0.3 * 255).round()),
            width: 1,
          ),
        ),
      ),
    );
  }

  Widget _buildBibleReferences(ColorScheme colorScheme) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: widget.message.bibleReferences!.map((reference) {
        return InkWell(
          onTap: () => widget.onBibleReferenceTap?.call(reference),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: colorScheme.outline.withAlpha((0.3 * 255).round()),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.menu_book,
                  size: 16,
                  color: colorScheme.onPrimaryContainer,
                ),
                const SizedBox(width: 6),
                Text(
                  reference,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: colorScheme.onPrimaryContainer,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildTimestamp(ColorScheme colorScheme) {
    final timestamp = DateFormat('HH:mm').format(widget.message.timestamp);

    return Text(
      timestamp,
      style: Theme.of(context).textTheme.bodySmall?.copyWith(
        color: colorScheme.onSurface.withAlpha((0.6 * 255).round()),
        fontSize: 11,
      ),
    );
  }

  void _showMessageOptions(BuildContext context, bool isUser) {
    final colorScheme = Theme.of(context).colorScheme;

    showModalBottomSheet(
      context: context,
      backgroundColor: colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: colorScheme.outline.withAlpha((0.3 * 255).round()),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              ListTile(
                leading: Icon(
                  Icons.copy,
                  color: colorScheme.onSurface,
                ),
                title: Text(
                  'Copy message',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: colorScheme.onSurface,
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _copyMessageToClipboard();
                },
              ),
              if (widget.message.bibleReferences != null &&
                  widget.message.bibleReferences!.isNotEmpty) ...[
                ListTile(
                  leading: Icon(
                    Icons.share,
                    color: colorScheme.onSurface,
                  ),
                  title: Text(
                    'Share references',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: colorScheme.onSurface,
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    _shareBibleReferences();
                  },
                ),
              ],
              ListTile(
                leading: Icon(
                  Icons.flag,
                  color: colorScheme.onSurface,
                ),
                title: Text(
                  'Report issue',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: colorScheme.onSurface,
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _reportIssue();
                },
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  void _copyMessageToClipboard() async {
    await Clipboard.setData(ClipboardData(text: widget.message.content));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Message copied to clipboard'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    }
  }

  void _shareBibleReferences() {
    if (widget.message.bibleReferences == null) return;

    final referencesText = widget.message.bibleReferences!.join(', ');
    final shareText = 'Bible references from chat: $referencesText\n\n${widget.message.content}';

    // In a real implementation, you would use share_plus package or similar
    AppLogger.info('Sharing Bible references: $shareText');

    // For now, just copy to clipboard
    Clipboard.setData(ClipboardData(text: shareText));

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Bible references copied to clipboard'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    }
  }

  void _reportIssue() {
    // In a real implementation, you would show a dialog or navigate to a feedback screen
    AppLogger.info('Reporting issue with message: ${widget.message.id}');

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Thank you for your feedback. Issue reported.'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    }
  }
}