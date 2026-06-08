import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/skeleton_list.dart';
import '../cubit/engagement_cubit.dart';
import '../models/engagement_models.dart';
import '../widgets/match_engagement_dialog.dart';
import '../widgets/proposal_engagement_dialog.dart';
import 'engagement_activity_screen.dart';

class EngagementsListScreen extends StatelessWidget {
  const EngagementsListScreen({super.key});

  static void openDetail(BuildContext context, EngagementListItem item) {
    final cubit = context.read<EngagementCubit>();
    switch (item.kind) {
      case EngagementKind.proposalSent:
      case EngagementKind.proposalReceived:
        final proposal = cubit.proposalById(item.id);
        if (proposal != null) {
          ProposalEngagementDialog.show(
            context,
            proposal: proposal,
            kind: item.kind,
          );
        }
        return;
      case EngagementKind.match:
        MatchEngagementDialog.show(
          context,
          item: item,
          match: cubit.matchById(item.id),
        );
    }
  }

  static void openViewAll(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const EngagementActivityScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.darkBackground : AppColors.background;
    final textPrimary =
        isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Engagements',
          style: TextStyle(
            fontFamily: 'Manrope',
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: textPrimary,
            letterSpacing: -0.3,
          ),
        ),
        actions: [
          PopupMenuButton<String>(
            icon: Icon(Icons.more_vert_rounded, color: textPrimary),
            onSelected: (value) {
              if (value == 'view_all') openViewAll(context);
            },
            itemBuilder: (_) => [
              const PopupMenuItem<String>(
                value: 'view_all',
                child: Text(
                  'View all',
                  style: TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
      body: BlocBuilder<EngagementCubit, EngagementState>(
        builder: (context, state) {
          if (state.loading && state.items.isEmpty) {
            return const SkeletonList(count: 5);
          }
          if (state.items.isEmpty) {
            return Center(
              child: Text(
                'No active engagements.',
                style: TextStyle(
                  fontFamily: 'Manrope',
                  fontSize: 13,
                  color: isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.textSecondary,
                ),
              ),
            );
          }
          return RefreshIndicator(
            color: AppColors.primary,
            onRefresh: () =>
                context.read<EngagementCubit>().load(force: true),
            child: ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
              itemCount: state.items.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (_, i) => _EngagementCard(
                item: state.items[i],
                isDark: isDark,
                onOpenDetail: () =>
                    EngagementsListScreen.openDetail(context, state.items[i]),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _EngagementCard extends StatelessWidget {
  final EngagementListItem item;
  final bool isDark;
  final VoidCallback onOpenDetail;

  const _EngagementCard({
    required this.item,
    required this.isDark,
    required this.onOpenDetail,
  });

  @override
  Widget build(BuildContext context) {
    final surface = isDark ? AppColors.darkSurface : AppColors.surface;
    final textPrimary =
        isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;
    final textSecondary =
        isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;

    return Material(
      color: surface,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onOpenDetail,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 9, 12, 9),
          child: Row(
            children: [
              Container(
                width: 7,
                height: 7,
                decoration: BoxDecoration(
                  color: item.status.color,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            item.title,
                            style: TextStyle(
                              fontFamily: 'Manrope',
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: textPrimary,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 7, vertical: 2),
                          decoration: BoxDecoration(
                            color: item.status.color.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            item.status.label,
                            style: TextStyle(
                              fontFamily: 'Manrope',
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: item.status.color,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        if (item.fromCode != '—' || item.toCode != '—') ...[
                          _RouteChip(code: item.fromCode, isDark: isDark),
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 5),
                            child: Icon(Icons.arrow_forward_rounded,
                                size: 11, color: textSecondary),
                          ),
                          _RouteChip(code: item.toCode, isDark: isDark),
                          const SizedBox(width: 8),
                        ],
                        Expanded(
                          child: Text(
                            '${item.subtitle} · ${item.dateLabel}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontFamily: 'Manrope',
                              fontSize: 11,
                              color: textSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded,
                  size: 20,
                  color: isDark
                      ? AppColors.darkTextTertiary
                      : const Color(0xFFD1D5DB)),
            ],
          ),
        ),
      ),
    );
  }
}

class _RouteChip extends StatelessWidget {
  final String code;
  final bool isDark;

  const _RouteChip({required this.code, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkBackground : const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(5),
      ),
      child: Text(
        code,
        style: TextStyle(
          fontFamily: 'Manrope',
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color:
              isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
        ),
      ),
    );
  }
}
