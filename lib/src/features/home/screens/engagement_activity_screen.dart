import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

enum EngagementActivityFilter { proposals, matched }

class EngagementActivityScreen extends StatefulWidget {
  final EngagementActivityFilter initialFilter;

  const EngagementActivityScreen({
    super.key,
    this.initialFilter = EngagementActivityFilter.proposals,
  });

  @override
  State<EngagementActivityScreen> createState() =>
      _EngagementActivityScreenState();
}

class _EngagementActivityScreenState extends State<EngagementActivityScreen> {
  late EngagementActivityFilter _filter;

  @override
  void initState() {
    super.initState();
    _filter = widget.initialFilter;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.darkBackground : AppColors.background;
    final textPrimary =
        isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;
    final textSecondary =
        isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;
    final items = _filter == EngagementActivityFilter.proposals
        ? _sampleProposals
        : _sampleMatches;

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(
            'Cancel',
            style: TextStyle(
              fontFamily: 'Manrope',
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: textPrimary,
            ),
          ),
        ),
        leadingWidth: 72,
        title: Text(
          'View all',
          style: TextStyle(
            fontFamily: 'Manrope',
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: textPrimary,
            letterSpacing: -0.3,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: _FilterBar(
              selected: _filter,
              isDark: isDark,
              onChanged: (f) => setState(() => _filter = f),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              _filter == EngagementActivityFilter.proposals
                  ? 'Your proposals — sample preview until API is connected.'
                  : 'Your matches — sample preview until API is connected.',
              style: TextStyle(
                fontFamily: 'Manrope',
                fontSize: 11.5,
                color: textSecondary,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 28),
              itemCount: items.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (_, i) => _SampleActivityCard(
                item: items[i],
                isDark: isDark,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterBar extends StatelessWidget {
  final EngagementActivityFilter selected;
  final bool isDark;
  final ValueChanged<EngagementActivityFilter> onChanged;

  const _FilterBar({
    required this.selected,
    required this.isDark,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.surface,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          _FilterChip(
            label: 'Proposals',
            selected: selected == EngagementActivityFilter.proposals,
            isDark: isDark,
            onTap: () => onChanged(EngagementActivityFilter.proposals),
          ),
          _FilterChip(
            label: 'Matched',
            selected: selected == EngagementActivityFilter.matched,
            isDark: isDark,
            onTap: () => onChanged(EngagementActivityFilter.matched),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final bool isDark;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.selected,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: selected ? AppColors.secondary : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              fontFamily: 'Manrope',
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
              color: selected
                  ? Colors.white
                  : (isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.textSecondary),
            ),
          ),
        ),
      ),
    );
  }
}

class _SampleActivityItem {
  final String title;
  final String route;
  final String subtitle;
  final String status;
  final Color statusColor;

  const _SampleActivityItem({
    required this.title,
    required this.route,
    required this.subtitle,
    required this.status,
    required this.statusColor,
  });
}

const _sampleProposals = [
  _SampleActivityItem(
    title: 'Electronics bundle',
    route: 'JFK → LHR',
    subtitle: 'Manhattan → London · \$120.00',
    status: 'Pending',
    statusColor: AppColors.info,
  ),
  _SampleActivityItem(
    title: 'Documents',
    route: 'CDG → JFK',
    subtitle: 'Paris → Brooklyn · \$45.00',
    status: 'Sent',
    statusColor: Color(0xFF4299E1),
  ),
  _SampleActivityItem(
    title: 'Clothing box',
    route: 'LAX → NRT',
    subtitle: 'LA → Tokyo · \$89.50',
    status: 'Viewed',
    statusColor: Color(0xFF9F7AEA),
  ),
];

const _sampleMatches = [
  _SampleActivityItem(
    title: 'Laptop + charger',
    route: 'SFO → SIN',
    subtitle: 'Receiver: Alex M. · \$210.00',
    status: 'Matched',
    statusColor: AppColors.success,
  ),
  _SampleActivityItem(
    title: 'Gift package',
    route: 'ORD → MIA',
    subtitle: 'Receiver: Sam K. · \$55.00',
    status: 'In progress',
    statusColor: AppColors.warning,
  ),
];

class _SampleActivityCard extends StatelessWidget {
  final _SampleActivityItem item;
  final bool isDark;

  const _SampleActivityCard({required this.item, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final surface = isDark ? AppColors.darkSurface : AppColors.surface;
    final textPrimary =
        isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;
    final textSecondary =
        isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.borderLight,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: item.statusColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              item.status == 'Matched' || item.status == 'In progress'
                  ? Icons.handshake_outlined
                  : Icons.mail_outline_rounded,
              color: item.statusColor,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        item.title,
                        style: TextStyle(
                          fontFamily: 'Manrope',
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: textPrimary,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: item.statusColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        item.status,
                        style: TextStyle(
                          fontFamily: 'Manrope',
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: item.statusColor,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '${item.route} · ${item.subtitle}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 11,
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
