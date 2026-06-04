import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final FocusNode _focusNode = FocusNode();
  final TextEditingController _controller = TextEditingController();
  String _query = '';

  static const _popular = [
    ('London', 'LHR', '🇬🇧'),
    ('Dubai', 'DXB', '🇦🇪'),
    ('New York', 'JFK', '🇺🇸'),
    ('Addis Ababa', 'ADD', '🇪🇹'),
    ('Toronto', 'YYZ', '🇨🇦'),
    ('Lagos', 'LOS', '🇳🇬'),
    ('Paris', 'CDG', '🇫🇷'),
    ('Nairobi', 'NBO', '🇰🇪'),
  ];

  static const _recentSearches = [
    'London, United Kingdom',
    'Dubai, UAE',
    'Addis Ababa, Ethiopia',
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.darkBackground : AppColors.background;
    final surface = isDark ? AppColors.darkSurface : AppColors.surface;
    final textPrimary = isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;
    final textSecondary = isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;
    final textTertiary = isDark ? AppColors.darkTextTertiary : AppColors.textTertiary;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.border;

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Search bar ──────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 52,
                      decoration: BoxDecoration(
                        color: surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: _focusNode.hasFocus
                              ? AppColors.primary
                              : borderColor,
                          width: _focusNode.hasFocus ? 1.5 : 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          const SizedBox(width: 14),
                          Icon(Icons.search_rounded,
                              size: 20, color: textTertiary),
                          const SizedBox(width: 10),
                          Expanded(
                            child: TextField(
                              controller: _controller,
                              focusNode: _focusNode,
                              onChanged: (v) => setState(() => _query = v),
                              style: TextStyle(
                                fontFamily: 'Manrope',
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                                color: textPrimary,
                              ),
                              decoration: InputDecoration(
                                hintText:
                                    'Search by country, city or destination',
                                hintStyle: TextStyle(
                                  fontFamily: 'Manrope',
                                  fontSize: 14,
                                  color: textTertiary,
                                ),
                                border: InputBorder.none,
                                isDense: true,
                              ),
                            ),
                          ),
                          if (_query.isNotEmpty)
                            GestureDetector(
                              onTap: () {
                                _controller.clear();
                                setState(() => _query = '');
                              },
                              child: Padding(
                                padding: const EdgeInsets.only(right: 12),
                                child: Icon(Icons.cancel_rounded,
                                    size: 18, color: textTertiary),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Text(
                      'Cancel',
                      style: TextStyle(
                        fontFamily: 'Manrope',
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Recent searches ─────────────────────────────────
                    if (_query.isEmpty) ...[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Recent searches',
                            style: TextStyle(
                              fontFamily: 'Manrope',
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: textSecondary,
                              letterSpacing: 0.2,
                            ),
                          ),
                          GestureDetector(
                            child: Text(
                              'Clear',
                              style: TextStyle(
                                fontFamily: 'Manrope',
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      ..._recentSearches.map(
                        (s) => _RecentItem(
                          label: s,
                          isDark: isDark,
                          surface: surface,
                          textPrimary: textPrimary,
                          textSecondary: textSecondary,
                          onTap: () {
                            _controller.text = s;
                            setState(() => _query = s);
                          },
                        ),
                      ),

                      const SizedBox(height: 28),

                      // ── Popular destinations ──────────────────────────
                      Text(
                        'Popular destinations',
                        style: TextStyle(
                          fontFamily: 'Manrope',
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: textSecondary,
                          letterSpacing: 0.2,
                        ),
                      ),
                      const SizedBox(height: 14),
                      GridView.count(
                        crossAxisCount: 2,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                        childAspectRatio: 2.4,
                        children: _popular
                            .map(
                              (d) => _DestinationChip(
                                city: d.$1,
                                code: d.$2,
                                flag: d.$3,
                                isDark: isDark,
                                surface: surface,
                                textPrimary: textPrimary,
                                textSecondary: textSecondary,
                              ),
                            )
                            .toList(),
                      ),
                    ],

                    // ── Search results placeholder ──────────────────────
                    if (_query.isNotEmpty) ...[
                      Text(
                        'Results for "$_query"',
                        style: TextStyle(
                          fontFamily: 'Manrope',
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: textSecondary,
                        ),
                      ),
                      const SizedBox(height: 40),
                      Center(
                        child: Column(
                          children: [
                            Icon(Icons.search_rounded,
                                size: 52,
                                color: borderColor),
                            const SizedBox(height: 14),
                            Text(
                              'Search results coming soon',
                              style: TextStyle(
                                fontFamily: 'Manrope',
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RecentItem extends StatelessWidget {
  final String label;
  final bool isDark;
  final Color surface, textPrimary, textSecondary;
  final VoidCallback onTap;

  const _RecentItem({
    required this.label,
    required this.isDark,
    required this.surface,
    required this.textPrimary,
    required this.textSecondary,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        decoration: BoxDecoration(
          color: surface,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(Icons.history_rounded, size: 18, color: textSecondary),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontFamily: 'Manrope',
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: textPrimary,
                ),
              ),
            ),
            Icon(Icons.north_west_rounded, size: 14, color: textSecondary),
          ],
        ),
      ),
    );
  }
}

class _DestinationChip extends StatelessWidget {
  final String city, code, flag;
  final bool isDark;
  final Color surface, textPrimary, textSecondary;

  const _DestinationChip({
    required this.city,
    required this.code,
    required this.flag,
    required this.isDark,
    required this.surface,
    required this.textPrimary,
    required this.textSecondary,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Text(flag, style: const TextStyle(fontSize: 18)),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  city,
                  style: TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: textPrimary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  code,
                  style: TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 10,
                    color: textSecondary,
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
