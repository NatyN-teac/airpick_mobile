import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/skeleton_list.dart';
import '../../../core/widgets/state_message.dart';
import '../cubit/offer_requests_cubit.dart';
import '../models/offer_request_models.dart';
import '../repository/offer_request_repository.dart';
import 'offer_request_detail_screen.dart';

class OfferRequestsScreen extends StatefulWidget {
  // Called when the user chooses to edit a request from its detail screen.
  // Home wires this to open the edit bubble anchored to the + button.
  final ValueChanged<OfferRequestResponse> onEdit;

  const OfferRequestsScreen({super.key, required this.onEdit});

  @override
  State<OfferRequestsScreen> createState() => _OfferRequestsScreenState();
}

class _OfferRequestsScreenState extends State<OfferRequestsScreen> {
  @override
  void initState() {
    super.initState();
    context.read<OfferRequestsCubit>().load();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BlocBuilder<OfferRequestsCubit, OfferRequestsState>(
      builder: (context, state) {
        return Column(
          children: [
            // Status filter — hidden until there's data to filter
            if (state.requests.isNotEmpty)
              _StatusFilterBar(
                selected: state.statusFilter,
                isDark: isDark,
                onSelect: (s) =>
                    context.read<OfferRequestsCubit>().setFilter(s),
              ),
            Expanded(child: _body(context, state, isDark)),
          ],
        );
      },
    );
  }

  Widget _body(BuildContext context, OfferRequestsState state, bool isDark) {
    // Pull-to-refresh always forces a fresh fetch, on every state.
    Future<void> refresh() =>
        context.read<OfferRequestsCubit>().load(force: true);

    Widget content;
    if (state.loading && state.requests.isEmpty) {
      content = const SkeletonList();
    } else if (state.error != null && state.requests.isEmpty) {
      content = _centeredFiller(
        AppErrorState(
          title: 'Could not load requests',
          message: state.error!,
          onRetry: refresh,
        ),
      );
    } else if (state.requests.isEmpty) {
      content = _centeredFiller(
        const AppEmptyState(
          icon: Icons.inventory_2_outlined,
          title: 'No requests yet',
          message: 'Tap + to create a request for items you need delivered.',
        ),
      );
    } else if (state.visible.isEmpty) {
      content = _centeredFiller(
        const AppEmptyState(
          icon: Icons.filter_list_off_rounded,
          title: 'No requests with this status',
          message: 'Choose another status filter to see your other requests.',
        ),
      );
    } else {
      content = _RequestsList(
        requests: state.visible,
        latestId: state.latestId,
        isDark: isDark,
        onEdit: widget.onEdit,
      );
    }

    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: refresh,
      child: content,
    );
  }

  // Wraps a centered widget so it stays pull-to-refreshable even when short.
  Widget _centeredFiller(Widget child) {
    return LayoutBuilder(
      builder: (_, constraints) => SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: constraints.maxHeight),
          child: Center(child: child),
        ),
      ),
    );
  }
}

// ── Status filter bar ─────────────────────────────────────────────────────────

class _StatusFilterBar extends StatelessWidget {
  final String? selected;
  final bool isDark;
  final ValueChanged<String?> onSelect;

  const _StatusFilterBar({
    required this.selected,
    required this.isDark,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final options = <String?>[null, ...kOfferRequestStatuses];
    return SizedBox(
      height: 52,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 8),
        itemCount: options.length,
        separatorBuilder: (context, _) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final status = options[i];
          final active = status == selected;
          final label = status == null
              ? 'All'
              : offerRequestStatusLabel(status);
          return GestureDetector(
            onTap: () => onSelect(status),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                          offset: const Offset(0, 3),
                        ),
                      ]
                    : null,
              ),
              child: Center(
                child: Text(
                  label,
                  style: TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: active
                        ? Colors.white
                        : (isDark
                              ? AppColors.darkTextSecondary
                              : AppColors.textSecondary),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// Pushes the view-only detail screen.
Future<void> openOfferRequestDetail(
  BuildContext context,
  OfferRequestResponse request,
) {
  return Navigator.of(context).push(
    MaterialPageRoute(
      builder: (_) => OfferRequestDetailScreen(request: request),
    ),
  );
}

// ── Requests list ─────────────────────────────────────────────────────────────

class _RequestsList extends StatelessWidget {
  final List<OfferRequestResponse> requests;
  final String? latestId;
  final bool isDark;
  final ValueChanged<OfferRequestResponse> onEdit;

  const _RequestsList({
    required this.requests,
    required this.latestId,
    required this.isDark,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate((context, i) {
              final req = requests[i];
              final isNew = req.id == latestId;
              final card = GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => openOfferRequestDetail(context, req),
                child: _OfferRequestCard(
                  request: req,
                  isDark: isDark,
                  onEdit: req.canDelete ? () => onEdit(req) : null,
                ),
              );
              return _AnimatedCard(
                key: ValueKey(req.id),
                isNew: isNew,
                child: req.canDelete
                    ? Dismissible(
                        key: ValueKey('dismiss-${req.id}'),
                        direction: DismissDirection.endToStart,
                        background: const _DeleteSwipeBackground(),
                        confirmDismiss: (_) => _confirmDelete(context, req),
                        onDismissed: (_) {
                          context.read<OfferRequestsCubit>().remove(req.id);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Request deleted',
                                style: TextStyle(fontFamily: 'Manrope'),
                              ),
                              backgroundColor: AppColors.success,
                            ),
                          );
                        },
                        child: card,
                      )
                    : card,
              );
            }, childCount: requests.length),
          ),
        ),
      ],
    );
  }

  // Shows confirmation, then deletes via the API. Returns true to dismiss.
  Future<bool> _confirmDelete(
    BuildContext context,
    OfferRequestResponse req,
  ) async {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final messenger = ScaffoldMessenger.of(context);
    final repo = context.read<OfferRequestRepository>();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => _DeleteConfirmDialog(isDark: isDark),
    );
    if (confirmed != true) return false;

    try {
      await repo.deleteOfferRequest(req.id);
      return true;
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            e.toString().replaceFirst('Exception: ', ''),
            style: const TextStyle(fontFamily: 'Manrope'),
          ),
          backgroundColor: AppColors.error,
        ),
      );
      return false;
    }
  }
}

// ── Swipe-to-delete background ────────────────────────────────────────────────

class _DeleteSwipeBackground extends StatelessWidget {
  const _DeleteSwipeBackground();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.only(right: 24),
      alignment: Alignment.centerRight,
      decoration: BoxDecoration(
        color: AppColors.error,
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.delete_outline_rounded, color: Colors.white, size: 24),
          SizedBox(height: 2),
          Text(
            'Delete',
            style: TextStyle(
              fontFamily: 'Manrope',
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Delete confirmation dialog ────────────────────────────────────────────────

class _DeleteConfirmDialog extends StatelessWidget {
  final bool isDark;
  const _DeleteConfirmDialog({required this.isDark});

  @override
  Widget build(BuildContext context) {
    final bg = isDark ? AppColors.darkSurface : Colors.white;
    final textPrimary = isDark
        ? AppColors.darkTextPrimary
        : AppColors.textPrimary;
    final textSecondary = isDark
        ? AppColors.darkTextSecondary
        : AppColors.textSecondary;

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
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.delete_outline_rounded,
                size: 26,
                color: AppColors.error,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Delete this request?',
              style: TextStyle(
                fontFamily: 'Manrope',
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: textPrimary,
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'This permanently removes your offer request. This action cannot be undone.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Manrope',
                fontSize: 12,
                color: textSecondary,
                height: 1.5,
              ),
            ),
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
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'Cancel',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'Manrope',
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: textPrimary,
                        ),
                      ),
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
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'Delete',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'Manrope',
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
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

// Wraps the card with a slide-down + fade entrance for newly added items
class _AnimatedCard extends StatefulWidget {
  final bool isNew;
  final Widget child;

  const _AnimatedCard({super.key, required this.isNew, required this.child});

  @override
  State<_AnimatedCard> createState() => _AnimatedCardState();
}

class _AnimatedCardState extends State<_AnimatedCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _slide = Tween<Offset>(
      begin: const Offset(0, -0.15),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));

    if (widget.isNew) {
      _ctrl.forward();
    } else {
      _ctrl.value = 1.0;
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: SlideTransition(
        position: _slide,
        child: FadeTransition(opacity: _fade, child: widget.child),
      ),
    );
  }
}

// ── Offer request card ────────────────────────────────────────────────────────

class _OfferRequestCard extends StatelessWidget {
  final OfferRequestResponse request;
  final bool isDark;
  final VoidCallback? onEdit;

  const _OfferRequestCard({
    required this.request,
    required this.isDark,
    this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final surface = isDark ? AppColors.darkSurface : Colors.white;
    final textPrimary = isDark
        ? AppColors.darkTextPrimary
        : AppColors.textPrimary;
    final textSecondary = isDark
        ? AppColors.darkTextSecondary
        : AppColors.textSecondary;
    final textTertiary = isDark
        ? AppColors.darkTextTertiary
        : AppColors.textTertiary;
    return Container(
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.28 : 0.07),
            blurRadius: 24,
            offset: const Offset(0, 6),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.10 : 0.03),
            blurRadius: 6,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ──────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.info.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.inventory_2_rounded,
                    size: 20,
                    color: AppColors.info,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${request.sourceCity}, ${request.sourceCountry}',
                        style: TextStyle(
                          fontFamily: 'Manrope',
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: textPrimary,
                          letterSpacing: -0.2,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Icon(
                            Icons.arrow_forward_rounded,
                            size: 11,
                            color: textTertiary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            request.destinationCountry,
                            style: TextStyle(
                              fontFamily: 'Manrope',
                              fontSize: 12,
                              color: textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (onEdit != null) ...[
                      GestureDetector(
                        onTap: onEdit,
                        behavior: HitTestBehavior.opaque,
                        child: Container(
                          padding: const EdgeInsets.all(5),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.edit_outlined,
                            size: 15,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                    ],
                    _StatusChip(status: request.status),
                  ],
                ),
              ],
            ),
          ),

          // ── Route date strip ─────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: surface,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.calendar_today_outlined,
                    size: 13,
                    color: textPrimary,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    _formatDate(request.preferredDate),
                    style: TextStyle(
                      fontFamily: 'Manrope',
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: textPrimary,
                    ),
                  ),
                  const Spacer(),
                  _UrgencyBadge(label: request.urgencyLabel),
                ],
              ),
            ),
          ),

          // ── Footer ───────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
            child: Row(
              children: [
                // Item count
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.category_rounded,
                        size: 11,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${request.items.length} item${request.items.length == 1 ? '' : 's'}',
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
                // Partial badge
                if (request.partialProposalAccepted)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.info.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'Partial ✓',
                      style: TextStyle(
                        fontFamily: 'Manrope',
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppColors.info,
                      ),
                    ),
                  ),
                const Spacer(),
                // Proposal count
                Row(
                  children: [
                    Icon(
                      Icons.people_outline_rounded,
                      size: 13,
                      color: textSecondary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${request.proposalCount} proposal${request.proposalCount == 1 ? '' : 's'}',
                      style: TextStyle(
                        fontFamily: 'Manrope',
                        fontSize: 11,
                        color: textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(String raw) {
    try {
      final parts = raw.split('-');
      const months = [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec',
      ];
      final month = months[int.parse(parts[1]) - 1];
      return '${parts[2]} $month ${parts[0]}';
    } catch (_) {
      return raw;
    }
  }
}

class _StatusChip extends StatelessWidget {
  final String status;
  const _StatusChip({required this.status});

  Color get _color => switch (status) {
    'OPEN' => AppColors.success,
    'PENDING_ITEM_APPROVAL' => AppColors.warning,
    'CLOSED' => AppColors.textDisabled,
    _ => AppColors.info,
  };

  String get _label => switch (status) {
    'OPEN' => 'Open',
    'PENDING_ITEM_APPROVAL' => 'Pending',
    'CLOSED' => 'Closed',
    _ => status,
  };

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
    decoration: BoxDecoration(
      color: _color.withValues(alpha: 0.12),
      borderRadius: BorderRadius.circular(8),
    ),
    child: Text(
      _label,
      style: TextStyle(
        fontFamily: 'Manrope',
        fontSize: 10,
        fontWeight: FontWeight.w700,
        color: _color,
      ),
    ),
  );
}

class _UrgencyBadge extends StatelessWidget {
  final String label;
  const _UrgencyBadge({required this.label});

  Color get _color => switch (label) {
    'Urgent' => AppColors.error,
    'Flexible' => AppColors.info,
    _ => AppColors.textSecondary,
  };

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
    decoration: BoxDecoration(
      color: _color.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(8),
    ),
    child: Text(
      label,
      style: TextStyle(
        fontFamily: 'Manrope',
        fontSize: 10,
        fontWeight: FontWeight.w600,
        color: _color,
      ),
    ),
  );
}
