import 'package:flutter/material.dart';

import '../l10n/strings_nl.dart' as strings;

class PromoCard extends StatefulWidget {
  final bool isDonation;
  final bool isSatisfaction;
  final bool isDifficulty;
  final bool isAccountCreation;
  final String? socialMediaType;
  final VoidCallback onDismiss;
  final Function(String) onAction;
  final VoidCallback? onView;

  const PromoCard({
    super.key,
    required this.isDonation,
    required this.isSatisfaction,
    required this.isDifficulty,
    required this.isAccountCreation,
    this.socialMediaType,
    required this.onDismiss,
    required this.onAction,
    this.onView,
  });

  @override
  State<PromoCard> createState() => _PromoCardState();
}

class _PromoCardState extends State<PromoCard> {
  @override
  void initState() {
    super.initState();
    // Trigger view callback when card is first displayed
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.onView != null) {
        widget.onView!();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    List<Color> gradientColors;
    if (widget.isDonation) {
      gradientColors = [
        cs.primary.withValues(alpha: 0.14),
        cs.primary.withValues(alpha: 0.06)
      ];
    } else if (widget.isSatisfaction) {
      gradientColors = [
        cs.primary.withValues(alpha: 0.14),
        cs.primary.withValues(alpha: 0.06)
      ];
    } else if (widget.isDifficulty) {
      gradientColors = [
        cs.primary.withValues(alpha: 0.14),
        cs.primary.withValues(alpha: 0.06)
      ];
    } else if (widget.isAccountCreation) {
      gradientColors = [
        cs.primary.withValues(alpha: 0.14),
        cs.primary.withValues(alpha: 0.06)
      ];
    } else if (widget.socialMediaType != null) {
      gradientColors = [
        cs.primary.withValues(alpha: 0.14),
        cs.primary.withValues(alpha: 0.06)
      ];
    } else {
      gradientColors = [
        cs.primary.withValues(alpha: 0.14),
        cs.primary.withValues(alpha: 0.06)
      ];
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradientColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: cs.outlineVariant.withValues(alpha: 0.8),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: cs.shadow.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                widget.isDonation
                    ? Icons.favorite_rounded
                    : widget.isSatisfaction
                        ? Icons.feedback_rounded
                        : widget.isDifficulty
                            ? Icons.tune_rounded
                            : widget.isAccountCreation
                                ? Icons.person_add_rounded
                                : widget.socialMediaType == 'mastodon'
                                    ? Icons.alternate_email
                                    : widget.socialMediaType == 'pixelfed'
                                        ? Icons.camera_alt
                                        : widget.socialMediaType == 'kwebler'
                                            ? Icons.group
                                            : widget.socialMediaType == 'signal'
                                                ? Icons.message
                                                : widget.socialMediaType ==
                                                        'discord'
                                                    ? Icons.discord
                                                    : widget.socialMediaType ==
                                                            'bluesky'
                                                        ? Icons.cloud
                                                        : widget.socialMediaType ==
                                                                'nooki'
                                                            ? Icons.group
                                                            : Icons
                                                                .group_add_rounded,
                color: cs.onSurface.withValues(alpha: 0.7),
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  widget.isDonation
                      ? strings.AppStrings.donate
                      : widget.isSatisfaction
                          ? strings.AppStrings.satisfactionSurvey
                          : widget.isDifficulty
                              ? strings.AppStrings.difficultyFeedbackTitle
                              : widget.isAccountCreation
                                  ? strings.AppStrings.createAccount
                                  : widget.socialMediaType == 'mastodon'
                                      ? strings.AppStrings.followMastodon
                                      : widget.socialMediaType == 'pixelfed'
                                          ? strings.AppStrings.followPixelfed
                                          : widget.socialMediaType == 'kwebler'
                                              ? strings.AppStrings.followKwebler
                                              : widget.socialMediaType == 'signal'
                                                  ? strings.AppStrings.followSignal
                                                  : widget.socialMediaType ==
                                                          'discord'
                                                      ? strings
                                                          .AppStrings.followDiscord
                                                      : widget.socialMediaType ==
                                                              'bluesky'
                                                          ? strings.AppStrings
                                                              .followBluesky
                                                          : widget.socialMediaType ==
                                                                  'nooki'
                                                              ? strings.AppStrings
                                                                  .followNooki
                                                              : strings.AppStrings
                                                                  .followUs,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: cs.onSurface,
                      ),
                ),
              ),
              IconButton(
                onPressed: widget.onDismiss,
                icon: Icon(Icons.close,
                    color: cs.onSurface.withValues(alpha: 0.6)),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            widget.isDonation
                ? strings.AppStrings.donateExplanation
                : widget.isSatisfaction
                    ? strings.AppStrings.satisfactionSurveyMessage
                    : widget.isDifficulty
                        ? strings.AppStrings.difficultyFeedbackMessage
                        : widget.isAccountCreation
                            ? strings.AppStrings.createAccountMessage
                            : strings.AppStrings.followUsMessage,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 12),
          if (widget.isDonation) ...[
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => widget.onAction(''),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: cs.primary,
                      foregroundColor: cs.onPrimary,
                      minimumSize: const Size.fromHeight(44),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    icon: const Icon(Icons.favorite_rounded),
                    label: Text(strings.AppStrings.donateButton),
                  ),
                ),
              ],
            ),
          ] else if (widget.isSatisfaction) ...[
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => widget.onAction(''),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: cs.primary,
                      foregroundColor: cs.onPrimary,
                      minimumSize: const Size.fromHeight(44),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    icon: const Icon(Icons.feedback_rounded),
                    label: Text(strings.AppStrings.satisfactionSurveyButton),
                  ),
                ),
              ],
            ),
          ] else if (widget.isDifficulty) ...[
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => widget.onAction('too_hard'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: cs.primary,
                      foregroundColor: cs.onPrimary,
                      minimumSize: const Size.fromHeight(44),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text(strings.AppStrings.difficultyTooHard),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => widget.onAction('good'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: cs.primary,
                      foregroundColor: cs.onPrimary,
                      minimumSize: const Size.fromHeight(44),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text(strings.AppStrings.difficultyGood),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => widget.onAction('too_easy'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: cs.primary,
                      foregroundColor: cs.onPrimary,
                      minimumSize: const Size.fromHeight(44),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text(strings.AppStrings.difficultyTooEasy),
                  ),
                ),
              ],
            ),
          ] else if (widget.isAccountCreation) ...[
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => widget.onAction('create_account'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: cs.primary,
                      foregroundColor: cs.onPrimary,
                      minimumSize: const Size.fromHeight(44),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    icon: const Icon(Icons.person_add_rounded),
                    label: Text(strings.AppStrings.createAccountButton),
                  ),
                ),
              ],
            ),
          ] else if (widget.socialMediaType != null) ...[
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => widget.onAction('https://bijbelquiz.app/links'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: cs.primary,
                      foregroundColor: cs.onPrimary,
                      minimumSize: const Size.fromHeight(44),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    icon: const Icon(Icons.group_add_rounded),
                    label: Text(strings.AppStrings.followUs),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

