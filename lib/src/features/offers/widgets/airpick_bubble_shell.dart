import 'package:flutter/material.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../core/l10n/l10n.dart';
import '../../../core/theme/app_colors.dart';

// Shared bottle-shaped bubble shell used by both offer creation and offer-request creation.

const double kBubbleW = 340.0;
const double kBubbleH = 680.0;
const double kTipH = 54.0;
const double kTotalH = kBubbleH + kTipH;

// ── Entry point ───────────────────────────────────────────────────────────────

Future<void> showAirpickBubble(
  BuildContext context, {
  required GlobalKey plusKey,
  required Widget Function(VoidCallback onDismiss) contentBuilder,
}) async {
  final renderBox =
      plusKey.currentContext?.findRenderObject() as RenderBox?;
  if (renderBox == null) return;

  final buttonSize = renderBox.size;
  final buttonPos = renderBox.localToGlobal(Offset.zero);
  final double buttonCenterX = buttonPos.dx + buttonSize.width / 2;
  final double buttonTopY = buttonPos.dy;
  final locale = resolveAppLocale(Localizations.localeOf(context));

  await showGeneralDialog(
    context: context,
    barrierDismissible: false,
    barrierColor: Colors.black.withValues(alpha: 0.35),
    barrierLabel: '',
    transitionDuration: const Duration(milliseconds: 300),
    pageBuilder: (dialogCtx, _, __) {
      final dismiss = () => Navigator.of(dialogCtx).pop();
      return Localizations(
        locale: locale,
        delegates: AppLocalizations.localizationsDelegates,
        child: Material(
          type: MaterialType.transparency,
          child: AirpickBubbleLayout(
            buttonCenterX: buttonCenterX,
            buttonTopY: buttonTopY,
            onDismiss: dismiss,
            content: contentBuilder(dismiss),
          ),
        ),
      );
    },
    transitionBuilder: (_, animation, __, child) => FadeTransition(
      opacity: CurvedAnimation(parent: animation, curve: Curves.easeOut),
      child: ScaleTransition(
        scale: CurvedAnimation(parent: animation, curve: Curves.easeOutBack),
        alignment: Alignment.bottomCenter,
        child: child,
      ),
    ),
  );
}

// ── Layout ────────────────────────────────────────────────────────────────────

class AirpickBubbleLayout extends StatelessWidget {
  final double buttonCenterX;
  final double buttonTopY;
  final VoidCallback onDismiss;
  final Widget content;

  const AirpickBubbleLayout({
    super.key,
    required this.buttonCenterX,
    required this.buttonTopY,
    required this.onDismiss,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    final screenW = MediaQuery.of(context).size.width;
    final double left =
        (buttonCenterX - kBubbleW / 2).clamp(8.0, screenW - kBubbleW - 8.0);
    final double top =
        (buttonTopY - kTotalH + 52).clamp(8.0, double.infinity);

    return Stack(
      children: [
        Positioned(
          left: left,
          top: top,
          width: kBubbleW,
          height: kTotalH,
          child: AirpickBubbleShell(onDismiss: onDismiss, content: content),
        ),
      ],
    );
  }
}

// ── Shell ─────────────────────────────────────────────────────────────────────

class AirpickBubbleShell extends StatelessWidget {
  final VoidCallback onDismiss;
  final Widget content;

  const AirpickBubbleShell({
    super.key,
    required this.onDismiss,
    required this.content,
  });

  static const double _btnSize = 44.0;
  static const double _neckR = 26.0;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.darkSurface : Colors.white;

    return CustomPaint(
      painter: AirpickBubblePainter(color: bg, isDark: isDark),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: kTipH),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: content,
            ),
          ),
          Positioned(
            left: kBubbleW / 2 - _btnSize / 2,
            top: kTotalH - _neckR - _btnSize / 2,
            child: GestureDetector(
              onTap: onDismiss,
              child: Container(
                width: _btnSize,
                height: _btnSize,
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.close_rounded,
                    size: 20, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Painter ───────────────────────────────────────────────────────────────────

class AirpickBubblePainter extends CustomPainter {
  final Color color;
  final bool isDark;
  AirpickBubblePainter({required this.color, required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    const cornerR = 20.0;
    const neckW = 52.0;
    const neckR = neckW / 2;
    final cx = size.width / 2;
    final bodyH = size.height - kTipH;
    final shoulderY = bodyH + kTipH * 0.46;

    final path = Path();
    path.moveTo(cornerR, 0);
    path.lineTo(size.width - cornerR, 0);
    path.arcToPoint(Offset(size.width, cornerR),
        radius: const Radius.circular(cornerR));
    path.lineTo(size.width, bodyH);
    path.cubicTo(size.width, bodyH + kTipH * 0.18,
        cx + neckR, shoulderY, cx + neckR, shoulderY);
    path.lineTo(cx + neckR, size.height - neckR);
    path.arcToPoint(Offset(cx - neckR, size.height - neckR),
        radius: const Radius.circular(neckR), clockwise: false);
    path.lineTo(cx - neckR, shoulderY);
    path.cubicTo(cx - neckR, shoulderY, 0, bodyH + kTipH * 0.18, 0, bodyH);
    path.lineTo(0, cornerR);
    path.arcToPoint(const Offset(cornerR, 0),
        radius: const Radius.circular(cornerR));
    path.close();

    canvas.drawShadow(
        path,
        Colors.black.withValues(alpha: isDark ? 0.45 : 0.12),
        18,
        true);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(AirpickBubblePainter old) =>
      old.color != color || old.isDark != isDark;
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
  int _countdown = 3;

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
      builder: (_, v, __) => SizedBox(
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
