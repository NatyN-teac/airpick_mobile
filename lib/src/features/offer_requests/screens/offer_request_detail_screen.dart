import 'package:flutter/material.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../core/l10n/l10n.dart';
import '../../../core/theme/app_colors.dart';
import '../models/offer_request_models.dart';

// View-only detail screen. Edit + delete now live on the list card.
class OfferRequestDetailScreen extends StatelessWidget {
  final OfferRequestResponse request;

  const OfferRequestDetailScreen({super.key, required this.request});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.darkBackground : AppColors.background;
    final l = l10n(context);
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
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          l.requestDetailTitle,
          style: TextStyle(
            fontFamily: 'Manrope',
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: textPrimary,
            letterSpacing: -0.3,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Route + status header ──────────────────────────────
            _RouteHeader(request: request, isDark: isDark),
            const SizedBox(height: 12),

            // ── Meta row: created ago + proposals ──────────────────
            Row(
              children: [
                Icon(Icons.schedule_rounded,
                    size: 14, color: textSecondary),
                const SizedBox(width: 5),
                Text(
                  l.offerCreatedAgo(request.createdAgo),
                  style: TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 12,
                    color: textSecondary,
                  ),
                ),
                const Spacer(),
                Icon(Icons.people_outline_rounded,
                    size: 14, color: textSecondary),
                const SizedBox(width: 5),
                Text(
                  '${request.proposalCount} proposal${request.proposalCount == 1 ? '' : 's'}',
                  style: TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 12,
                    color: textSecondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // ── Detail rows ────────────────────────────────────────
            _DetailTile(
              icon: Icons.calendar_today_rounded,
              label: l.preferredDate,
              value: _prettyDate(request.preferredDate),
              isDark: isDark,
            ),
            _DetailTile(
              icon: Icons.bolt_rounded,
              label: l.urgencyLevel,
              value: request.urgencyLabel,
              isDark: isDark,
            ),
            _DetailTile(
              icon: Icons.call_split_rounded,
              label: l.reqPartialProposals,
              value: request.partialProposalAccepted
                  ? l.statusAccepted
                  : l.statusNotAccepted,
              isDark: isDark,
            ),
            if (request.specialNote != null &&
                request.specialNote!.isNotEmpty)
              _DetailTile(
                icon: Icons.sticky_note_2_outlined,
                label: l.specialNote,
                value: request.specialNote!,
                isDark: isDark,
              ),
            const SizedBox(height: 20),

            // ── Items ──────────────────────────────────────────────
            Row(
              children: [
                Text(
                  l.offerItems,
                  style: TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: textPrimary,
                    letterSpacing: -0.2,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  '· ${request.totalQuantity} total',
                  style: TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 12,
                    color: textSecondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            ...request.items.map((it) => _ItemTile(item: it, isDark: isDark)),
            if (request.items.isEmpty)
              Text(
                l.reqNoItems,
                style: TextStyle(
                  fontFamily: 'Manrope',
                  fontSize: 13,
                  color: textSecondary,
                ),
              ),

            // ── Lock notice when not editable ──────────────────────
            if (!request.canDelete) ...[
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.warning.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline_rounded,
                        size: 15, color: AppColors.warning),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        request.proposalCount > 0
                            ? l.reqHasProposalsLocked
                            : l.reqStatusLocked(switch (request.status) {
                                'OPEN' => l.statusOpen,
                                'PENDING_ITEM_APPROVAL' =>
                                  l.statusPendingApproval,
                                'CLOSED' => l.statusClosed,
                                'ACCEPTED' => l.statusAccepted,
                                'CANCELLED' => l.statusCancelled,
                                _ => request.statusLabel,
                              }.toLowerCase()),
                        style: const TextStyle(
                          fontFamily: 'Manrope',
                          fontSize: 11,
                          color: AppColors.warning,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _prettyDate(String raw) {
    try {
      final parts = raw.split('-');
      const months = [
        'January', 'February', 'March', 'April', 'May', 'June',
        'July', 'August', 'September', 'October', 'November', 'December'
      ];
      return '${parts[2]} ${months[int.parse(parts[1]) - 1]} ${parts[0]}';
    } catch (_) {
      return raw;
    }
  }
}

// ── Route header ──────────────────────────────────────────────────────────────

class _RouteHeader extends StatelessWidget {
  final OfferRequestResponse request;
  final bool isDark;

  const _RouteHeader({required this.request, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final surface = isDark ? AppColors.darkSurface : Colors.white;
    final textPrimary =
        isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;
    final textSecondary =
        isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.06),
            blurRadius: 18,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: AppColors.info.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.inventory_2_rounded,
                    size: 21, color: AppColors.info),
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
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: textPrimary,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Icon(Icons.arrow_forward_rounded,
                            size: 13, color: textSecondary),
                        const SizedBox(width: 4),
                        Text(
                          request.destinationCountry,
                          style: TextStyle(
                            fontFamily: 'Manrope',
                            fontSize: 13,
                            color: textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              _StatusChip(status: request.status),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String status;
  const _StatusChip({required this.status});

  Color get _color => switch (status) {
        'OPEN' => AppColors.success,
        'PENDING_ITEM_APPROVAL' => AppColors.warning,
        'ACCEPTED' => AppColors.info,
        'CANCELLED' || 'CLOSED' => AppColors.textDisabled,
        _ => AppColors.info,
      };

  String _labelOf(AppLocalizations l) => switch (status) {
        'OPEN' => l.statusOpen,
        'PENDING_ITEM_APPROVAL' => l.statusPending,
        'ACCEPTED' => l.statusAccepted,
        'CANCELLED' => l.statusCancelled,
        'CLOSED' => l.statusClosed,
        _ => status,
      };

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
        decoration: BoxDecoration(
          color: _color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          _labelOf(l10n(context)),
          style: TextStyle(
            fontFamily: 'Manrope',
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: _color,
          ),
        ),
      );
}

// ── Detail tile ───────────────────────────────────────────────────────────────

class _DetailTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool isDark;

  const _DetailTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final textPrimary =
        isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;
    final textSecondary =
        isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 17, color: AppColors.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 11,
                    color: textSecondary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: textPrimary,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Item tile ─────────────────────────────────────────────────────────────────

class _ItemTile extends StatelessWidget {
  final OfferRequestItem item;
  final bool isDark;

  const _ItemTile({required this.item, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final surface = isDark ? AppColors.darkSurface : Colors.white;
    final border = isDark ? AppColors.darkBorder : AppColors.border;
    final textPrimary =
        isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;
    final textSecondary =
        isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: border),
      ),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(9),
            ),
            child: const Icon(Icons.category_rounded,
                size: 16, color: AppColors.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              item.name,
              style: TextStyle(
                fontFamily: 'Manrope',
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: textPrimary,
              ),
            ),
          ),
          Text(
            '× ${item.quantity}${item.measurementUnit != null ? '  ${item.measurementUnit}' : ''}',
            style: TextStyle(
              fontFamily: 'Manrope',
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
