import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

// ── Offer item model ──────────────────────────────────────────────────────────

enum _ItemStatus { available, limited, full }

extension _ItemStatusX on _ItemStatus {
  String get label => switch (this) {
        _ItemStatus.available => 'Available',
        _ItemStatus.limited => 'Limited',
        _ItemStatus.full => 'Full',
      };
  Color get color => switch (this) {
        _ItemStatus.available => AppColors.success,
        _ItemStatus.limited => AppColors.warning,
        _ItemStatus.full => const Color(0xFFA0AEC0),
      };
}

class _OfferItem {
  final String title, note, priceUnit, capacityUnit;
  final IconData icon;
  final Color iconColor;
  final double price, capacity;
  final _ItemStatus status;

  const _OfferItem({
    required this.title,
    required this.icon,
    required this.iconColor,
    required this.price,
    required this.priceUnit,
    required this.capacity,
    required this.capacityUnit,
    required this.status,
    required this.note,
  });
}

// ── Screen ────────────────────────────────────────────────────────────────────

class CarrierOfferDetailScreen extends StatelessWidget {
  final String name;
  final String fromCode, fromCity, toCode, toCity, date;
  final double rating, startingPrice, maxCapacity;
  final String priceUnit, capacityUnit;
  final int reviews, itemCount;
  final Color avatarColor;
  final bool isVerified;

  const CarrierOfferDetailScreen({
    super.key,
    required this.name,
    required this.fromCode,
    required this.fromCity,
    required this.toCode,
    required this.toCity,
    required this.date,
    required this.rating,
    required this.reviews,
    required this.startingPrice,
    required this.priceUnit,
    required this.maxCapacity,
    required this.capacityUnit,
    required this.itemCount,
    required this.avatarColor,
    this.isVerified = true,
  });

  static const _mockItems = [
    _OfferItem(
      title: 'Consumer Electronics',
      icon: Icons.devices_rounded,
      iconColor: Color(0xFF4299E1),
      price: 3.20,
      priceUnit: 'kg',
      capacity: 5,
      capacityUnit: 'kg',
      status: _ItemStatus.available,
      note: 'Phones, tablets, small gadgets. Fragile items accepted.',
    ),
    _OfferItem(
      title: 'Fashion & Clothing',
      icon: Icons.checkroom_rounded,
      iconColor: Color(0xFF9F7AEA),
      price: 2.50,
      priceUnit: 'kg',
      capacity: 4,
      capacityUnit: 'kg',
      status: _ItemStatus.available,
      note: 'Folded or vacuum-packed. No oversized items.',
    ),
    _OfferItem(
      title: 'Documents & Books',
      icon: Icons.description_outlined,
      iconColor: Color(0xFF48BB78),
      price: 1.80,
      priceUnit: 'kg',
      capacity: 2,
      capacityUnit: 'kg',
      status: _ItemStatus.limited,
      note: 'A4 envelopes, printed materials, softcover books.',
    ),
    _OfferItem(
      title: 'Cosmetics & Skincare',
      icon: Icons.spa_outlined,
      iconColor: Color(0xFFF6AD55),
      price: 1.50,
      priceUnit: 'piece',
      capacity: 10,
      capacityUnit: 'pieces',
      status: _ItemStatus.available,
      note: 'Sealed, non-liquid items only. No aerosols.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.darkBackground : const Color(0xFFF7F9FC);
    final surface = isDark ? AppColors.darkSurface : Colors.white;
    final textPrimary = isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;
    final textSecondary = isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;
    final textTertiary = isDark ? AppColors.darkTextTertiary : AppColors.textTertiary;
    final border = isDark ? AppColors.darkBorder : const Color(0xFFF1F5F9);

    return Scaffold(
      backgroundColor: bg,
      body: Column(
        children: [
          // ── App bar ───────────────────────────────────────────────────
          _DetailAppBar(
            isDark: isDark,
            surface: surface,
            textPrimary: textPrimary,
            bg: bg,
          ),

          // ── Scrollable content ────────────────────────────────────────
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Carrier profile
                  _CarrierProfileCard(
                    name: name,
                    rating: rating,
                    reviews: reviews,
                    avatarColor: avatarColor,
                    isVerified: isVerified,
                    isDark: isDark,
                    surface: surface,
                    textPrimary: textPrimary,
                    textSecondary: textSecondary,
                    textTertiary: textTertiary,
                    border: border,
                  ),
                  const SizedBox(height: 24),

                  // Flight details
                  _SectionLabel('Flight Details', textTertiary),
                  const SizedBox(height: 10),
                  _FlightCard(
                    fromCode: fromCode,
                    fromCity: fromCity,
                    toCode: toCode,
                    toCity: toCity,
                    date: date,
                    isDark: isDark,
                    surface: surface,
                    textPrimary: textPrimary,
                    textSecondary: textSecondary,
                    textTertiary: textTertiary,
                    border: border,
                  ),
                  const SizedBox(height: 24),

                  // Pickup & delivery
                  _SectionLabel('Pickup & Delivery', textTertiary),
                  const SizedBox(height: 10),
                  _LocationCard(
                    fromCity: fromCity,
                    fromCode: fromCode,
                    toCity: toCity,
                    toCode: toCode,
                    isDark: isDark,
                    surface: surface,
                    textPrimary: textPrimary,
                    textSecondary: textSecondary,
                    textTertiary: textTertiary,
                    border: border,
                  ),
                  const SizedBox(height: 24),

                  // Offer items
                  _SectionLabel('What I Can Carry', textTertiary),
                  const SizedBox(height: 10),
                  ...List.generate(
                    _mockItems.length,
                    (i) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _OfferItemCard(
                        item: _mockItems[i],
                        isDark: isDark,
                        surface: surface,
                        textPrimary: textPrimary,
                        textSecondary: textSecondary,
                        textTertiary: textTertiary,
                        border: border,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),

      // ── Sticky match bar ─────────────────────────────────────────────
      bottomNavigationBar: _MatchBar(
        name: name,
        startingPrice: startingPrice,
        priceUnit: priceUnit,
        isDark: isDark,
        surface: surface,
        textPrimary: textPrimary,
        textSecondary: textSecondary,
        border: border,
      ),
    );
  }
}

// ── App bar ───────────────────────────────────────────────────────────────────

class _DetailAppBar extends StatelessWidget {
  final bool isDark;
  final Color surface, textPrimary, bg;

  const _DetailAppBar({
    required this.isDark,
    required this.surface,
    required this.textPrimary,
    required this.bg,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: bg,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 8,
        left: 16,
        right: 16,
        bottom: 12,
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: surface,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(Icons.arrow_back_ios_new_rounded,
                  size: 15, color: textPrimary),
            ),
          ),
          Expanded(
            child: Text(
              'Offer Details',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Manrope',
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: textPrimary,
              ),
            ),
          ),
          const SizedBox(width: 36),
        ],
      ),
    );
  }
}

// ── Section label ─────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String text;
  final Color color;

  const _SectionLabel(this.text, this.color);

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: TextStyle(
        fontFamily: 'Manrope',
        fontSize: 11,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.8,
        color: color,
      ),
    );
  }
}

// ── Carrier profile card ──────────────────────────────────────────────────────

class _CarrierProfileCard extends StatelessWidget {
  final String name;
  final double rating;
  final int reviews;
  final Color avatarColor;
  final bool isVerified;
  final bool isDark;
  final Color surface, textPrimary, textSecondary, textTertiary, border;

  const _CarrierProfileCard({
    required this.name,
    required this.rating,
    required this.reviews,
    required this.avatarColor,
    required this.isVerified,
    required this.isDark,
    required this.surface,
    required this.textPrimary,
    required this.textSecondary,
    required this.textTertiary,
    required this.border,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          // Avatar
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [avatarColor, avatarColor.withValues(alpha: 0.65)],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(
                  child: Text(
                    name[0],
                    style: const TextStyle(
                      fontFamily: 'Manrope',
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              if (isVerified)
                Positioned(
                  bottom: -3,
                  right: -3,
                  child: Container(
                    width: 18,
                    height: 18,
                    decoration: BoxDecoration(
                      color: AppColors.success,
                      shape: BoxShape.circle,
                      border: Border.all(color: surface, width: 2),
                    ),
                    child: const Icon(Icons.check, size: 10, color: Colors.white),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        name,
                        style: TextStyle(
                          fontFamily: 'Manrope',
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: textPrimary,
                          letterSpacing: -0.3,
                        ),
                      ),
                    ),
                    if (isVerified) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 7, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.success.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          'Verified',
                          style: TextStyle(
                            fontFamily: 'Manrope',
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: AppColors.success,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 5),
                Row(
                  children: [
                    const Icon(Icons.star_rounded,
                        color: Color(0xFFF6AD55), size: 14),
                    const SizedBox(width: 3),
                    Text(
                      rating.toStringAsFixed(1),
                      style: TextStyle(
                        fontFamily: 'Manrope',
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: textPrimary,
                      ),
                    ),
                    Text(
                      '  ·  $reviews reviews',
                      style: TextStyle(
                        fontFamily: 'Manrope',
                        fontSize: 12,
                        color: textSecondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 5),
                Row(
                  children: [
                    Icon(Icons.repeat_rounded, size: 12, color: textTertiary),
                    const SizedBox(width: 4),
                    Text(
                      '47 trips completed',
                      style: TextStyle(
                        fontFamily: 'Manrope',
                        fontSize: 11,
                        color: textTertiary,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(width: 3, height: 3,
                        decoration: BoxDecoration(
                            color: textTertiary, shape: BoxShape.circle)),
                    const SizedBox(width: 8),
                    Text(
                      'Member since 2023',
                      style: TextStyle(
                        fontFamily: 'Manrope',
                        fontSize: 11,
                        color: textTertiary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Flight card ───────────────────────────────────────────────────────────────

class _FlightCard extends StatelessWidget {
  final String fromCode, fromCity, toCode, toCity, date;
  final bool isDark;
  final Color surface, textPrimary, textSecondary, textTertiary, border;

  const _FlightCard({
    required this.fromCode,
    required this.fromCity,
    required this.toCode,
    required this.toCity,
    required this.date,
    required this.isDark,
    required this.surface,
    required this.textPrimary,
    required this.textSecondary,
    required this.textTertiary,
    required this.border,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          // Route row
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
            child: Row(
              children: [
                // Origin
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      fromCode,
                      style: TextStyle(
                        fontFamily: 'Manrope',
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: textPrimary,
                        letterSpacing: -0.5,
                      ),
                    ),
                    Text(
                      fromCity,
                      style: TextStyle(
                        fontFamily: 'Manrope',
                        fontSize: 11,
                        color: textTertiary,
                      ),
                    ),
                  ],
                ),

                // Flight arc
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _FlightDot(color: AppColors.primary),
                        Expanded(
                          child: Container(
                            height: 1,
                            margin: const EdgeInsets.symmetric(horizontal: 2),
                            decoration: BoxDecoration(
                              border: Border(
                                top: BorderSide(
                                  color: isDark
                                      ? AppColors.darkBorder
                                      : const Color(0xFFE2E8F0),
                                  width: 1.5,
                                  style: BorderStyle.solid,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const Icon(Icons.flight_rounded,
                            size: 18, color: AppColors.primary),
                        Expanded(
                          child: Container(
                            height: 1,
                            margin: const EdgeInsets.symmetric(horizontal: 2),
                            decoration: BoxDecoration(
                              border: Border(
                                top: BorderSide(
                                  color: isDark
                                      ? AppColors.darkBorder
                                      : const Color(0xFFE2E8F0),
                                  width: 1.5,
                                  style: BorderStyle.solid,
                                ),
                              ),
                            ),
                          ),
                        ),
                        _FlightDot(color: AppColors.primary),
                      ],
                    ),
                  ),
                ),

                // Destination
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      toCode,
                      style: TextStyle(
                        fontFamily: 'Manrope',
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: textPrimary,
                        letterSpacing: -0.5,
                      ),
                    ),
                    Text(
                      toCity,
                      style: TextStyle(
                        fontFamily: 'Manrope',
                        fontSize: 11,
                        color: textTertiary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          Divider(height: 1, color: border),

          // Flight stats
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 16),
            child: Row(
              children: [
                _FlightStat(
                  label: 'Departure',
                  value: date,
                  sub: '10:30 AM',
                  textPrimary: textPrimary,
                  textSecondary: textSecondary,
                  textTertiary: textTertiary,
                ),
                const Spacer(),
                _FlightStat(
                  label: 'Arrival',
                  value: '${date.split(' ')[0]} ${int.parse(date.split(' ')[1]) + 1 <= 31 ? int.parse(date.split(' ')[1]) + 1 : 1}',
                  sub: '10:45 AM',
                  textPrimary: textPrimary,
                  textSecondary: textSecondary,
                  textTertiary: textTertiary,
                  align: CrossAxisAlignment.center,
                ),
                const Spacer(),
                _FlightStat(
                  label: 'Duration',
                  value: '~8 hrs',
                  sub: 'Direct flight',
                  textPrimary: textPrimary,
                  textSecondary: textSecondary,
                  textTertiary: textTertiary,
                  align: CrossAxisAlignment.end,
                ),
              ],
            ),
          ),

          Divider(height: 1, color: border),

          // Terminal row
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 14),
            child: Row(
              children: [
                Icon(Icons.location_on_outlined, size: 13, color: textTertiary),
                const SizedBox(width: 5),
                Text(
                  '$fromCode · Terminal 4',
                  style: TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 12,
                    color: textSecondary,
                  ),
                ),
                const Spacer(),
                Icon(Icons.location_on_outlined, size: 13, color: textTertiary),
                const SizedBox(width: 5),
                Text(
                  '$toCode · Terminal 2',
                  style: TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 12,
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

class _FlightDot extends StatelessWidget {
  final Color color;
  const _FlightDot({required this.color});
  @override
  Widget build(BuildContext context) => Container(
        width: 6,
        height: 6,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      );
}

class _FlightStat extends StatelessWidget {
  final String label, value, sub;
  final CrossAxisAlignment align;
  final Color textPrimary, textSecondary, textTertiary;

  const _FlightStat({
    required this.label,
    required this.value,
    required this.sub,
    required this.textPrimary,
    required this.textSecondary,
    required this.textTertiary,
    this.align = CrossAxisAlignment.start,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: align,
      children: [
        Text(
          label,
          style: TextStyle(
            fontFamily: 'Manrope',
            fontSize: 10,
            color: textTertiary,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          value,
          style: TextStyle(
            fontFamily: 'Manrope',
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: textPrimary,
          ),
        ),
        Text(
          sub,
          style: TextStyle(
            fontFamily: 'Manrope',
            fontSize: 11,
            color: textSecondary,
          ),
        ),
      ],
    );
  }
}

// ── Location card ─────────────────────────────────────────────────────────────

class _LocationCard extends StatelessWidget {
  final String fromCity, fromCode, toCity, toCode;
  final bool isDark;
  final Color surface, textPrimary, textSecondary, textTertiary, border;

  const _LocationCard({
    required this.fromCity,
    required this.fromCode,
    required this.toCity,
    required this.toCode,
    required this.isDark,
    required this.surface,
    required this.textPrimary,
    required this.textSecondary,
    required this.textTertiary,
    required this.border,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          _LocationRow(
            icon: Icons.flight_takeoff_rounded,
            iconColor: AppColors.primary,
            label: 'Pickup',
            value: '$fromCode Airport, Terminal 4 departure area',
            sub: fromCity,
            isTop: true,
            textPrimary: textPrimary,
            textSecondary: textSecondary,
            textTertiary: textTertiary,
          ),
          Divider(height: 1, indent: 52, color: border),
          _LocationRow(
            icon: Icons.flight_land_rounded,
            iconColor: AppColors.info,
            label: 'Delivery',
            value: 'Central $toCity area (negotiable)',
            sub: '$toCode · ~5 km radius',
            isTop: false,
            textPrimary: textPrimary,
            textSecondary: textSecondary,
            textTertiary: textTertiary,
          ),
        ],
      ),
    );
  }
}

class _LocationRow extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label, value, sub;
  final bool isTop;
  final Color textPrimary, textSecondary, textTertiary;

  const _LocationRow({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
    required this.sub,
    required this.isTop,
    required this.textPrimary,
    required this.textSecondary,
    required this.textTertiary,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
          16, isTop ? 14 : 12, 16, isTop ? 12 : 14),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 10,
                    color: textTertiary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: textPrimary,
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  sub,
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

// ── Offer item card ───────────────────────────────────────────────────────────

class _OfferItemCard extends StatelessWidget {
  final _OfferItem item;
  final bool isDark;
  final Color surface, textPrimary, textSecondary, textTertiary, border;

  const _OfferItemCard({
    required this.item,
    required this.isDark,
    required this.surface,
    required this.textPrimary,
    required this.textSecondary,
    required this.textTertiary,
    required this.border,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Category icon
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: item.iconColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(item.icon, color: item.iconColor, size: 19),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      style: TextStyle(
                        fontFamily: 'Manrope',
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      item.note,
                      style: TextStyle(
                        fontFamily: 'Manrope',
                        fontSize: 11,
                        color: textTertiary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              // Status badge
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: item.status.color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  item.status.label,
                  style: TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: item.status.color,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Divider(height: 1, color: border),
          const SizedBox(height: 10),
          // Price + capacity
          Row(
            children: [
              _ItemStat(
                label: 'Price',
                value: '\$${item.price.toStringAsFixed(2)}',
                unit: '/ ${item.priceUnit}',
                valueColor: textPrimary,
                unitColor: textSecondary,
              ),
              Container(
                width: 1,
                height: 28,
                color: border,
                margin: const EdgeInsets.symmetric(horizontal: 16),
              ),
              _ItemStat(
                label: 'Max capacity',
                value:
                    '${item.capacity % 1 == 0 ? item.capacity.toInt() : item.capacity}',
                unit: item.capacityUnit,
                valueColor: textPrimary,
                unitColor: textSecondary,
              ),
              Container(
                width: 1,
                height: 28,
                color: border,
                margin: const EdgeInsets.symmetric(horizontal: 16),
              ),
              _ItemStat(
                label: 'Status',
                value: item.status.label,
                unit: '',
                valueColor: item.status.color,
                unitColor: textSecondary,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ItemStat extends StatelessWidget {
  final String label, value, unit;
  final Color valueColor, unitColor;

  const _ItemStat({
    required this.label,
    required this.value,
    required this.unit,
    required this.valueColor,
    required this.unitColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontFamily: 'Manrope',
            fontSize: 10,
            color: unitColor,
          ),
        ),
        const SizedBox(height: 2),
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              value,
              style: TextStyle(
                fontFamily: 'Manrope',
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: valueColor,
              ),
            ),
            if (unit.isNotEmpty) ...[
              const SizedBox(width: 2),
              Text(
                unit,
                style: TextStyle(
                  fontFamily: 'Manrope',
                  fontSize: 10,
                  color: unitColor,
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }
}

// ── Match bottom bar ──────────────────────────────────────────────────────────

class _MatchBar extends StatelessWidget {
  final String name, priceUnit;
  final double startingPrice;
  final bool isDark;
  final Color surface, textPrimary, textSecondary, border;

  const _MatchBar({
    required this.name,
    required this.startingPrice,
    required this.priceUnit,
    required this.isDark,
    required this.surface,
    required this.textPrimary,
    required this.textSecondary,
    required this.border,
  });

  @override
  Widget build(BuildContext context) {
    final bg = isDark ? AppColors.darkBackground : Colors.white;
    return Container(
      decoration: BoxDecoration(
        color: bg,
        border: Border(top: BorderSide(color: border, width: 1)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
          child: Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Starting from',
                    style: TextStyle(
                      fontFamily: 'Manrope',
                      fontSize: 10,
                      color: textSecondary,
                    ),
                  ),
                  const SizedBox(height: 1),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        '\$${startingPrice.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontFamily: 'Manrope',
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: textPrimary,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(width: 3),
                      Text(
                        '/ $priceUnit',
                        style: TextStyle(
                          fontFamily: 'Manrope',
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(width: 16),
              Expanded(
                child: GestureDetector(
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Text(
                      'Match with ${name.split(' ')[0]}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontFamily: 'Manrope',
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        letterSpacing: -0.2,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
