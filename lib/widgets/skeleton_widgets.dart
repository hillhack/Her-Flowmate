import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:provider/provider.dart';
import '../utils/app_theme.dart';
import '../services/storage_service.dart';

/// A reusable skeleton loader for a card structure.
class SkeletonCard extends StatelessWidget {
  final double? width;
  final double height;
  final double borderRadius;

  const SkeletonCard({
    super.key,
    this.width,
    required this.height,
    this.borderRadius = 24,
  });

  @override
  Widget build(BuildContext context) {
    final isHighPerf = context.select<StorageService, bool>(
      (s) => s.isHighPerformanceMode,
    );

    final child = Container(
      width: width ?? double.infinity,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    );

    if (isHighPerf) return Opacity(opacity: 0.1, child: child);

    return Shimmer.fromColors(
      baseColor: AppTheme.textSecondary.withValues(alpha: 0.1),
      highlightColor: Colors.white.withValues(alpha: 0.4),
      child: child,
    );
  }
}

/// A circular skeleton loader (e.g., for avatars).
class SkeletonCircle extends StatelessWidget {
  final double size;

  const SkeletonCircle({super.key, required this.size});

  @override
  Widget build(BuildContext context) {
    final isHighPerf = context.select<StorageService, bool>(
      (s) => s.isHighPerformanceMode,
    );

    final child = Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
      ),
    );

    if (isHighPerf) return Opacity(opacity: 0.1, child: child);

    return Shimmer.fromColors(
      baseColor: AppTheme.textSecondary.withValues(alpha: 0.1),
      highlightColor: Colors.white.withValues(alpha: 0.4),
      child: child,
    );
  }
}

/// A line skeleton loader for text placeholders.
class SkeletonLine extends StatelessWidget {
  final double? width;
  final double height;

  const SkeletonLine({super.key, this.width, this.height = 16});

  @override
  Widget build(BuildContext context) {
    final isHighPerf = context.select<StorageService, bool>(
      (s) => s.isHighPerformanceMode,
    );

    final child = Container(
      width: width ?? double.infinity,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(height / 2),
      ),
    );

    if (isHighPerf) return Opacity(opacity: 0.1, child: child);

    return Shimmer.fromColors(
      baseColor: AppTheme.textSecondary.withValues(alpha: 0.1),
      highlightColor: Colors.white.withValues(alpha: 0.4),
      child: child,
    );
  }
}

