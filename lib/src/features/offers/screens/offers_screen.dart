import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/skeleton_list.dart';
import '../cubit/offers_cubit.dart';
import '../models/offer_response.dart';
import '../repository/offer_repository.dart';
import 'offer_detail_screen.dart';

class OffersScreen extends StatefulWidget {
  final ValueChanged<OfferResponse> onEdit;
  const OffersScreen({super.key, required this.onEdit});

  @override
  State<OffersScreen> createState() => _OffersScreenState();
}

class _OffersScreenState extends State<OffersScreen> {
  @override
  void initState() {
    super.initState();
    context.read<OffersCubit>().load();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return BlocBuilder<OffersCubit, OffersState>(
      builder: (context, state) {
        return Column(
          children: [
            if (state.offers.isNotEmpty)
              _StatusFilterBar(
                selected: state.statusFilter,
                isDark: isDark,
                onSelect: (s) => context.read<OffersCubit>().setFilter(s),
              ),
            Expanded(child: _body(context, state, isDark)),
          ],
        );
      },
    );
  }

  Widget _body(BuildContext context, OffersState state, bool isDark) {
    Future<void> refresh() => context.read<OffersCubit>().load(force: true);

    Widget content;
    if (state.loading && state.offers.isEmpty) {
      content = const SkeletonList();
    } else if (state.error != null && state.offers.isEmpty) {
      content = _filler(_ErrorState(message: state.error!, onRetry: refresh));
    } else if (state.offers.isEmpty) {
      content = _filler(const _EmptyState());
    } else if (state.visible.isEmpty) {
      content = _filler(const _FilterEmpty());
    } else {
      content = ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        itemCount: state.visible.length,
        itemBuilder: (_, i) {
          final offer = state.visible[i];
          final card = GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => Navigator.of(context).push(MaterialPageRoute(
                builder: (_) => OfferDetailScreen(offer: offer))),
            child: _MyOfferCard(
              offer: offer,
              isDark: isDark,
              isNew: offer.id == state.latestId,
              onEdit: offer.canDelete ? () => widget.onEdit(offer) : null,
            ),
          );
          return Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: offer.canDelete
                ? Dismissible(
                    key: ValueKey('off-${offer.id}'),
                    direction: DismissDirection.endToStart,
                    background: const _DeleteBg(),
                    confirmDismiss: (_) => _confirmDelete(context, offer),
                    onDismissed: (_) {
                      context.read<OffersCubit>().remove(offer.id);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Offer deleted',
                              style: TextStyle(fontFamily: 'Manrope')),
                          backgroundColor: AppColors.success,
                        ),
                      );
                    },
                    child: card,
                  )
                : card,
          );
        },
      );
    }
    return RefreshIndicator(
        color: AppColors.primary, onRefresh: refresh, child: content);
  }

  Widget _filler(Widget child) => LayoutBuilder(
        builder: (_, c) => SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: c.maxHeight),
            child: Center(child: child),
          ),
        ),
      );

  Future<bool> _confirmDelete(BuildContext context, OfferResponse offer) async {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final messenger = ScaffoldMessenger.of(context);
    final repo = context.read<OfferRepository>();
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => _DeleteDialog(isDark: isDark),
    );
    if (ok != true) return false;
    try {
      await repo.deleteOffer(offer.id);
      return true;
    } catch (e) {
      messenger.showSnackBar(SnackBar(
        content: Text(e.toString().replaceFirst('Exception: ', ''),
            style: const TextStyle(fontFamily: 'Manrope')),
        backgroundColor: AppColors.error,
      ));
      return false;
    }
  }
}

// ── Status filter bar ─────────────────────────────────────────────────────────

class _StatusFilterBar extends StatelessWidget {
  final String? selected;
  final bool isDark;
  final ValueChanged<String?> onSelect;
  const _StatusFilterBar(
      {required this.selected, required this.isDark, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    final options = <String?>[null, ...kOfferStatuses];
    return SizedBox(
      height: 52,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 8),
        itemCount: options.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final s = options[i];
          final active = s == selected;
          final label = s == null ? 'All' : offerStatusLabel(s);
          return GestureDetector(
            onTap: () => onSelect(s),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                gradient: active ? AppColors.primaryGradient : null,
                color: active
                    ? null
                    : (isDark ? AppColors.darkSurface : Colors.white),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: active
                      ? Colors.transparent
                      : (isDark ? AppColors.darkBorder : AppColors.border),
                ),
                boxShadow: active
                    ? [
                        BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.25),
                            blurRadius: 10,
                            offset: const Offset(0, 3))
                      ]
                    : null,
              ),
              child: Center(
                child: Text(label,
                    style: TextStyle(
                      fontFamily: 'Manrope',
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: active
                          ? Colors.white
                          : (isDark
                              ? AppColors.darkTextSecondary
                              : AppColors.textSecondary),
                    )),
              ),
            ),
          );
        },
      ),
    );
  }
}

// ── Card ──────────────────────────────────────────────────────────────────────

class _MyOfferCard extends StatefulWidget {
  final OfferResponse offer;
  final bool isDark;
  final bool isNew;
  final VoidCallback? onEdit;
  const _MyOfferCard(
      {required this.offer,
      required this.isDark,
      required this.isNew,
      this.onEdit});

  @override
  State<_MyOfferCard> createState() => _MyOfferCardState();
}

class _MyOfferCardState extends State<_MyOfferCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 450));
  late final Animation<double> _fade =
      CurvedAnimation(parent: _c, curve: Curves.easeOut);
  late final Animation<Offset> _slide = Tween(
          begin: const Offset(0, -0.12), end: Offset.zero)
      .animate(CurvedAnimation(parent: _c, curve: Curves.easeOutCubic));

  @override
  void initState() {
    super.initState();
    widget.isNew ? _c.forward() : _c.value = 1;
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final o = widget.offer;
    final isDark = widget.isDark;
    final surface = isDark ? AppColors.darkSurface : Colors.white;
    final textPrimary =
        isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;
    final textSecondary =
        isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;
    final textTertiary =
        isDark ? AppColors.darkTextTertiary : AppColors.textTertiary;

    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(
        position: _slide,
        child: Container(
          decoration: BoxDecoration(
            color: surface,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.28 : 0.07),
                  blurRadius: 24,
                  offset: const Offset(0, 6)),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: route + status + edit
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.flight_takeoff_rounded,
                          size: 20, color: AppColors.primary),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(o.fromCode ?? '—',
                                  style: TextStyle(
                                    fontFamily: 'Manrope',
                                    fontSize: 15,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 0.4,
                                    color: textPrimary,
                                  )),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 6),
                                child: Icon(Icons.arrow_forward_rounded,
                                    size: 13, color: textTertiary),
                              ),
                              Text(o.toCode ?? '—',
                                  style: TextStyle(
                                    fontFamily: 'Manrope',
                                    fontSize: 15,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 0.4,
                                    color: textPrimary,
                                  )),
                            ],
                          ),
                          if (o.departureDate != null)
                            Text(o.departureDate!,
                                style: TextStyle(
                                    fontFamily: 'Manrope',
                                    fontSize: 11,
                                    color: textSecondary)),
                        ],
                      ),
                    ),
                    if (widget.onEdit != null) ...[
                      GestureDetector(
                        onTap: widget.onEdit,
                        behavior: HitTestBehavior.opaque,
                        child: Container(
                          padding: const EdgeInsets.all(5),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.edit_outlined,
                              size: 15, color: AppColors.primary),
                        ),
                      ),
                      const SizedBox(width: 6),
                    ],
                    _StatusChip(status: o.status),
                  ],
                ),
              ),
              // Footer: items + value + created
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 2, 14, 12),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.category_rounded,
                              size: 11, color: AppColors.primary),
                          const SizedBox(width: 4),
                          Text(
                            '${o.items.length} item${o.items.length == 1 ? '' : 's'}',
                            style: const TextStyle(
                              fontFamily: 'Manrope',
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text('${o.currency} ${o.totalValue.toStringAsFixed(2)}',
                        style: TextStyle(
                            fontFamily: 'Manrope',
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: textSecondary)),
                    const Spacer(),
                    Icon(Icons.schedule_rounded, size: 11, color: textTertiary),
                    const SizedBox(width: 4),
                    Text(o.createdAgo,
                        style: TextStyle(
                            fontFamily: 'Manrope',
                            fontSize: 10,
                            color: textTertiary)),
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

class _StatusChip extends StatelessWidget {
  final String status;
  const _StatusChip({required this.status});

  Color get _c => switch (status) {
        'OPEN' => AppColors.success,
        'MATCHED' || 'ACCEPTED' => AppColors.info,
        'IN_DELIVERY' => const Color(0xFF9F7AEA),
        'COMPLETED' => AppColors.textSecondary,
        _ => AppColors.warning,
      };

  @override
  Widget build(BuildContext context) {
    final s = status.replaceAll('_', ' ').toLowerCase();
    final label = s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: _c.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(label,
          style: TextStyle(
            fontFamily: 'Manrope',
            fontSize: 10,
            fontWeight: FontWeight.w700,
            color: _c,
          )),
    );
  }
}

// ── States ────────────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  const _EmptyState();
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary =
        isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;
    final textSecondary =
        isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 88,
          height: 88,
          decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.08),
              shape: BoxShape.circle),
          child: const Icon(Icons.local_offer_outlined,
              size: 44, color: AppColors.primary),
        ),
        const SizedBox(height: 20),
        Text('No offers yet',
            style: TextStyle(
                fontFamily: 'Manrope',
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: textPrimary,
                letterSpacing: -0.3)),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Text('Tap + to post an offer with your flight.',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontFamily: 'Manrope',
                  fontSize: 13,
                  color: textSecondary,
                  height: 1.5)),
        ),
      ],
    );
  }
}

class _FilterEmpty extends StatelessWidget {
  const _FilterEmpty();
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final c = isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.filter_list_off_rounded, size: 36, color: c),
        const SizedBox(height: 10),
        Text('No offers with this status',
            style: TextStyle(fontFamily: 'Manrope', fontSize: 13, color: c)),
      ],
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  final Future<void> Function() onRetry;
  const _ErrorState({required this.message, required this.onRetry});
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final c = isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.cloud_off_rounded, size: 40, color: AppColors.error),
          const SizedBox(height: 12),
          Text(message.replaceFirst('Exception: ', ''),
              textAlign: TextAlign.center,
              style: TextStyle(fontFamily: 'Manrope', fontSize: 13, color: c)),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: onRetry,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(10)),
              child: const Text('Retry',
                  style: TextStyle(
                      fontFamily: 'Manrope',
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }
}

class _DeleteBg extends StatelessWidget {
  const _DeleteBg();
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.only(right: 24),
        alignment: Alignment.centerRight,
        decoration: BoxDecoration(
            color: AppColors.error, borderRadius: BorderRadius.circular(20)),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.delete_outline_rounded, color: Colors.white, size: 24),
            SizedBox(height: 2),
            Text('Delete',
                style: TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: Colors.white)),
          ],
        ),
      );
}

class _DeleteDialog extends StatelessWidget {
  final bool isDark;
  const _DeleteDialog({required this.isDark});
  @override
  Widget build(BuildContext context) {
    final bg = isDark ? AppColors.darkSurface : Colors.white;
    final textPrimary =
        isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;
    final textSecondary =
        isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;
    return Dialog(
      backgroundColor: bg,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.1),
                  shape: BoxShape.circle),
              child: const Icon(Icons.delete_outline_rounded,
                  size: 26, color: AppColors.error),
            ),
            const SizedBox(height: 16),
            Text('Delete this offer?',
                style: TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: textPrimary,
                    letterSpacing: -0.3)),
            const SizedBox(height: 8),
            Text('This removes your offer permanently.',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 12,
                    color: textSecondary,
                    height: 1.5)),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => Navigator.of(context).pop(false),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                          color: isDark
                              ? AppColors.darkBackground
                              : AppColors.surface,
                          borderRadius: BorderRadius.circular(12)),
                      child: Text('Cancel',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontFamily: 'Manrope',
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: textPrimary)),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: GestureDetector(
                    onTap: () => Navigator.of(context).pop(true),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                          color: AppColors.error,
                          borderRadius: BorderRadius.circular(12)),
                      child: const Text('Delete',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontFamily: 'Manrope',
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: Colors.white)),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
