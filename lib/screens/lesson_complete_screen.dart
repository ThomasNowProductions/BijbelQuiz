import 'package:flutter/material.dart';
import 'dart:math' as math;

import '../models/lesson.dart';

class LessonCompleteScreen extends StatefulWidget {
  final Lesson lesson;
  final int stars; // 0..3
  final int correct;
  final int total;
  final int bestStreak;
  final VoidCallback onRetry;
  final VoidCallback onExit;

  const LessonCompleteScreen({
    super.key,
    required this.lesson,
    required this.stars,
    required this.correct,
    required this.total,
    required this.bestStreak,
    required this.onRetry,
    required this.onExit,
  });

  @override
  State<LessonCompleteScreen> createState() => _LessonCompleteScreenState();
}

class _LessonCompleteScreenState extends State<LessonCompleteScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _celebrate;

  @override
  void initState() {
    super.initState();
    _celebrate = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(period: const Duration(milliseconds: 2200));
  }

  @override
  void dispose() {
    _celebrate.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final pctValue = widget.total > 0 ? (widget.correct / widget.total * 100.0) : 0.0;

    return Scaffold(
      backgroundColor: cs.surface,
      body: Stack(
        children: [
          // Background gradient
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  cs.primary.withOpacity(0.10),
                  cs.primaryContainer.withOpacity(0.06),
                  cs.surface,
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          // Confetti overlay
          IgnorePointer(
            child: AnimatedBuilder(
              animation: _celebrate,
              builder: (context, _) {
                return Stack(children: _buildConfetti(context, cs));
              },
            ),
          ),
          SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 640),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
                  child: SingleChildScrollView(
                    child: Column(
                    children: [
                      const SizedBox(height: 8),
                      // Heading + Icon (animated)
                      TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0.9, end: 1.0),
                        duration: const Duration(milliseconds: 500),
                        curve: Curves.easeOutBack,
                        builder: (context, value, child) => Transform.scale(scale: value, child: child),
                        child: Container(
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color: cs.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: cs.outlineVariant),
                            boxShadow: [
                              BoxShadow(
                                color: cs.primary.withOpacity(0.15),
                                blurRadius: 18,
                                spreadRadius: 2,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.emoji_events_rounded, color: cs.primary, size: 36),
                              const SizedBox(width: 12),
                              Text(
                                'Les voltooid',
                                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),
                      // Lesson title/badge
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: cs.surface,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: cs.outlineVariant),
                        ),
                        child: Text(
                          widget.lesson.title,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                          textAlign: TextAlign.center,
                        ),
                      ),

                      const SizedBox(height: 24),
                      // Animated Stars row (celebration)
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          // Soft glow
                          Container(
                            width: 160,
                            height: 60,
                            decoration: BoxDecoration(
                              gradient: RadialGradient(
                                colors: [
                                  cs.primary.withOpacity(0.18),
                                  Colors.transparent,
                                ],
                              ),
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(3, (i) {
                              final filled = i < widget.stars;
                              final delayMs = 150 * i;
                              return TweenAnimationBuilder<double>(
                                key: ValueKey('star_${i}-${widget.stars}'),
                                tween: Tween(begin: 0.0, end: 1.0),
                                duration: Duration(milliseconds: 500 + delayMs),
                                curve: Curves.easeOutBack,
                                builder: (context, value, child) => Transform.scale(
                                  scale: value.clamp(0.0, 1.0),
                                  child: Opacity(opacity: value.clamp(0.0, 1.0), child: child),
                                ),
                                child: Padding(
                                  padding: EdgeInsets.only(right: i == 2 ? 0 : 12),
                                  child: Icon(
                                    Icons.star_rounded,
                                    size: 48,
                                    color: filled ? cs.primary : cs.outlineVariant,
                                  ),
                                ),
                              );
                            }),
                          ),
                        ],
                      ),

                      const SizedBox(height: 28),
                      // Stats cards
                      Wrap(
                        alignment: WrapAlignment.center,
                        spacing: 12,
                        runSpacing: 12,
                        children: [
                          _AnimatedNumberCard(
                            icon: Icons.check_circle_rounded,
                            label: 'Correct',
                            target: widget.correct,
                          ),
                          _AnimatedNumberCard(
                            icon: Icons.percent_rounded,
                            label: 'Percentage',
                            target: pctValue.round(),
                            suffix: '%',
                          ),
                          _StatCard(
                            icon: Icons.local_fire_department_rounded,
                            label: 'Beste reeks',
                            value: '${widget.bestStreak}',
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // Call-to-actions
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: widget.onExit,
                              icon: const Icon(Icons.list_alt_rounded),
                              label: const Text('Terug naar lessen'),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 14),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: widget.onRetry,
                              icon: const Icon(Icons.refresh_rounded),
                              label: const Text('Opnieuw'),
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 14),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  )),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildConfetti(BuildContext context, ColorScheme cs) {
    final size = MediaQuery.of(context).size;
    final width = size.width;
    final height = size.height;
    final t = _celebrate.value;
    final colors = <Color>[
      cs.primary.withOpacity(0.9),
      const Color(0xFFF59E0B),
      const Color(0xFF10B981),
      const Color(0xFF6366F1),
      const Color(0xFFEF4444),
      const Color(0xFF06B6D4),
    ];

    final widgets = <Widget>[];
    for (int i = 0; i < 18; i++) {
      final phase = (t + i * 0.07) % 1.0;
      final x = (math.sin((phase * 2 * math.pi) + i) * 0.4 + 0.5) * width;
      final y = phase * height * 0.8 + (i % 3) * 24.0;
      final color = colors[i % colors.length];
      final iconSize = 12.0 + (i % 3) * 4.0;
      widgets.add(Positioned(
        left: x,
        top: y,
        child: Opacity(
          opacity: 0.6 + 0.4 * (math.sin(phase * 2 * math.pi).abs()),
          child: Transform.rotate(
            angle: phase * 2 * math.pi,
            child: Icon(Icons.auto_awesome, color: color, size: iconSize),
          ),
        ),
      ));
    }
    return widgets;
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      width: 168,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cs.outlineVariant),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: cs.primary),
          const SizedBox(height: 6),
          Text(
            value,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: cs.onSurface.withOpacity(0.7),
                ),
          ),
        ],
      ),
    );
  }
}

class _AnimatedNumberCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final int target;
  final String? suffix;

  const _AnimatedNumberCard({
    required this.icon,
    required this.label,
    required this.target,
    this.suffix,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      width: 168,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cs.outlineVariant),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: cs.primary),
          const SizedBox(height: 6),
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: target.toDouble()),
            duration: const Duration(milliseconds: 900),
            curve: Curves.easeOutCubic,
            builder: (context, value, _) {
              final text = value.round().toString() + (suffix ?? '');
              return Text(
                text,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
              );
            },
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: cs.onSurface.withOpacity(0.7),
                ),
          ),
        ],
      ),
    );
  }
}