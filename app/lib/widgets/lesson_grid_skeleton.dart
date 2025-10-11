import 'package:flutter/material.dart';

class LessonGridSkeleton extends StatelessWidget {
  const LessonGridSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final screenWidth = MediaQuery.sizeOf(context).width;
    final double tileMaxExtent = screenWidth >= 1400
        ? 260
        : screenWidth >= 1200
            ? 240
            : screenWidth >= 1000
                ? 220
                : screenWidth >= 840
                    ? 210
                    : screenWidth >= 600
                        ? 200
                        : screenWidth >= 400
                            ? 170
                            : 160;
    final double gridAspect = screenWidth >= 1000
        ? 1.12
        : screenWidth >= 600
            ? 1.05
            : screenWidth >= 360
                ? 0.98
                : 0.92;

    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;
        if (!w.isFinite || w <= 0) {
          return const SizedBox.shrink();
        }
        return GridView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: 6,
          gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: tileMaxExtent,
            mainAxisSpacing: 14,
            crossAxisSpacing: 14,
            childAspectRatio: gridAspect,
          ),
          itemBuilder: (_, __) => Container(
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: colorScheme.outlineVariant),
            ),
          ),
        );
      },
    );
  }
}
