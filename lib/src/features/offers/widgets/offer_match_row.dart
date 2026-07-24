import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/theme/app_colors.dart';
import '../../matches/models/match_models.dart';
import '../../matches/repository/match_repository.dart';

/// A single match on the carrier's own offer, in the offer-detail matches list.
/// Eligible (chat-ready) matches route to chat; PENDING ones open accept/reject.
class OfferMatchRow extends StatelessWidget {
  final MatchResponse match;
  final bool isDark;
  final VoidCallback onTap;

  const OfferMatchRow({
    super.key,
    required this.match,
    required this.isDark,
    required this.onTap,
  });

  String get _itemsSummary {
    if (match.matchedItems.isEmpty) return 'Match';
    return match.matchedItems
        .map((i) => '${OfferQty.format(i.quantity)}× ${i.itemName}')
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
    final isPending = match.status.toUpperCase() == 'PENDING';
    final canChat = match.hasAvailableChat;

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
                          _MatchStatusChip(status: match.status),
                          if (match.totalPrice > 0) ...[
                            const SizedBox(width: 8),
                            Text(
                              OfferQty.format(match.totalPrice),
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
                if (canChat)
                  const Icon(Icons.chat_bubble_outline_rounded,
                      size: 18, color: AppColors.primary)
                else if (isPending)
                  Row(
                    children: [
                      Text('Review',
                          style: TextStyle(
                            fontFamily: 'Manrope',
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary,
                          )),
                      const Icon(Icons.chevron_right_rounded,
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

/// Small helper so this widget doesn't depend on OfferResponse's static.
class OfferQty {
  static String format(double n) =>
      n % 1 == 0 ? n.toInt().toString() : n.toStringAsFixed(1);
}

class _MatchStatusChip extends StatelessWidget {
  final String status;
  const _MatchStatusChip({required this.status});

  Color get _c => switch (status.toUpperCase()) {
        'PENDING' => AppColors.warning,
        'ACCEPTED' ||
        'IN_PROGRESS' ||
        'IN_DELIVERY' ||
        'CARRIER_DELIVERED' =>
          AppColors.info,
        'COMPLETED' => AppColors.success,
        'REJECTED' || 'CANCELLED' => AppColors.error,
        _ => AppColors.textSecondary,
      };

  String get _label => switch (status.toUpperCase()) {
        'PENDING' => 'Pending',
        'ACCEPTED' => 'Accepted',
        'IN_PROGRESS' => 'In transit',
        'IN_DELIVERY' => 'In delivery',
        'CARRIER_DELIVERED' => 'Awaiting confirmation',
        'COMPLETED' => 'Delivered',
        'REJECTED' => 'Rejected',
        'CANCELLED' => 'Cancelled',
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

/// Bottom sheet letting the carrier accept or reject a PENDING match — same
/// backend calls as the engagement dialog. Returns `true` if the match changed.
Future<bool?> showOfferMatchActions(BuildContext context, MatchResponse match) {
  return showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _OfferMatchActionsSheet(match: match),
  );
}

class _OfferMatchActionsSheet extends StatefulWidget {
  final MatchResponse match;
  const _OfferMatchActionsSheet({required this.match});

  @override
  State<_OfferMatchActionsSheet> createState() =>
      _OfferMatchActionsSheetState();
}

class _OfferMatchActionsSheetState extends State<_OfferMatchActionsSheet> {
  String? _busy; // 'accept' | 'reject'

  MatchRepository get _repo => context.read<MatchRepository>();

  Future<void> _accept() async {
    setState(() => _busy = 'accept');
    try {
      await _repo.acceptMatch(widget.match.id);
      if (!mounted) return;
      Navigator.of(context).pop(true);
      _snack('Match accepted');
    } catch (e) {
      if (!mounted) return;
      setState(() => _busy = null);
      _snack(_message(e), isError: true);
    }
  }

  Future<void> _reject() async {
    final reason = await _askReason();
    if (reason == null || !mounted) return;
    setState(() => _busy = 'reject');
    try {
      await _repo.rejectMatch(widget.match.id, reason);
      if (!mounted) return;
      Navigator.of(context).pop(true);
      _snack('Match rejected');
    } catch (e) {
      if (!mounted) return;
      setState(() => _busy = null);
      _snack(_message(e), isError: true);
    }
  }

  Future<String?> _askReason() {
    final controller = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (ctx) {
        final isDark = Theme.of(ctx).brightness == Brightness.dark;
        final textPrimary =
            isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;
        return StatefulBuilder(
          builder: (ctx, setLocal) {
            final canSubmit = controller.text.trim().isNotEmpty;
            return AlertDialog(
              backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
              shape:
                  RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
              title: Text('Reject match?',
                  style: TextStyle(
                    fontFamily: 'Manrope',
                    fontWeight: FontWeight.w800,
                    color: textPrimary,
                  )),
              content: TextField(
                controller: controller,
                autofocus: true,
                maxLines: 3,
                onChanged: (_) => setLocal(() {}),
                style: const TextStyle(fontFamily: 'Manrope', fontSize: 13),
                decoration: InputDecoration(
                  hintText: 'Reason for rejecting (required)',
                  hintStyle: TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 13,
                    color: isDark
                        ? AppColors.darkTextTertiary
                        : AppColors.textTertiary,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: const Text('Cancel',
                      style: TextStyle(fontFamily: 'Manrope')),
                ),
                TextButton(
                  onPressed: canSubmit
                      ? () => Navigator.of(ctx).pop(controller.text.trim())
                      : null,
                  child: Text('Reject',
                      style: TextStyle(
                        fontFamily: 'Manrope',
                        color: canSubmit
                            ? AppColors.error
                            : AppColors.textDisabled,
                        fontWeight: FontWeight.w700,
                      )),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _snack(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(fontFamily: 'Manrope')),
        backgroundColor: isError ? AppColors.error : null,
      ),
    );
  }

  String _message(Object e) => e.toString().replaceFirst('Exception: ', '');

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surface = isDark ? AppColors.darkSurface : Colors.white;
    final textPrimary =
        isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;
    final textSecondary =
        isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;
    final isBusy = _busy != null;
    final items = widget.match.matchedItems;

    return Container(
      padding: EdgeInsets.fromLTRB(
        20,
        12,
        20,
        MediaQuery.of(context).padding.bottom + 20,
      ),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: textSecondary.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 18),
          Text('Review match',
              style: TextStyle(
                fontFamily: 'Manrope',
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: textPrimary,
              )),
          const SizedBox(height: 6),
          Text(
            'This sender wants to match with your offer. Accept to open a chat and arrange delivery, or reject with a reason.',
            style: TextStyle(
              fontFamily: 'Manrope',
              fontSize: 13,
              height: 1.5,
              color: textSecondary,
            ),
          ),
          const SizedBox(height: 16),
          ...items.map((it) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  children: [
                    const Icon(Icons.inventory_2_outlined,
                        size: 15, color: AppColors.primary),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '${OfferQty.format(it.quantity)}× ${it.itemName}',
                        style: TextStyle(
                          fontFamily: 'Manrope',
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              )),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: isBusy ? null : _reject,
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(48),
                    side: const BorderSide(color: AppColors.error),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                  child: _busy == 'reject'
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: AppColors.error),
                        )
                      : const Text('Reject',
                          style: TextStyle(
                            fontFamily: 'Manrope',
                            fontWeight: FontWeight.w700,
                            color: AppColors.error,
                          )),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton(
                  onPressed: isBusy ? null : _accept,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    minimumSize: const Size.fromHeight(48),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                  child: _busy == 'accept'
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white),
                        )
                      : const Text('Accept',
                          style: TextStyle(
                            fontFamily: 'Manrope',
                            fontWeight: FontWeight.w700,
                          )),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
