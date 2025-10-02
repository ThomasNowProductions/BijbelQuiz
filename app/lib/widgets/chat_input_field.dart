import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/logger.dart';
import '../theme/app_theme.dart';

/// Text input widget for user questions in the chat interface.
///
/// Features:
/// - Text input for user questions
/// - Send button with loading state
/// - Language selection (Dutch/English)
/// - Question type hints or suggestions
class ChatInputField extends StatefulWidget {
  /// Controller for the text input
  final TextEditingController controller;

  /// Callback when a message is sent
  final Function(String message) onSendMessage;

  /// Current loading state
  final bool isLoading;


  /// Maximum number of lines for the input field
  final int maxLines;

  /// Placeholder text for the input field
  final String? placeholder;

  /// Whether to show quick suggestion buttons
  final bool showSuggestions;

  const ChatInputField({
    super.key,
    required this.controller,
    required this.onSendMessage,
    required this.isLoading,
    this.maxLines = 5,
    this.placeholder,
    this.showSuggestions = true,
  });

  @override
  State<ChatInputField> createState() => _ChatInputFieldState();
}

class _ChatInputFieldState extends State<ChatInputField>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _pulseAnimation;

  bool _isComposing = false;
  final FocusNode _focusNode = FocusNode();
  String? _inputError;
  bool _showError = false;

  // Common Bible questions for suggestions
  final List<String> _dutchSuggestions = [
    'Wat zegt de Bijbel over vergeving?',
    'Leg de gelijkenis van de verloren zoon uit',
    'Wat is de betekenis van Johannes 3:16?',
    'Hoe kan ik bidden?',
    'Wat zegt de Bijbel over liefde?',
  ];


  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    widget.controller.addListener(_onTextChanged);

    _focusNode.addListener(() {
      if (_focusNode.hasFocus && !_animationController.isAnimating) {
        _animationController.repeat(reverse: true);
      } else if (!_focusNode.hasFocus) {
        _animationController.stop();
        _animationController.value = 0.0;
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _focusNode.dispose();
    widget.controller.removeListener(_onTextChanged);
    super.dispose();
  }

  void _onTextChanged() {
    final hasText = widget.controller.text.trim().isNotEmpty;
    if (hasText != _isComposing) {
      setState(() {
        _isComposing = hasText;
        // Clear error when user starts typing
        if (_showError && hasText) {
          _clearError();
        }
      });
    }
  }

  String? _validateInput(String text) {
    final trimmedText = text.trim();

    if (trimmedText.isEmpty) {
      return null; // No error for empty text, just disable sending
    }

    if (trimmedText.length > 1000) {
      return 'Bericht is te lang (maximaal 1000 tekens)';
    }

    if (trimmedText.length < 3) {
      return 'Bericht is te kort (minimaal 3 tekens)';
    }

    // Check for potentially inappropriate content
    final inappropriateWords = ['spam', 'test'];
    final lowerText = trimmedText.toLowerCase();
    if (inappropriateWords.any((word) => lowerText.contains(word))) {
      return 'Controleer je bericht op geschikte inhoud';
    }

    return null; // No errors
  }

  void _clearError() {
    setState(() {
      _inputError = null;
      _showError = false;
    });
  }

  void _showInputError(String error) {
    setState(() {
      _inputError = error;
      _showError = true;
    });
  }

  void _handleSendMessage() {
    final message = widget.controller.text.trim();
    if (message.isEmpty || widget.isLoading) return;

    // Validate input
    final validationError = _validateInput(message);
    if (validationError != null) {
      _showInputError(validationError);
      return;
    }

    // Clear any existing errors
    _clearError();

    AppLogger.info('Sending message: $message');
    widget.onSendMessage(message);
  }

  void _insertSuggestion(String suggestion) {
    widget.controller.text = suggestion;
    widget.controller.selection = TextSelection.fromPosition(
      TextPosition(offset: suggestion.length),
    );
    _focusNode.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final suggestions = _dutchSuggestions;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: colorScheme.outline.withAlpha((0.2 * 255).round()),
            width: 1,
          ),
        ),
      ),
      child: Column(
        children: [
          // Quick suggestions (when input is empty and not loading)
          if (widget.showSuggestions &&
              !widget.isLoading &&
              widget.controller.text.isEmpty) ...[
            _buildSuggestions(suggestions, colorScheme),
          ],

          // Error message display
          if (_showError && _inputError != null) ...[
            Container(
              margin: const EdgeInsets.only(left: 16, right: 16, bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: colorScheme.errorContainer,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: colorScheme.error.withAlpha((0.5 * 255).round()),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.warning_amber_rounded,
                    size: 16,
                    color: colorScheme.onErrorContainer,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _inputError!,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: colorScheme.onErrorContainer,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: _clearError,
                    icon: Icon(
                      Icons.close,
                      size: 16,
                      color: colorScheme.onErrorContainer,
                    ),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ),
          ],

          // Main input area
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [

                // Text input field
                Expanded(
                  child: AnimatedBuilder(
                    animation: _pulseAnimation,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _focusNode.hasFocus ? _pulseAnimation.value : 1.0,
                        child: Container(
                          decoration: BoxDecoration(
                            color: colorScheme.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                              color: _focusNode.hasFocus
                                ? colorScheme.primary
                                : colorScheme.outline.withAlpha((0.3 * 255).round()),
                              width: _focusNode.hasFocus ? 2 : 1,
                            ),
                            boxShadow: _focusNode.hasFocus
                              ? [
                                  BoxShadow(
                                    color: colorScheme.primary.withAlpha((0.1 * 255).round()),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ]
                              : null,
                          ),
                          child: TextField(
                            controller: widget.controller,
                            focusNode: _focusNode,
                            maxLines: widget.maxLines,
                            minLines: 1,
                            textCapitalization: TextCapitalization.sentences,
                            textInputAction: TextInputAction.send,
                            onSubmitted: (_) => _handleSendMessage(),
                            decoration: InputDecoration(
                              hintText: widget.placeholder ?? 'Stel een vraag over de Bijbel...',
                              hintStyle: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                color: colorScheme.onSurface.withAlpha((0.5 * 255).round()),
                              ),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              suffixIcon: _isComposing
                                ? IconButton(
                                    icon: Icon(
                                      Icons.send,
                                      color: colorScheme.primary,
                                    ),
                                    onPressed: _handleSendMessage,
                                  )
                                : Icon(
                                    Icons.mic,
                                    color: colorScheme.onSurface.withAlpha((0.5 * 255).round()),
                                  ),
                            ),
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: colorScheme.onSurface,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(width: 12),

                // Send button
                AnimatedScale(
                  scale: widget.isLoading ? 0.8 : 1.0,
                  duration: const Duration(milliseconds: 200),
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: (_isComposing && !widget.isLoading && !_showError)
                        ? colorScheme.primary
                        : (_showError ? colorScheme.errorContainer : colorScheme.surfaceContainerHighest),
                      border: Border.all(
                        color: (_isComposing && !widget.isLoading && !_showError)
                          ? colorScheme.primary
                          : (_showError ? colorScheme.error : colorScheme.outline.withAlpha((0.3 * 255).round())),
                      ),
                    ),
                    child: Material(
                       color: Colors.transparent,
                       child: InkWell(
                         borderRadius: BorderRadius.circular(24),
                         onTap: (widget.isLoading || (_showError && _inputError != null)) ? null : _handleSendMessage,
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 200),
                          child: widget.isLoading
                            ? SizedBox(
                                key: const ValueKey('loading'),
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    colorScheme.onPrimary,
                                  ),
                                ),
                              )
                            : Icon(
                                key: const ValueKey('send'),
                                Icons.send,
                                color: (_isComposing && !widget.isLoading && !_showError)
                                  ? colorScheme.onPrimary
                                  : (_showError ? colorScheme.onErrorContainer : colorScheme.onSurface.withAlpha((0.5 * 255).round())),
                                size: 20,
                              ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildSuggestions(List<String> suggestions, ColorScheme colorScheme) {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: suggestions.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ActionChip(
              label: Text(
                suggestions[index],
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSecondaryContainer,
                ),
              ),
              backgroundColor: colorScheme.secondaryContainer,
              onPressed: () => _insertSuggestion(suggestions[index]),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          );
        },
      ),
    );
  }
}