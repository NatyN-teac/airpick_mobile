import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import 'shimmer.dart';

// A loading placeholder that mimics a list of cards. Wrap the whole thing in a
// single Shimmer so one controller drives the sweep across every block.
class SkeletonList extends StatelessWidget {
  final int count;
  final EdgeInsets padding;
  final bool scrollable;

  const SkeletonList({
    super.key,
    this.count = 4,
    this.padding = const EdgeInsets.fromLTRB(16, 16, 16, 16),
    this.scrollable = true,
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer(
      child: ListView.separated(
        physics: scrollable
            ? const AlwaysScrollableScrollPhysics()
            : const NeverScrollableScrollPhysics(),
        padding: padding,
        itemCount: count,
        separatorBuilder: (context, _) => const SizedBox(height: 14),
        itemBuilder: (context, _) => const _CardSkeleton(showSurface: true),
      ),
    );
  }
}

/// Compact stack for home-tab previews (Available carriers / Offer requests).
class SkeletonPreviewList extends StatelessWidget {
  final int count;
  final EdgeInsets padding;

  const SkeletonPreviewList({
    super.key,
    this.count = 3,
    this.padding = const EdgeInsets.fromLTRB(20, 0, 20, 0),
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer(
      child: Column(
        children: [
          for (var i = 0; i < count; i++)
            Padding(
              padding: EdgeInsets.fromLTRB(
                padding.left,
                i == 0 ? padding.top : 0,
                padding.right,
                14,
              ),
              child: const _CardSkeleton(showSurface: true),
            ),
        ],
      ),
    );
  }
}

/// Chat inbox rows — avatar + preview lines.
class SkeletonChatList extends StatelessWidget {
  final int count;

  const SkeletonChatList({super.key, this.count = 6});

  @override
  Widget build(BuildContext context) {
    return Shimmer(
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(12, 4, 12, 24),
        itemCount: count,
        separatorBuilder: (context, _) => const SizedBox(height: 2),
        itemBuilder: (context, _) => const _ChatRowSkeleton(),
      ),
    );
  }
}

class _ChatRowSkeleton extends StatelessWidget {
  const _ChatRowSkeleton();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      child: Row(
        children: const [
          ShimmerBox(width: 48, height: 48, radius: 24),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ShimmerBox(width: 120, height: 14, radius: 7),
                SizedBox(height: 8),
                ShimmerBox(width: 180, height: 11, radius: 6),
              ],
            ),
          ),
          SizedBox(width: 8),
          ShimmerBox(width: 36, height: 10, radius: 5),
        ],
      ),
    );
  }
}

/// Home engagements teaser — single wide card placeholder.
class SkeletonEngagementTeaser extends StatelessWidget {
  const SkeletonEngagementTeaser({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Shimmer(child: _EngagementTeaserSkeleton()),
    );
  }
}

class _EngagementTeaserSkeleton extends StatelessWidget {
  const _EngagementTeaserSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 13, 12, 13),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(18)),
      child: Row(
        children: const [
          ShimmerBox(width: 42, height: 42, radius: 13),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ShimmerBox(width: 160, height: 14, radius: 7),
                SizedBox(height: 8),
                ShimmerBox(width: 220, height: 11, radius: 6),
              ],
            ),
          ),
          SizedBox(width: 8),
          ShimmerBox(width: 72, height: 32, radius: 20),
        ],
      ),
    );
  }
}

class _CardSkeleton extends StatelessWidget {
  final bool showSurface;

  const _CardSkeleton({this.showSurface = false});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surface = isDark ? AppColors.darkSurface : Colors.white;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: showSurface ? surface : null,
        borderRadius: BorderRadius.circular(20),
        boxShadow: showSurface
            ? [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.05),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const ShimmerBox(width: 42, height: 42, radius: 12),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    ShimmerBox(width: 130, height: 14, radius: 7),
                    SizedBox(height: 8),
                    ShimmerBox(width: 90, height: 11, radius: 6),
                  ],
                ),
              ),
              const ShimmerBox(width: 56, height: 22, radius: 8),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: const [
              ShimmerBox(width: 70, height: 20, radius: 8),
              SizedBox(width: 8),
              ShimmerBox(width: 54, height: 14, radius: 7),
              Spacer(),
              ShimmerBox(width: 44, height: 11, radius: 6),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: const [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ShimmerBox(width: 72, height: 10, radius: 5),
                    SizedBox(height: 6),
                    ShimmerBox(width: 110, height: 18, radius: 7),
                  ],
                ),
              ),
              ShimmerBox(width: 88, height: 36, radius: 12),
            ],
          ),
        ],
      ),
    );
  }
}
