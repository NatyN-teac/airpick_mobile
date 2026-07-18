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

  // 0=awaiting pickup, 1=picked up, 2=in transit, 3=delivered.
  int get _stage {
    switch (_match.status.toUpperCase()) {
      case 'ACCEPTED':
        return _match.hasPickupPhoto ? 1 : 0;
      case 'IN_PROGRESS':
      case 'IN_DELIVERY':
        return 2;
      case 'COMPLETED':
        return 3;
      default:
        return 0;
    }
  }

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
    if (mounted) _snack('Marked as delivered');
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
          const SizedBox(height: 24),
          _buildAction(isDark, textSecondary),
        ],
      ),
    );
  }

  // Carrier: one action per stage. Sender: a read-only note.
  Widget _buildAction(bool isDark, Color textSecondary) {
    if (!widget.viewerIsCarrier) {
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
  final int stage; // 0..3
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
          children: List.generate(4, (i) {
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
          children: List.generate(4, (i) {
            final isActive = i <= stage;
            return Expanded(
              child: Text(
                deliveryStageLabels[i],
                textAlign: i == 0
                    ? TextAlign.left
                    : (i == 3 ? TextAlign.right : TextAlign.center),
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
