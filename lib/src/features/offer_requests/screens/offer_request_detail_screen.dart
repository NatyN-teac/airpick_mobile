import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../core/l10n/l10n.dart';
import '../../../core/theme/app_colors.dart';
import '../../chat/screens/chat_screen.dart';
import '../../home/models/engagement_models.dart';
import '../../home/widgets/proposal_engagement_dialog.dart';
import '../repository/offer_request_repository.dart';
import '../models/offer_request_models.dart';

// Detail screen. When the owner opens their own request (`showProposals`), it
// lists the proposals received — tap PENDING to accept/reject, ACCEPTED to chat.
class OfferRequestDetailScreen extends StatefulWidget {
  final OfferRequestResponse request;
  final bool showProposals;

  const OfferRequestDetailScreen({
    super.key,
    required this.request,
    this.showProposals = false,
  });

  @override
  State<OfferRequestDetailScreen> createState() =>
      _OfferRequestDetailScreenState();
}

class _OfferRequestDetailScreenState extends State<OfferRequestDetailScreen> {
  List<ProposalEngagement> _proposals = const [];
  bool _loadingProposals = false;
  String? _proposalsError;

  @override
  void initState() {
    super.initState();
    if (widget.showProposals) _loadProposals();
  }

  Future<void> _loadProposals() async {
    setState(() {
      _loadingProposals = true;
      _proposalsError = null;
    });
    try {
      final proposals = await context
          .read<OfferRequestRepository>()
          .getProposalsForRequest(widget.request.id);
      if (!mounted) return;
      setState(() {
        _proposals = proposals;
        _loadingProposals = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loadingProposals = false;
        _proposalsError = e.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  // Accepted → open the chat; pending → the shipper's accept/reject flow.
  Future<void> _onProposalTap(ProposalEngagement proposal) async {
    if (proposal.hasAvailableChat) {
      openChatScreen(context, proposal.matchId!);
      return;
    }
    if (proposal.status.toUpperCase() == 'PENDING') {
      await ProposalEngagementDialog.show(
        context,
        proposal: proposal,
        kind: EngagementKind.proposalReceived,
      );
      if (mounted) _loadProposals();
    }
  }

  @override
  Widget build(BuildContext context) {
    final request = widget.request;
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

            // ── Proposals ──────────────────────────────────────────
            if (widget.showProposals) ...[
              _buildProposalsSection(
                  context, isDark, textPrimary, textSecondary),
              const SizedBox(height: 24),
            ],

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

  Widget _buildProposalsSection(
    BuildContext context,
    bool isDark,
    Color textPrimary,
    Color textSecondary,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Proposals',
              style: TextStyle(
                fontFamily: 'Manrope',
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: textPrimary,
                letterSpacing: -0.2,
              ),
            ),
            if (_proposals.isNotEmpty) ...[
              const SizedBox(width: 6),
              Text(
                '· ${_proposals.length}',
                style: TextStyle(
                  fontFamily: 'Manrope',
                  fontSize: 12,
                  color: textSecondary,
                ),
              ),
            ],
            const Spacer(),
            if (_loadingProposals)
              const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
          ],
        ),
        const SizedBox(height: 12),
        if (_proposalsError != null)
          Text(
            _proposalsError!,
            style: const TextStyle(
              fontFamily: 'Manrope',
              fontSize: 13,
              color: AppColors.error,
            ),
          )
        else if (!_loadingProposals && _proposals.isEmpty)
          Text(
            'No proposals yet on this request.',
            style: TextStyle(
              fontFamily: 'Manrope',
              fontSize: 13,
              color: textSecondary,
            ),
          )
        else
          ..._proposals.map(
            (p) => _ProposalRow(
              proposal: p,
              isDark: isDark,
              onTap: () => _onProposalTap(p),
            ),
          ),
      ],
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

// ── Proposal row ────────────────────────────────────────────────────────────

class _ProposalRow extends StatelessWidget {
  final ProposalEngagement proposal;
  final bool isDark;
  final VoidCallback onTap;

  const _ProposalRow({
    required this.proposal,
    required this.isDark,
    required this.onTap,
  });

  static String _fmtQty(double n) =>
      n % 1 == 0 ? n.toInt().toString() : n.toStringAsFixed(1);

  String get _itemsSummary {
    if (proposal.items.isEmpty) return 'Proposal';
    return proposal.items
        .map((i) => '${_fmtQty(i.quantity)}× ${i.itemName}')
        .join(', ');
  }

  @override
  Widget build(BuildContext context) {
    final surface = isDark ? AppColors.darkSurface : Colors.white;
    final textPrimary =
        isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;
    final textSecondary =
        isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;
    final border = isDark ? AppColors.darkBorder : AppColors.border;
    final isPending = proposal.status.toUpperCase() == 'PENDING';

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: surface,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: border),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _itemsSummary,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontFamily: 'Manrope',
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          _ProposalStatusChip(status: proposal.status),
                          if (proposal.totalPrice > 0) ...[
                            const SizedBox(width: 8),
                            Text(
                              _fmtQty(proposal.totalPrice),
                              style: TextStyle(
                                fontFamily: 'Manrope',
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: textSecondary,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                if (proposal.hasAvailableChat)
                  const Icon(Icons.chat_bubble_outline_rounded,
                      size: 18, color: AppColors.primary)
                else if (isPending)
                  Row(
                    children: const [
                      Text('Review',
                          style: TextStyle(
                            fontFamily: 'Manrope',
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary,
                          )),
                      Icon(Icons.chevron_right_rounded,
                          size: 18, color: AppColors.primary),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ProposalStatusChip extends StatelessWidget {
  final String status;
  const _ProposalStatusChip({required this.status});

  Color get _c => switch (status.toUpperCase()) {
        'PENDING' => AppColors.warning,
        'ACCEPTED' => AppColors.info,
        'REJECTED' => AppColors.error,
        'WITHDRAWN' => AppColors.textDisabled,
        _ => AppColors.textSecondary,
      };

  String get _label => switch (status.toUpperCase()) {
        'PENDING' => 'Pending',
        'ACCEPTED' => 'Accepted',
        'REJECTED' => 'Rejected',
        'WITHDRAWN' => 'Withdrawn',
        _ => status,
      };

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: _c.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        _label,
        style: TextStyle(
          fontFamily: 'Manrope',
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: _c,
        ),
      ),
    );
  }
}
