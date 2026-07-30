import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../core/l10n/l10n.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/skeleton_list.dart';
import '../cubit/engagement_cubit.dart';
import '../models/engagement_models.dart';
import 'engagements_list_screen.dart';

enum EngagementActivityFilter { sent, received, matched }

extension _FilterX on EngagementActivityFilter {
  String label(AppLocalizations l) => switch (this) {
        EngagementActivityFilter.sent => l.tabSent,
        EngagementActivityFilter.received => l.tabReceived,
        EngagementActivityFilter.matched => l.tabMatched,
      };

  EngagementKind get kind => switch (this) {
        EngagementActivityFilter.sent => EngagementKind.proposalSent,
        EngagementActivityFilter.received => EngagementKind.proposalReceived,
        EngagementActivityFilter.matched => EngagementKind.match,
      };

  String emptyMessage(AppLocalizations l) => switch (this) {
        EngagementActivityFilter.sent => l.emptyProposalsSent,
        EngagementActivityFilter.received => l.emptyProposalsReceived,
        EngagementActivityFilter.matched => l.emptyMatches,
      };
}

class EngagementActivityScreen extends StatefulWidget {
  final EngagementActivityFilter initialFilter;

  const EngagementActivityScreen({
    super.key,
    this.initialFilter = EngagementActivityFilter.sent,
  });

  @override
  State<EngagementActivityScreen> createState() =>
      _EngagementActivityScreenState();
}

class _EngagementActivityScreenState extends State<EngagementActivityScreen> {
  late EngagementActivityFilter _filter;

  @override
  void initState() {
    super.initState();
    _filter = widget.initialFilter;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.darkBackground : AppColors.background;
    final textPrimary =
        isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;
    final textSecondary =
        isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        elevation: 0,
        scrolledUnderElevation: 0,
        // The label is localised, so it must never be squeezed into a fixed
        // box — a clamped leadingWidth wrapped "Cancel" onto two lines.
        leading: TextButton(
          onPressed: () => Navigator.of(context).pop(),
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: Text(
            l10n(context).cancel,
            maxLines: 1,
            softWrap: false,
            overflow: TextOverflow.fade,
            style: TextStyle(
              fontFamily: 'Manrope',
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: textPrimary,
            ),
          ),
        ),
        leadingWidth: 96,
        title: Text(
          l10n(context).viewAll,
          style: TextStyle(
            fontFamily: 'Manrope',
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: textPrimary,
            letterSpacing: -0.3,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: _FilterBar(
              selected: _filter,
              isDark: isDark,
              onChanged: (f) => setState(() => _filter = f),
            ),
          ),
          Expanded(
            child: BlocBuilder<EngagementCubit, EngagementState>(
              builder: (context, state) {
                if (state.loading && state.response == null) {
                  return const SkeletonList(count: 5);
                }

                final items =
                    state.response?.itemsOfKind(_filter.kind) ?? const [];

                if (items.isEmpty) {
                  return RefreshIndicator(
                    color: AppColors.primary,
                    onRefresh: () =>
                        context.read<EngagementCubit>().load(force: true),
                    child: ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: [
                        const SizedBox(height: 120),
                        Center(
                          child: Text(
                            _filter.emptyMessage(l10n(context)),
                            style: TextStyle(
                              fontFamily: 'Manrope',
                              fontSize: 13,
                              color: textSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  color: AppColors.primary,
                  onRefresh: () =>
                      context.read<EngagementCubit>().load(force: true),
                  child: ListView.separated(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 28),
                    itemCount: items.length,
                    separatorBuilder: (context, _) => const SizedBox(height: 10),
                    itemBuilder: (_, i) => _ActivityCard(
                      item: items[i],
                      isDark: isDark,
                      onTap: () =>
                          EngagementsListScreen.openDetail(context, items[i]),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterBar extends StatelessWidget {
  final EngagementActivityFilter selected;
  final bool isDark;
  final ValueChanged<EngagementActivityFilter> onChanged;

  const _FilterBar({
    required this.selected,
    required this.isDark,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.surface,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: EngagementActivityFilter.values
            .map((f) => _FilterChip(
                  label: f.label(l10n(context)),
                  selected: selected == f,
                  isDark: isDark,
                  onTap: () => onChanged(f),
                ))
            .toList(),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final bool isDark;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.selected,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: selected ? AppColors.secondary : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          alignment: Alignment.center,
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: Text(
                label,
                maxLines: 1,
                softWrap: false,
                overflow: TextOverflow.fade,
                style: TextStyle(
                  fontFamily: 'Manrope',
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  color: selected
                      ? Colors.white
                      : (isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.textSecondary),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ActivityCard extends StatelessWidget {
  final EngagementListItem item;
  final bool isDark;
  final VoidCallback onTap;

  const _ActivityCard({
    required this.item,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final surface = isDark ? AppColors.darkSurface : AppColors.surface;
    final textPrimary =
        isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;
    final textSecondary =
        isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;

    final showRoute = item.fromCode != '—' || item.toCode != '—';

    return Material(
      color: surface,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isDark ? AppColors.darkBorder : AppColors.borderLight,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: item.status.color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  item.kind == EngagementKind.match
                      ? Icons.handshake_outlined
                      : Icons.mail_outline_rounded,
                  color: item.status.color,
                  size: 20,
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
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontFamily: 'Manrope',
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: textPrimary,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
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
                    const SizedBox(height: 4),
                    Text(
                      [
                        if (showRoute) '${item.fromCode} → ${item.toCode}',
                        '${item.subtitle} · ${item.dateLabel}',
                      ].join(' · '),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: 'Manrope',
                        fontSize: 11,
                        color: textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
