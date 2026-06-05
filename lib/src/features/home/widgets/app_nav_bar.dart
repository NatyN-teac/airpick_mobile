import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/app_colors.dart';

class AppNavBar extends StatefulWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final Map<int, int> badgeCounts;
  final VoidCallback? onPlusTap;
  final GlobalKey? plusKey;

  const AppNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    this.badgeCounts = const {},
    this.onPlusTap,
    this.plusKey,
  });

  @override
  State<AppNavBar> createState() => _AppNavBarState();
}

class _AppNavBarState extends State<AppNavBar> with TickerProviderStateMixin {
  late AnimationController _plusController;
  late Animation<double> _plusScale;

  @override
  void initState() {
    super.initState();
    _plusController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _plusScale = Tween<double>(begin: 1.0, end: 0.88).animate(
      CurvedAnimation(parent: _plusController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _plusController.dispose();
    super.dispose();
  }

  void _onPlusTap() {
    HapticFeedback.mediumImpact();
    _plusController.forward().then((_) => _plusController.reverse());
    widget.onPlusTap?.call();
  }

  void _onTabTap(int index) {
    HapticFeedback.lightImpact();
    widget.onTap(index);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkBackground : AppColors.background,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.4 : 0.08),
            blurRadius: 24,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 64,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              children: [
                _NavItem(
                  icon: CupertinoIcons.house,
                  iconFilled: CupertinoIcons.house_fill,
                  label: 'Home',
                  index: 0,
                  currentIndex: widget.currentIndex,
                  badgeCount: widget.badgeCounts[0] ?? 0,
                  onTap: _onTabTap,
                  isDark: isDark,
                ),
                _NavItem(
                  icon: CupertinoIcons.chat_bubble,
                  iconFilled: CupertinoIcons.chat_bubble_fill,
                  label: 'Chat',
                  index: 1,
                  currentIndex: widget.currentIndex,
                  badgeCount: widget.badgeCounts[1] ?? 0,
                  onTap: _onTabTap,
                  isDark: isDark,
                ),
                // Plus button
                Expanded(
                  child: Center(
                    child: GestureDetector(
                      onTap: _onPlusTap,
                      child: AnimatedBuilder(
                        animation: _plusScale,
                        builder: (context, _) => Transform.scale(
                          scale: _plusScale.value,
                          child: Container(
                            key: widget.plusKey,
                            width: 52,
                            height: 52,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: const LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  AppColors.primary,
                                  AppColors.primaryLight,
                                ],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primary
                                      .withValues(alpha: 0.38),
                                  blurRadius: 14,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: const Icon(
                              CupertinoIcons.add,
                              color: Colors.white,
                              size: 26,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                _NavItem(
                  icon: CupertinoIcons.bell,
                  iconFilled: CupertinoIcons.bell_fill,
                  label: 'Alerts',
                  index: 3,
                  currentIndex: widget.currentIndex,
                  badgeCount: widget.badgeCounts[3] ?? 0,
                  onTap: _onTabTap,
                  isDark: isDark,
                ),
                _NavItem(
                  icon: CupertinoIcons.person,
                  iconFilled: CupertinoIcons.person_fill,
                  label: 'Profile',
                  index: 4,
                  currentIndex: widget.currentIndex,
                  badgeCount: widget.badgeCounts[4] ?? 0,
                  onTap: _onTabTap,
                  isDark: isDark,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final IconData iconFilled;
  final String label;
  final int index;
  final int currentIndex;
  final int badgeCount;
  final ValueChanged<int> onTap;
  final bool isDark;

  const _NavItem({
    required this.icon,
    required this.iconFilled,
    required this.label,
    required this.index,
    required this.currentIndex,
    required this.badgeCount,
    required this.onTap,
    required this.isDark,
  });

  bool get _selected => index == currentIndex;

  @override
  Widget build(BuildContext context) {
    final selectedColor = AppColors.primary;
    final unselectedColor =
        isDark ? AppColors.darkTextTertiary : const Color(0xFF9CA3AF);

    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => onTap(index),
        child: SizedBox(
          height: 64,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    child: Icon(
                      _selected ? iconFilled : icon,
                      key: ValueKey(_selected),
                      size: 24,
                      color: _selected ? selectedColor : unselectedColor,
                    ),
                  ),
                  if (badgeCount > 0)
                    Positioned(
                      top: -3,
                      right: -6,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 4, vertical: 1),
                        constraints: const BoxConstraints(
                            minWidth: 16, minHeight: 16),
                        decoration: BoxDecoration(
                          color: AppColors.error,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: isDark
                                ? AppColors.darkBackground
                                : AppColors.background,
                            width: 1.5,
                          ),
                        ),
                        child: Text(
                          badgeCount > 99 ? '99+' : '$badgeCount',
                          style: const TextStyle(
                            fontFamily: 'Manrope',
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 4),
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 200),
                style: TextStyle(
                  fontFamily: 'Manrope',
                  fontSize: 10,
                  fontWeight:
                      _selected ? FontWeight.w700 : FontWeight.w500,
                  color: _selected ? selectedColor : unselectedColor,
                ),
                child: Text(label),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
