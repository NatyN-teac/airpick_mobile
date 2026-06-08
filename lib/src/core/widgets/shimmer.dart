import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

// Lightweight shimmer (no package). Wrap a subtree of opaque "skeleton" shapes;
// a highlight band sweeps across them to signal loading. One controller.
class Shimmer extends StatefulWidget {
  final Widget child;
  const Shimmer({super.key, required this.child});

  @override
  State<Shimmer> createState() => _ShimmerState();
}

class _ShimmerState extends State<Shimmer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1300),
  )..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final base = isDark ? AppColors.darkBorder : const Color(0xFFE9EDF2);
    final highlight =
        isDark ? const Color(0xFF3E4C63) : const Color(0xFFF6F8FB);

    return AnimatedBuilder(
      animation: _c,
      builder: (context, child) {
        return ShaderMask(
          blendMode: BlendMode.srcATop,
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [base, base, highlight, base, base],
              stops: const [0.0, 0.35, 0.5, 0.65, 1.0],
              tileMode: TileMode.clamp,
              transform: _SlideTransform(_c.value * 2 - 1),
            ).createShader(bounds);
          },
          child: child,
        );
      },
      child: widget.child,
    );
  }
}

class _SlideTransform extends GradientTransform {
  final double slide;
  const _SlideTransform(this.slide);

  @override
  Matrix4? transform(Rect bounds, {TextDirection? textDirection}) =>
      Matrix4.translationValues(bounds.width * slide, 0, 0);
}

// A rounded placeholder block (base colour; the Shimmer paints the sweep on it).
class ShimmerBox extends StatelessWidget {
  final double? width;
  final double height;
  final double radius;
  const ShimmerBox({
    super.key,
    this.width,
    required this.height,
    this.radius = 8,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white, // overwritten by the Shimmer shader (srcATop)
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}
