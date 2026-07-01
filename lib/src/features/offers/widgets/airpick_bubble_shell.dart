import 'package:flutter/material.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../core/l10n/l10n.dart';
import '../../../core/theme/app_colors.dart';

// Shared shell + success screens for offer and offer-request creation, now
// presented as a modal bottom sheet.

// ── Bottom sheet entry point ──────────────────────────────────────────────────

// Presents the same [contentBuilder] used by [showAirpickBubble] as a proper
// modal bottom sheet: slides up from the bottom, drag handle, keyboard-aware,
// rounded top corners. The content's `onDismiss` closes the sheet.
Future<void> showAirpickSheet(
  BuildContext context, {
  required Widget Function(VoidCallback onDismiss) contentBuilder,
}) {
  final locale = resolveAppLocale(Localizations.localeOf(context));
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black.withValues(alpha: 0.35),
    builder: (sheetCtx) {
      void dismiss() => Navigator.of(sheetCtx).pop();
      return Localizations(
        locale: locale,
        delegates: AppLocalizations.localizationsDelegates,
        child: AirpickSheetShell(content: contentBuilder(dismiss)),
      );
    },
  );
}

// ── Bottom sheet shell ────────────────────────────────────────────────────────

class AirpickSheetShell extends StatelessWidget {
  final Widget content;

  const AirpickSheetShell({super.key, required this.content});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.darkSurface : Colors.white;
    final media = MediaQuery.of(context);
    // Cap the sheet so it never fully covers the screen, but let it grow with
    // the keyboard via viewInsets padding below.
    final maxHeight = media.size.height * 0.92;

    return Padding(
      // Push content above the keyboard when a field is focused.
      padding: EdgeInsets.only(bottom: media.viewInsets.bottom),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: maxHeight),
        child: Container(
          decoration: BoxDecoration(
            color: bg,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Drag handle
              Padding(
                padding: const EdgeInsets.only(top: 10, bottom: 4),
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppColors.darkBorder
                        : const Color(0xFFE2E8F0),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Flexible(
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(24),
                  ),
                  child: content,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Shared success screen (reused by both bubble types) ───────────────────────

class BubbleSuccessScreen extends StatefulWidget {
  final bool isDark;
  final VoidCallback onDismiss;
  final String title;
  final String subtitle;

  const BubbleSuccessScreen({
    super.key,
    required this.isDark,
    required this.onDismiss,
    required this.title,
    required this.subtitle,
  });

  @override
  State<BubbleSuccessScreen> createState() => _BubbleSuccessScreenState();
}

class _BubbleSuccessScreenState extends State<BubbleSuccessScreen> {
  int _countdown = 1;

  @override
  void initState() {
    super.initState();
    _tick();
  }

  void _tick() {
    Future.delayed(const Duration(seconds: 1), () {
      if (!mounted) return;
      if (_countdown <= 1) {
        widget.onDismiss();
      } else {
        setState(() => _countdown--);
        _tick();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final textPrimary =
        widget.isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;
    final textSecondary =
        widget.isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 700),
              curve: Curves.elasticOut,
              builder: (_, v, child) =>
                  Transform.scale(scale: v, child: child),
              child: Container(
                width: 76,
                height: 76,
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check_rounded,
                    size: 44, color: AppColors.success),
              ),
            ),
            const SizedBox(height: 20),
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeOut,
              builder: (_, v, child) => Opacity(opacity: v, child: child),
              child: Text(
                widget.title,
                style: TextStyle(
                  fontFamily: 'Manrope',
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: textPrimary,
                  letterSpacing: -0.4,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              widget.subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontFamily: 'Manrope', fontSize: 12, color: textSecondary),
            ),
            const SizedBox(height: 24),
            BubbleCountdownRing(countdown: _countdown),
            const SizedBox(height: 8),
            Text(
              'Closing in $_countdown...',
              style: TextStyle(
                  fontFamily: 'Manrope', fontSize: 11, color: textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}

class BubbleCountdownRing extends StatelessWidget {
  final int countdown;
  const BubbleCountdownRing({super.key, required this.countdown});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      key: ValueKey(countdown),
      tween: Tween(begin: 1.0, end: 0.0),
      duration: const Duration(seconds: 1),
      curve: Curves.linear,
      builder: (_, v, _) => SizedBox(
        width: 36,
        height: 36,
        child: Stack(
          alignment: Alignment.center,
          children: [
            CircularProgressIndicator(
              value: v,
              strokeWidth: 3,
              backgroundColor: AppColors.success.withValues(alpha: 0.15),
              valueColor:
                  const AlwaysStoppedAnimation<Color>(AppColors.success),
            ),
            Text(
              '$countdown',
              style: const TextStyle(
                fontFamily: 'Manrope',
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppColors.success,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
