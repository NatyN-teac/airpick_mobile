import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/l10n/l10n.dart';
import '../../../core/theme/app_colors.dart';

class AppNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final Map<int, int> badgeCounts;
  // Label for the center tab (index 2). Switches with sender/carrier mode.
  final String centerLabel;

  const AppNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    this.badgeCounts = const {},
    required this.centerLabel,
  });

  void _onTabTap(int index) {
    HapticFeedback.lightImpact();
    onTap(index);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l = l10n(context);

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
                  label: l.navHome,
                  index: 0,
                  currentIndex: currentIndex,
                  badgeCount: badgeCounts[0] ?? 0,
                  onTap: _onTabTap,
                  isDark: isDark,
                ),
                _NavItem(
                  icon: CupertinoIcons.chat_bubble,
                  iconFilled: CupertinoIcons.chat_bubble_fill,
                  label: l.navChat,
                  index: 1,
                  currentIndex: currentIndex,
                  badgeCount: badgeCounts[1] ?? 0,
                  onTap: _onTabTap,
                  isDark: isDark,
                ),
                _NavItem(
                  icon: CupertinoIcons.square_list,
                  iconFilled: CupertinoIcons.square_list_fill,
                  label: centerLabel,
                  index: 2,
                  currentIndex: currentIndex,
                  badgeCount: badgeCounts[2] ?? 0,
                  onTap: _onTabTap,
                  isDark: isDark,
                ),
                _NavItem(
                  icon: CupertinoIcons.bell,
                  iconFilled: CupertinoIcons.bell_fill,
                  label: l.navAlerts,
                  index: 3,
                  currentIndex: currentIndex,
                  badgeCount: badgeCounts[3] ?? 0,
                  onTap: _onTabTap,
                  isDark: isDark,
                ),
                _NavItem(
                  icon: CupertinoIcons.person,
                  iconFilled: CupertinoIcons.person_fill,
                  label: l.navProfile,
                  index: 4,
                  currentIndex: currentIndex,
                  badgeCount: badgeCounts[4] ?? 0,
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
