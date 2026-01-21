import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../utils/responsive_utils.dart';

class LessonTileSkeleton extends StatelessWidget {
  final bool isDesktop;
  final bool isTablet;
  final bool isSmallPhone;
  final String layoutType;

  const LessonTileSkeleton({
    super.key,
    this.isDesktop = false,
    this.isTablet = false,
    this.isSmallPhone = false,
    this.layoutType = 'grid', // 'list', 'grid', or 'compact_grid'
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final orig = colorScheme.surfaceContainerHighest;

    // Use Color.fromRGBO for better Android compatibility with alpha
    final baseColor = Color.fromRGBO(
      ((orig.r * 255.0).round() & 0xff),
      ((orig.g * 255.0).round() & 0xff),
      ((orig.b * 255.0).round() & 0xff),
      0.3, // 30% opacity
    );
    final highlightColor = Color.fromRGBO(
      ((orig.r * 255.0).round() & 0xff),
      ((orig.g * 255.0).round() & 0xff),
      ((orig.b * 255.0).round() & 0xff),
      0.6, // 60% opacity
    );

    Widget skeletonContent;

    switch (layoutType) {
      case 'list':
        // List view layout
        skeletonContent = Container(
          height: 120, // Fixed height for list items
          decoration: BoxDecoration(
            color: baseColor,
            borderRadius:
                BorderRadius.circular(context.responsiveBorderRadius(18)),
            border: Border.all(
              color: colorScheme.outlineVariant.withValues(alpha: 0.7),
              width: 1,
            ),
          ),
          child: Stack(
            children: [
              // Index badge skeleton
              Positioned(
                top: 12,
                left: 12,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: baseColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: colorScheme.outlineVariant),
                  ),
                  child: Container(
                    width: 60,
                    height: 16,
                    decoration: BoxDecoration(
                      color: baseColor,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),
              // Center icon skeleton
              Positioned.fill(
                child: Center(
                  child: Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: baseColor,
                      borderRadius: BorderRadius.circular(32),
                    ),
                  ),
                ),
              ),
              // Recommended indicator skeleton (if needed)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: baseColor,
                    shape: BoxShape.circle,
                  ),
                  child: Container(
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      color: baseColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      case 'compact_grid':
        // Compact grid layout
        skeletonContent = Container(
          decoration: BoxDecoration(
            color: baseColor,
            borderRadius:
                BorderRadius.circular(context.responsiveBorderRadius(18)),
            border: Border.all(
              color: colorScheme.outlineVariant.withValues(alpha: 0.7),
              width: 1,
            ),
          ),
          child: Stack(
            children: [
              // Index badge skeleton
              Positioned(
                top: 12,
                left: 12,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: baseColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: colorScheme.outlineVariant),
                  ),
                  child: Container(
                    width: 50,
                    height: 16,
                    decoration: BoxDecoration(
                      color: baseColor,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),
              // Center icon skeleton
              Positioned.fill(
                child: Center(
                  child: Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: baseColor,
                      borderRadius: BorderRadius.circular(32),
                    ),
                  ),
                ),
              ),
              // Recommended indicator skeleton (if needed)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: baseColor,
                    shape: BoxShape.circle,
                  ),
                  child: Container(
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      color: baseColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      case 'grid':
      default:
        // Original grid layout
        skeletonContent = Container(
          decoration: BoxDecoration(
            color: baseColor,
            borderRadius:
                BorderRadius.circular(context.responsiveBorderRadius(18)),
            border: Border.all(
              color: colorScheme.outlineVariant.withValues(alpha: 0.7),
              width: 1,
            ),
          ),
          child: Stack(
            children: [
              // Index badge skeleton
              Positioned(
                top: 12,
                left: 12,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: baseColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: colorScheme.outlineVariant),
                  ),
                  child: Container(
                    width: 60,
                    height: 16,
                    decoration: BoxDecoration(
                      color: baseColor,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),
              // Center icon skeleton
              Positioned.fill(
                child: Center(
                  child: Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: baseColor,
                      borderRadius: BorderRadius.circular(32),
                    ),
                  ),
                ),
              ),
              // Recommended indicator skeleton (if needed)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: baseColor,
                    shape: BoxShape.circle,
                  ),
                  child: Container(
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      color: baseColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
    }

    return Shimmer.fromColors(
      baseColor: baseColor,
      highlightColor: highlightColor,
      child: skeletonContent,
    );
  }
}
