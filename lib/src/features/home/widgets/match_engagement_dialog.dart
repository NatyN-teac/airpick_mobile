import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_colors.dart';
import '../cubit/engagement_cubit.dart';
import '../models/engagement_models.dart';

class MatchEngagementDialog {
  MatchEngagementDialog._();

  static Future<void> show(
    BuildContext context, {
    required EngagementListItem item,
    MatchEngagement? match,
  }) {
    final engagementCubit = context.read<EngagementCubit>();
    // Accept/Reject is a carrier-only action; the engagement response mode tells
    // us the viewer's role for these matches.
    final isCarrier = (engagementCubit.state.mode ?? '').toUpperCase() == 'CARRIER';
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (_) => BlocProvider.value(
        value: engagementCubit,
        child: _MatchEngagementDialogBody(
          item: item,
          match: match,
          isCarrier: isCarrier,
        ),
      ),
    );
  }
}

class _MatchEngagementDialogBody extends StatefulWidget {
  final EngagementListItem item;
  final MatchEngagement? match;
  final bool isCarrier;

  const _MatchEngagementDialogBody({
    required this.item,
    required this.match,
    required this.isCarrier,
  });

  @override
  State<_MatchEngagementDialogBody> createState() =>
      _MatchEngagementDialogBodyState();
}

class _MatchEngagementDialogBodyState
    extends State<_MatchEngagementDialogBody> {
  String? _busyAction; // 'accept' | 'reject'

  bool get _isPending =>
      (widget.match?.status ?? '').toUpperCase() == 'PENDING';

  // The carrier can accept/reject only while the match is still PENDING.
  bool get _canRespond =>
      widget.isCarrier && _isPending && widget.match != null;

  Future<void> _accept() async {
    final confirmed = await _confirm(
      title: 'Accept match?',
      message:
          'This accepts the match and opens a chat with the sender. You can then arrange pickup.',
      confirmLabel: 'Accept',
    );
    if (confirmed != true || !mounted) return;

    setState(() => _busyAction = 'accept');
    try {
      await context.read<EngagementCubit>().acceptMatch(widget.match!.id);
      if (!mounted) return;
      Navigator.of(context).pop();
      _snack('Match accepted');
    } catch (e) {
      if (!mounted) return;
      setState(() => _busyAction = null);
      _snack(_message(e), isError: true);
    }
  }

  Future<void> _reject() async {
    final reason = await _askReason();
    if (reason == null || !mounted) return; // cancelled

    setState(() => _busyAction = 'reject');
    try {
      await context.read<EngagementCubit>().rejectMatch(widget.match!.id, reason);
      if (!mounted) return;
      Navigator.of(context).pop();
      _snack('Match rejected');
    } catch (e) {
      if (!mounted) return;
      setState(() => _busyAction = null);
      _snack(_message(e), isError: true);
    }
  }

  // The backend requires a rejection reason, so collect one before rejecting.
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
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18)),
              title: Text(
                'Reject match?',
                style: TextStyle(
                  fontFamily: 'Manrope',
                  fontWeight: FontWeight.w800,
                  color: textPrimary,
                ),
              ),
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
                  child: Text(
                    'Reject',
                    style: TextStyle(
                      fontFamily: 'Manrope',
                      color: canSubmit ? AppColors.error : AppColors.textDisabled,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<bool?> _confirm({
    required String title,
    required String message,
    required String confirmLabel,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (ctx) {
        final isDark = Theme.of(ctx).brightness == Brightness.dark;
        final textPrimary =
            isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;
        return AlertDialog(
          backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          title: Text(
            title,
            style: TextStyle(
              fontFamily: 'Manrope',
              fontWeight: FontWeight.w800,
              color: textPrimary,
            ),
          ),
          content: Text(
            message,
            style: const TextStyle(
                fontFamily: 'Manrope', fontSize: 13, height: 1.5),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text('Cancel',
                  style: TextStyle(fontFamily: 'Manrope')),
            ),
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              child: Text(
                confirmLabel,
                style: const TextStyle(
                  fontFamily: 'Manrope',
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
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
    final bg = isDark ? AppColors.darkSurface : Colors.white;
    final textPrimary =
        isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;
    final textSecondary =
        isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;
    final item = widget.item;
    final match = widget.match;
    final isBusy = _busyAction != null;

    return Dialog(
      backgroundColor: bg,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 28),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(22, 22, 22, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.handshake_outlined,
                  color: AppColors.success, size: 28),
            ),
            const SizedBox(height: 14),
            Text(
              'Match',
              style: TextStyle(
                fontFamily: 'Manrope',
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              item.status.label,
              style: TextStyle(
                fontFamily: 'Manrope',
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: item.status.color,
              ),
            ),
            const SizedBox(height: 14),
            Text(
              item.title,
              style: TextStyle(
                fontFamily: 'Manrope',
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              item.subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Manrope',
                fontSize: 12,
                color: textSecondary,
              ),
            ),
            if (match?.chatId != null && match!.chatId!.isNotEmpty) ...[
              const SizedBox(height: 10),
              Text(
                'Chat is ready for this match.',
                style: TextStyle(
                  fontFamily: 'Manrope',
                  fontSize: 11.5,
                  color: textSecondary,
                ),
              ),
            ],
            const SizedBox(height: 12),
            if (_canRespond)
              // Carrier is being asked to accept or reject this pending match.
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.info.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'This sender wants to match with your offer. Accept to open a chat and arrange delivery, or reject with a reason.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 11.5,
                    height: 1.45,
                    color: textSecondary,
                  ),
                ),
              )
            else
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkBackground : AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Delivery and cancellation for matches will be handled in a dedicated flow soon.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 11.5,
                    height: 1.45,
                    color: textSecondary,
                  ),
                ),
              ),
            const SizedBox(height: 16),
            if (_canRespond)
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: isBusy ? null : _reject,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.error,
                        side: BorderSide(
                            color: AppColors.error.withValues(alpha: 0.45)),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                        minimumSize: const Size(0, 48),
                      ),
                      child: _busyAction == 'reject'
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text(
                              'Reject',
                              style: TextStyle(
                                fontFamily: 'Manrope',
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: isBusy ? null : _accept,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                        minimumSize: const Size(0, 48),
                      ),
                      child: _busyAction == 'accept'
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text(
                              'Accept',
                              style: TextStyle(
                                fontFamily: 'Manrope',
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            TextButton(
              onPressed: isBusy ? null : () => Navigator.of(context).pop(),
              child: Text(
                'Close',
                style: TextStyle(
                  fontFamily: 'Manrope',
                  color: textSecondary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
