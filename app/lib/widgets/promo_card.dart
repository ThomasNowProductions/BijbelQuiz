import 'package:flutter/material.dart';

import 'package:bijbelquiz/l10n/app_localizations.dart';

class PromoCard extends StatefulWidget {
  final bool isDonation;
  final bool isSatisfaction;
  final bool isDifficulty;
  final bool isAccountCreation;
  final bool isReferral;
  final bool isShareStats;
  final bool isUpdate;
  final bool isStatus;
  final bool isDismissible;
  final String? socialMediaType;
  final String? statusTitle;
  final String? statusMessage;
  final String? statusImpactText;
  final VoidCallback onDismiss;
  final Function(String) onAction;
  final VoidCallback? onView;

  const PromoCard({
    super.key,
    required this.isDonation,
    required this.isSatisfaction,
    required this.isDifficulty,
    required this.isAccountCreation,
    this.isReferral = false,
    this.isShareStats = false,
    this.isUpdate = false,
    this.isStatus = false,
    this.isDismissible = true,
    this.socialMediaType,
    this.statusTitle,
    this.statusMessage,
    this.statusImpactText,
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
    final statusTitle = (widget.statusTitle != null &&
            widget.statusTitle!.trim().isNotEmpty)
        ? widget.statusTitle!.trim()
        : AppLocalizations.of(context)!.serverStatus;
    final statusMessage = (widget.statusMessage != null &&
            widget.statusMessage!.trim().isNotEmpty)
        ? widget.statusMessage!.trim()
        : AppLocalizations.of(context)!.checkServiceStatus;

    List<Color> gradientColors;
    if (widget.isStatus) {
      gradientColors = [
        cs.primary.withValues(alpha: 0.14),
        cs.primary.withValues(alpha: 0.06)
      ];
    } else if (widget.isDonation) {
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
    } else if (widget.isUpdate) {
      gradientColors = [
        cs.tertiary.withValues(alpha: 0.12),
        cs.tertiary.withValues(alpha: 0.04)
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
                    : widget.isStatus
                        ? Icons.warning_rounded
                    : widget.isSatisfaction
                        ? Icons.feedback_rounded
                        : widget.isDifficulty
                            ? Icons.tune_rounded
                            : widget.isAccountCreation
                                ? Icons.person_add_rounded
                                : widget.isReferral
                                    ? Icons.campaign_rounded
                                    : widget.isShareStats
                                        ? Icons.bar_chart_rounded
                                        : widget.isUpdate
                                            ? Icons.system_update_rounded
                                            : Icons.group_add_rounded,
                color: cs.onSurface.withValues(alpha: 0.7),
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  widget.isDonation
                      ? AppLocalizations.of(context)!.donate
                      : widget.isStatus
                          ? statusTitle
                      : widget.isSatisfaction
                          ? AppLocalizations.of(context)!.satisfactionSurvey
                          : widget.isDifficulty
                              ? AppLocalizations.of(context)!
                                  .difficultyFeedbackTitle
                              : widget.isAccountCreation
                                  ? AppLocalizations.of(context)!.createAccount
                                  : widget.isReferral
                                      ? AppLocalizations.of(context)!
                                          .inviteFriend
                                      : widget.isShareStats
                                          ? AppLocalizations.of(context)!
                                              .shareYourStats
                                          : widget.isUpdate
                                              ? AppLocalizations.of(context)!
                                                  .updateAvailable
                                              : AppLocalizations.of(context)!
                                                  .followUs,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: cs.onSurface,
                      ),
                ),
              ),
              if (widget.isDismissible)
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
                ? AppLocalizations.of(context)!.donateExplanation
                : widget.isStatus
                    ? statusMessage
                : widget.isSatisfaction
                    ? AppLocalizations.of(context)!.satisfactionSurveyMessage
                    : widget.isDifficulty
                        ? AppLocalizations.of(context)!
                            .difficultyFeedbackMessage
                        : widget.isAccountCreation
                            ? AppLocalizations.of(context)!.createAccountMessage
                            : widget.isReferral
                                ? AppLocalizations.of(context)!.inviteFriendDesc
                                : widget.isShareStats
                                    ? AppLocalizations.of(context)!
                                        .copyStatsLinkToClipboard
                                    : widget.isUpdate
                                        ? AppLocalizations.of(context)!
                                            .updateAvailableMessage
                                        : AppLocalizations.of(context)!
                                            .followUsMessage,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          if (widget.isStatus &&
              widget.statusImpactText != null &&
              widget.statusImpactText!.trim().isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              widget.statusImpactText!,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: cs.onSurface,
                  ),
            ),
            const SizedBox(height: 12),
          ] else
            const SizedBox(height: 12),
          if (!widget.isStatus) ...[
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
                      label: Text(AppLocalizations.of(context)!.donateButton),
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
                      label: Text(AppLocalizations.of(context)!
                          .satisfactionSurveyButton),
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
                      child:
                          Text(AppLocalizations.of(context)!.difficultyTooHard),
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
                      child: Text(AppLocalizations.of(context)!.difficultyGood),
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
                      child:
                          Text(AppLocalizations.of(context)!.difficultyTooEasy),
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
                      label: Text(
                          AppLocalizations.of(context)!.createAccountButton),
                    ),
                  ),
                ],
              ),
            ] else if (widget.isReferral) ...[
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => widget.onAction('referral'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: cs.primary,
                        foregroundColor: cs.onPrimary,
                        minimumSize: const Size.fromHeight(44),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      icon: const Icon(Icons.campaign_rounded),
                      label: Text(AppLocalizations.of(context)!.inviteFriend),
                    ),
                  ),
                ],
              ),
            ] else if (widget.isShareStats) ...[
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => widget.onAction('share_stats'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: cs.primary,
                        foregroundColor: cs.onPrimary,
                        minimumSize: const Size.fromHeight(44),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      icon: const Icon(Icons.bar_chart_rounded),
                      label: Text(AppLocalizations.of(context)!.shareYourStats),
                    ),
                  ),
                ],
              ),
            ] else if (widget.isUpdate) ...[
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => widget.onAction('update'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: cs.primary,
                        foregroundColor: cs.onPrimary,
                        minimumSize: const Size.fromHeight(44),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      icon: const Icon(Icons.system_update_rounded),
                      label: Text(AppLocalizations.of(context)!.updateButton),
                    ),
                  ),
                ],
              ),
            ] else if (widget.socialMediaType != null) ...[
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => widget.onAction('social_media'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: cs.primary,
                        foregroundColor: cs.onPrimary,
                        minimumSize: const Size.fromHeight(44),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      icon: const Icon(Icons.group_add_rounded),
                      label: Text(AppLocalizations.of(context)!.followUs),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ],
      ),
    );
  }
}
