import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/app_refresh_bus.dart';
import '../models/delivery_track_models.dart';
import '../models/match_models.dart';
import '../repository/match_repository.dart';

/// Opens the delivery detail where a carrier progresses a match through pickup →
/// in-transit → delivered. The sender sees the same view, read-only.
Future<void> openDeliveryDetail(
  BuildContext context,
  MatchResponse match, {
  required bool viewerIsCarrier,
}) {
  final repo = context.read<MatchRepository>();
  return Navigator.of(context).push(
    MaterialPageRoute(
      builder: (_) => DeliveryDetailScreen(
        match: match,
        viewerIsCarrier: viewerIsCarrier,
        repository: repo,
      ),
    ),
  );
}

class DeliveryDetailScreen extends StatefulWidget {
  final MatchResponse match;
  final bool viewerIsCarrier;
  final MatchRepository repository;

  const DeliveryDetailScreen({
    super.key,
    required this.match,
    required this.viewerIsCarrier,
    required this.repository,
  });

  @override
  State<DeliveryDetailScreen> createState() => _DeliveryDetailScreenState();
}

class _DeliveryDetailScreenState extends State<DeliveryDetailScreen> {
  final _picker = ImagePicker();
  late MatchResponse _match = widget.match;
  bool _busy = false;
  bool _loadingId = false;

  // 0=awaiting pickup, 1=picked up, 2=in transit, 3=carrier delivered
  // (awaiting sender confirmation), 4=confirmed/complete.
  int get _stage =>
      deliveryStageForStatus(_match.status, _match.hasPickupPhoto);

  String? get _routeLabel {
    final from = _match.pickupArea?.trim();
    final to = _match.deliveryArea?.trim();
    if (from != null && from.isNotEmpty && to != null && to.isNotEmpty) {
      return '$from  →  $to';
    }
    return from?.isNotEmpty == true ? from : to;
  }

  Future<void> _runAction(Future<MatchResponse> Function() action) async {
    setState(() => _busy = true);
    try {
      final updated = await action();
      if (!mounted) return;
      setState(() {
        _match = updated;
        _busy = false;
      });
      // Keep the delivery list's chip + progress bar in sync.
      AppRefreshBus.instance.emit(RefreshTopic.deliveries);
    } catch (e) {
      if (!mounted) return;
      setState(() => _busy = false);
      _snack(e.toString().replaceFirst('Exception: ', ''), isError: true);
    }
  }

  Future<void> _confirmPickup() async {
    final source = await _chooseSource();
    if (source == null || !mounted) return;
    final file = await _picker.pickImage(source: source, imageQuality: 85);
    if (file == null || !mounted) return;
    await _runAction(
      () => widget.repository.uploadPickupPhoto(_match.id, File(file.path)),
    );
    if (mounted) _snack('Pickup confirmed');
  }

  Future<void> _startDelivery() async {
    await _runAction(() => widget.repository.startMatch(_match.id));
    if (mounted) _snack('Delivery started');
  }

  Future<void> _markDelivered() async {
    await _runAction(() => widget.repository.completeMatch(_match.id));
    if (mounted) _snack('Marked as delivered — awaiting confirmation');
  }

  // Sender confirms the carrier's delivery, completing the match.
  Future<void> _confirmDelivery() async {
    await _runAction(() => widget.repository.confirmDelivery(_match.id));
    if (mounted) _snack('Delivery confirmed');
  }

  // Fetch a fresh short-lived signed URL for the receiver's ID and open it
  // full-screen so the carrier can compare it against the person in front of them.
  Future<void> _viewReceiverId() async {
    setState(() => _loadingId = true);
    try {
      final url = await widget.repository.getReceiverIdPhotoUrl(_match.id);
      if (!mounted) return;
      setState(() => _loadingId = false);
      await showReceiverIdViewer(context, url, receiver: _match.receiver);
    } catch (e) {
      if (!mounted) return;
      setState(() => _loadingId = false);
      _snack(e.toString().replaceFirst('Exception: ', ''), isError: true);
    }
  }

  Future<ImageSource?> _chooseSource() {
    return showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final isDark = Theme.of(ctx).brightness == Brightness.dark;
        final bg = isDark ? AppColors.darkSurface : Colors.white;
        return Container(
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 24),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(16),
          ),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.photo_library_outlined),
                  title: const Text('Photo library',
                      style: TextStyle(fontFamily: 'Manrope')),
                  onTap: () => Navigator.pop(ctx, ImageSource.gallery),
                ),
                ListTile(
                  leading: const Icon(Icons.camera_alt_outlined),
                  title: const Text('Camera',
                      style: TextStyle(fontFamily: 'Manrope')),
                  onTap: () => Navigator.pop(ctx, ImageSource.camera),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _snack(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(fontFamily: 'Manrope')),
        backgroundColor: isError ? AppColors.error : null,
      ),
    );
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
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Delivery',
          style: TextStyle(
            fontFamily: 'Manrope',
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: textPrimary,
            letterSpacing: -0.3,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
        children: [
          if (_routeLabel != null) ...[
            Text(
              _routeLabel!,
              style: TextStyle(
                fontFamily: 'Manrope',
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: textPrimary,
              ),
            ),
            const SizedBox(height: 16),
          ],
          _StageTracker(stage: _stage, isDark: isDark),
          const SizedBox(height: 20),
          _SectionLabel('Items', textSecondary: textSecondary),
          const SizedBox(height: 8),
          ..._match.matchedItems.map(
            (it) => _ItemRow(
              name: it.itemName,
              trailing:
                  '${_fmtQty(it.quantity)} × \$${it.pricePerItem.toStringAsFixed(2)}',
              isDark: isDark,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Total',
                  style: TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: textSecondary,
                  )),
              Text('\$${_match.totalPrice.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: textPrimary,
                  )),
            ],
          ),
          // Receiver ID check — only for the carrier, only while delivering
          // (in transit), and only when a third-party receiver was designated.
          if (widget.viewerIsCarrier &&
              _match.receiverNeeded &&
              _stage == 2) ...[
            const SizedBox(height: 24),
            _ReceiverVerifyCard(
              receiver: _match.receiver,
              loading: _loadingId,
              isDark: isDark,
              onView: _viewReceiverId,
            ),
          ],
          const SizedBox(height: 24),
          _buildAction(isDark, textSecondary),
        ],
      ),
    );
  }

  // Carrier: one action per stage (through "mark delivered"). Sender: a confirm
  // action once the carrier has delivered, otherwise a read-only note.
  Widget _buildAction(bool isDark, Color textSecondary) {
    if (!widget.viewerIsCarrier) {
      if (_stage == 3) {
        return _ActionButton(
          label: 'Confirm delivery',
          busy: _busy,
          onPressed: _confirmDelivery,
        );
      }
      return _ReadOnlyNote(stage: _stage, isDark: isDark);
    }
    return switch (_stage) {
      0 => _ActionButton(
          label: 'Confirm pickup',
          busy: _busy,
          onPressed: _confirmPickup,
        ),
      1 => _ActionButton(
          label: 'Start delivery',
          busy: _busy,
          onPressed: _startDelivery,
        ),
      2 => _ActionButton(
          label: 'Mark as delivered',
          busy: _busy,
          onPressed: _markDelivered,
        ),
      _ => _ReadOnlyNote(stage: _stage, isDark: isDark),
    };
  }

  String _fmtQty(double q) => q % 1 == 0 ? q.toStringAsFixed(0) : q.toString();
}

class _StageTracker extends StatelessWidget {
  final int stage; // 0..4
  final bool isDark;
  const _StageTracker({required this.stage, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final track = isDark ? AppColors.darkBorder : const Color(0xFFEEF0F3);
    final textSecondary =
        isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: List.generate(deliveryStageLabels.length, (i) {
            final isActive = i <= stage;
            return Expanded(
              child: Padding(
                padding: EdgeInsets.only(left: i == 0 ? 0 : 4),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  height: 5,
                  decoration: BoxDecoration(
                    color: isActive ? AppColors.primary : track,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 8),
        Row(
          children: List.generate(deliveryStageLabels.length, (i) {
            final isActive = i <= stage;
            return Expanded(
              child: Text(
                deliveryStageLabels[i],
                textAlign: i == 0
                    ? TextAlign.left
                    : (i == deliveryStageLabels.length - 1
                        ? TextAlign.right
                        : TextAlign.center),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontFamily: 'Manrope',
                  fontSize: 9,
                  fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                  color: isActive ? AppColors.primary : textSecondary,
                ),
              ),
            );
          }),
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final bool busy;
  final VoidCallback onPressed;
  const _ActionButton({
    required this.label,
    required this.busy,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: busy ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
        child: busy
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                    strokeWidth: 2, color: Colors.white),
              )
            : Text(label,
                style: const TextStyle(
                    fontFamily: 'Manrope', fontWeight: FontWeight.w700)),
      ),
    );
  }
}

class _ReadOnlyNote extends StatelessWidget {
  final int stage;
  final bool isDark;
  const _ReadOnlyNote({required this.stage, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final textSecondary =
        isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;
    final msg = switch (stage) {
      0 => 'Waiting for the carrier to confirm pickup.',
      1 => 'The carrier has picked up your items.',
      2 => 'Your items are on the way.',
      3 => 'Delivered — waiting for the sender to confirm.',
      _ => 'This delivery is complete.',
    };
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        msg,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontFamily: 'Manrope',
          fontSize: 12.5,
          height: 1.4,
          color: textSecondary,
        ),
      ),
    );
  }
}

/// Prompts the carrier to check the receiver's ID before marking delivered.
class _ReceiverVerifyCard extends StatelessWidget {
  final MatchReceiverInfo? receiver;
  final bool loading;
  final bool isDark;
  final VoidCallback onView;

  const _ReceiverVerifyCard({
    required this.receiver,
    required this.loading,
    required this.isDark,
    required this.onView,
  });

  @override
  Widget build(BuildContext context) {
    final textPrimary =
        isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;
    final textSecondary =
        isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;
    final name = receiver?.fullName ?? '';
    final phone = receiver?.phone ?? '';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.warning.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.warning.withValues(alpha: 0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.badge_outlined,
                  size: 18, color: AppColors.warning),
              const SizedBox(width: 8),
              Text(
                'Verify receiver',
                style: TextStyle(
                  fontFamily: 'Manrope',
                  fontSize: 13.5,
                  fontWeight: FontWeight.w800,
                  color: textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Check this ID against the person receiving the items before you '
            'mark the delivery as done.',
            style: TextStyle(
              fontFamily: 'Manrope',
              fontSize: 12,
              height: 1.4,
              color: textSecondary,
            ),
          ),
          if (name.isNotEmpty || phone.isNotEmpty) ...[
            const SizedBox(height: 12),
            if (name.isNotEmpty)
              _kv(Icons.person_outline_rounded, name, textPrimary,
                  textSecondary),
            if (phone.isNotEmpty)
              _kv(Icons.phone_outlined, phone, textPrimary, textSecondary),
          ],
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            height: 46,
            child: OutlinedButton.icon(
              onPressed: loading ? null : onView,
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.warning,
                side: BorderSide(
                    color: AppColors.warning.withValues(alpha: 0.6)),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              icon: loading
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: AppColors.warning),
                    )
                  : const Icon(Icons.image_outlined, size: 18),
              label: const Text(
                'View ID photo',
                style: TextStyle(
                    fontFamily: 'Manrope', fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _kv(IconData icon, String value, Color primary, Color secondary) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Icon(icon, size: 15, color: secondary),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontFamily: 'Manrope',
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Full-screen, zoomable viewer for the receiver's ID photo (signed URL).
Future<void> showReceiverIdViewer(
  BuildContext context,
  String url, {
  MatchReceiverInfo? receiver,
}) {
  final title = receiver?.fullName.isNotEmpty == true
      ? receiver!.fullName
      : 'Receiver ID';
  return Navigator.of(context).push(
    MaterialPageRoute(
      fullscreenDialog: true,
      builder: (_) => Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
          elevation: 0,
          title: Text(
            title,
            style: const TextStyle(
              fontFamily: 'Manrope',
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ),
        body: Center(
          child: InteractiveViewer(
            minScale: 0.8,
            maxScale: 4,
            child: Image.network(
              url,
              fit: BoxFit.contain,
              loadingBuilder: (ctx, child, progress) {
                if (progress == null) return child;
                return const CircularProgressIndicator(color: Colors.white);
              },
              errorBuilder: (ctx, error, stack) => const Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  'Could not load the ID photo. The link may have expired — '
                  'close and try again.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontFamily: 'Manrope', color: Colors.white70, height: 1.4),
                ),
              ),
            ),
          ),
        ),
      ),
    ),
  );
}

class _SectionLabel extends StatelessWidget {
  final String text;
  final Color textSecondary;
  const _SectionLabel(this.text, {required this.textSecondary});

  @override
  Widget build(BuildContext context) => Text(
        text.toUpperCase(),
        style: TextStyle(
          fontFamily: 'Manrope',
          fontSize: 11,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.6,
          color: textSecondary,
        ),
      );
}

class _ItemRow extends StatelessWidget {
  final String name;
  final String trailing;
  final bool isDark;
  const _ItemRow({
    required this.name,
    required this.trailing,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final textPrimary =
        isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;
    final textSecondary =
        isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : AppColors.surface,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(name,
                  style: TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    color: textPrimary,
                  )),
            ),
            Text(trailing,
                style: TextStyle(
                  fontFamily: 'Manrope',
                  fontSize: 11,
                  color: textSecondary,
                )),
          ],
        ),
      ),
    );
  }
}
