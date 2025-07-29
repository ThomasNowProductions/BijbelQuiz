import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/quiz_question.dart';
import '../theme/app_theme.dart';
import 'answer_button.dart';

class QuestionCard extends StatelessWidget {
  final QuizQuestion question;
  final int? selectedAnswerIndex;
  final bool isAnswering;
  final bool isTransitioning;
  final Function(int) onAnswerSelected;
  final String language;

  const QuestionCard({
    super.key,
    required this.question,
    required this.selectedAnswerIndex,
    required this.isAnswering,
    required this.isTransitioning,
    required this.onAnswerSelected,
    required this.language,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final size = MediaQuery.of(context).size;
    final isDesktop = size.width > 800;

    Widget content;
    switch (question.type) {
      case QuestionType.mc:
        final options = question.allOptions;
        final correctIndex = options.indexOf(question.correctAnswer);
        content = Container(
          margin: EdgeInsets.symmetric(horizontal: isDesktop ? 20 : 16),
          child: Column(
            children: [
              // Enhanced question card with professional design
              Container(
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: colorScheme.outline.withAlpha((0.1 * 255).round()),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: colorScheme.shadow.withAlpha((0.08 * 255).round()),
                      blurRadius: 24,
                      offset: const Offset(0, 8),
                      spreadRadius: 0,
                    ),
                    BoxShadow(
                      color: colorScheme.shadow.withAlpha((0.04 * 255).round()),
                      blurRadius: 48,
                      offset: const Offset(0, 16),
                      spreadRadius: 0,
                    ),
                  ],
                ),
                child: Padding(
                  padding: EdgeInsets.all(isDesktop ? 28.0 : 28.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Question text with enhanced typography
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: isDesktop ? 12 : 8),
                        child: Text(
                          question.question,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: colorScheme.onSurface,
                            height: 1.5,
                            letterSpacing: -0.2,
                            fontSize: getResponsiveFontSize(context, 24),
                          ),
                          semanticsLabel: question.question,
                        ),
                      ),
                      SizedBox(height: isDesktop ? 36 : 32),
                      // Answer options with improved spacing
                      ...List.generate(
                        options.length,
                        (index) {
                          AnswerFeedback feedback = AnswerFeedback.none;
                          if (selectedAnswerIndex != null) {
                            if (index == selectedAnswerIndex && index == correctIndex) {
                              feedback = AnswerFeedback.correct;
                            } else if (index == selectedAnswerIndex && index != correctIndex) {
                              feedback = AnswerFeedback.incorrect;
                            } else if (index == correctIndex) {
                              feedback = AnswerFeedback.revealedCorrect;
                            }
                          }
                          return Padding(
                            padding: EdgeInsets.only(bottom: isDesktop ? 14.0 : 12.0),
                            child: AnswerButton(
                              onPressed: isAnswering || selectedAnswerIndex != null ? null : () => onAnswerSelected(index),
                              feedback: feedback,
                              label: options[index],
                              colorScheme: colorScheme,
                              letter: String.fromCharCode(65 + index),
                              isDisabled: isAnswering || selectedAnswerIndex != null,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
        break;
      case QuestionType.fitb:
        final options = question.allOptions;
        final correctIndex = options.indexOf(question.correctAnswer);
        content = Container(
          margin: EdgeInsets.symmetric(horizontal: isDesktop ? 20 : 16),
          child: Column(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: colorScheme.outline.withAlpha((0.1 * 255).round()),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: colorScheme.shadow.withAlpha((0.08 * 255).round()),
                      blurRadius: 24,
                      offset: const Offset(0, 8),
                      spreadRadius: 0,
                    ),
                    BoxShadow(
                      color: colorScheme.shadow.withAlpha((0.04 * 255).round()),
                      blurRadius: 48,
                      offset: const Offset(0, 16),
                      spreadRadius: 0,
                    ),
                  ],
                ),
                child: Padding(
                  padding: EdgeInsets.all(isDesktop ? 28.0 : 28.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Animated blank in question (like MC question text)
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: isDesktop ? 12 : 8),
                        child: _FitbAnimatedBlankRow(
                          question: question,
                          options: options,
                          selectedAnswerIndex: selectedAnswerIndex,
                          isAnswering: isAnswering,
                          onAnswerSelected: onAnswerSelected,
                          colorScheme: colorScheme,
                          isDesktop: isDesktop,
                        ),
                      ),
                      SizedBox(height: isDesktop ? 36 : 32),
                      // Answer options with improved spacing (like MC)
                      ...List.generate(
                        options.length,
                        (index) {
                          AnswerFeedback feedback = AnswerFeedback.none;
                          if (selectedAnswerIndex != null) {
                            if (index == selectedAnswerIndex && index == correctIndex) {
                              feedback = AnswerFeedback.correct;
                            } else if (index == selectedAnswerIndex && index != correctIndex) {
                              feedback = AnswerFeedback.incorrect;
                            } else if (index == correctIndex) {
                              feedback = AnswerFeedback.revealedCorrect;
                            }
                          }
                          return Padding(
                            padding: EdgeInsets.only(bottom: isDesktop ? 14.0 : 12.0),
                            child: AnswerButton(
                              onPressed: isAnswering || selectedAnswerIndex != null ? null : () => onAnswerSelected(index),
                              feedback: feedback,
                              label: options[index],
                              colorScheme: colorScheme,
                              letter: null,
                              isDisabled: isAnswering || selectedAnswerIndex != null,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
        break;
      case QuestionType.tf:
        final tfOptions = [
          'Goed',
          'Fout',
        ];
        final correctIndex = question.correctAnswer.toLowerCase() == 'goed' ? 0 : 1;
        content = Container(
          margin: EdgeInsets.symmetric(horizontal: isDesktop ? 20 : 16),
          child: Column(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: colorScheme.outline.withAlpha((0.1 * 255).round()),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: colorScheme.shadow.withAlpha((0.08 * 255).round()),
                      blurRadius: 24,
                      offset: const Offset(0, 8),
                      spreadRadius: 0,
                    ),
                    BoxShadow(
                      color: colorScheme.shadow.withAlpha((0.04 * 255).round()),
                      blurRadius: 48,
                      offset: const Offset(0, 16),
                      spreadRadius: 0,
                    ),
                  ],
                ),
                child: Padding(
                  padding: EdgeInsets.all(isDesktop ? 28.0 : 28.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: isDesktop ? 12 : 8),
                        child: Text(
                          question.question,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: colorScheme.onSurface,
                            height: 1.5,
                            letterSpacing: -0.2,
                            fontSize: getResponsiveFontSize(context, 28),
                          ),
                          semanticsLabel: question.question,
                        ),
                      ),
                      SizedBox(height: isDesktop ? 48 : 36),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(2, (index) {
                          AnswerFeedback feedback = AnswerFeedback.none;
                          if (selectedAnswerIndex != null) {
                            if (index == selectedAnswerIndex && index == correctIndex) {
                              feedback = AnswerFeedback.correct;
                            } else if (index == selectedAnswerIndex && index != correctIndex) {
                              feedback = AnswerFeedback.incorrect;
                            } else if (index == correctIndex) {
                              feedback = AnswerFeedback.revealedCorrect;
                            }
                          }
                          return Expanded(
                            child: Padding(
                              padding: EdgeInsets.symmetric(horizontal: 8.0),
                              child: AnswerButton(
                                onPressed: isAnswering || selectedAnswerIndex != null ? null : () => onAnswerSelected(index),
                                feedback: feedback,
                                label: tfOptions[index],
                                colorScheme: colorScheme,
                                letter: null,
                                isLarge: true,
                                isDisabled: isAnswering || selectedAnswerIndex != null,
                              ),
                            ),
                          );
                        }),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
        break;
      // Add more cases for other question types here
    }

    if (isDesktop) {
      // Only MC supports keyboard shortcuts for now
      if (question.type == QuestionType.mc) {
        final options = question.allOptions;
        content = Focus(
          autofocus: true,
          onKeyEvent: (FocusNode node, KeyEvent event) {
            if (event is KeyDownEvent && !isAnswering && !isTransitioning) {
              String key = event.logicalKey.keyLabel.toLowerCase();
              if (key == 'a' && options.isNotEmpty) {
                onAnswerSelected(0);
                return KeyEventResult.handled;
              } else if (key == 'b' && options.length > 1) {
                onAnswerSelected(1);
                return KeyEventResult.handled;
              } else if (key == 'c' && options.length > 2) {
                onAnswerSelected(2);
                return KeyEventResult.handled;
              } else if (key == 'd' && options.length > 3) {
                onAnswerSelected(3);
                return KeyEventResult.handled;
              }
            }
            return KeyEventResult.ignored;
          },
          child: content,
        );
      }
    }

    return content;
  }
}

class _FitbAnimatedBlankRow extends StatefulWidget {
  final QuizQuestion question;
  final List<String> options;
  final int? selectedAnswerIndex;
  final bool isAnswering;
  final Function(int) onAnswerSelected;
  final ColorScheme colorScheme;
  final bool isDesktop;

  const _FitbAnimatedBlankRow({
    required this.question,
    required this.options,
    required this.selectedAnswerIndex,
    required this.isAnswering,
    required this.onAnswerSelected,
    required this.colorScheme,
    required this.isDesktop,
  });

  @override
  State<_FitbAnimatedBlankRow> createState() => _FitbAnimatedBlankRowState();
}

class _FitbAnimatedBlankRowState extends State<_FitbAnimatedBlankRow> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final blankColor = widget.selectedAnswerIndex == null
        ? widget.colorScheme.outlineVariant
        : (widget.selectedAnswerIndex != null && widget.options[widget.selectedAnswerIndex!] == widget.question.correctAnswer)
            ? const Color(0xFF10B981)
            : const Color(0xFFEF4444);
    final blankBorder = Border.all(
      color: blankColor,
      width: 3,
    );
    final blankText = widget.selectedAnswerIndex == null
        ? '______'
        : widget.options[widget.selectedAnswerIndex!];
    // Handle both '...' and '_____' as blank indicators
    final questionText = widget.question.question;
    final hasEllipsis = questionText.contains('...');
    final hasUnderscore = questionText.contains('_____');
    
    // If using ellipsis, replace them with underscores for consistent processing
    final processedText = hasEllipsis 
        ? questionText.replaceAll('...', '_____')
        : questionText;
        
    final questionParts = processedText.split('_____');
    final hasBlank = hasEllipsis || hasUnderscore;
    
    // If no blanks found, just return the question text
    if (!hasBlank) {
      return Text(
        questionText,
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
          fontWeight: FontWeight.w600,
          color: widget.colorScheme.onSurface,
          height: 1.5,
          letterSpacing: -0.2,
          fontSize: getResponsiveFontSize(context, 24),
        ),
      );
    }

    // Build a list of widgets for each part of the question
    final List<Widget> children = [];
    
    for (int i = 0; i < questionParts.length; i++) {
      // Add the text part
      if (questionParts[i].isNotEmpty) {
        children.add(
          Text(
            questionParts[i],
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: widget.colorScheme.onSurface,
              height: 1.5,
              letterSpacing: -0.2,
              fontSize: getResponsiveFontSize(context, 24),
            ),
          ),
        );
      }
      
      // Add the blank if we're not at the last part
      if (i < questionParts.length - 1) {
        children.add(
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 600),
            transitionBuilder: (child, anim) {
              return ScaleTransition(scale: anim, child: child);
            },
            child: Container(
              key: ValueKey('blank_$i'),
              margin: const EdgeInsets.symmetric(horizontal: 8),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
              decoration: BoxDecoration(
                color: blankColor.withValues(alpha: (0.08 * 255)),
                borderRadius: BorderRadius.circular(12),
                border: blankBorder,
              ),
              child: Text(
                i == 0 ? blankText : '______', // Only show selected answer in first blank for now
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: i == 0 ? blankColor : widget.colorScheme.outlineVariant,
                  fontSize: getResponsiveFontSize(context, 24),
                ),
              ),
            ),
          ),
        );
      }
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: Wrap(
        alignment: WrapAlignment.center,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: children,
      ),
    );
  }
} 