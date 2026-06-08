import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../models/offer_models.dart';
import '../models/offer_response.dart';
import '../screens/offer_detail_screen.dart';

// ── Carrier avatar (photo, initial, optional verified chip) ───────────────────

class CarrierAvatar extends StatelessWidget {
  final CarrierSummary? carrier;
  final String fallbackSeed;
  final double size;

  const CarrierAvatar({
    super.key,
    required this.carrier,
    required this.fallbackSeed,
    this.size = 46,
  });

  Color _color() {
    const palette = [
      Color(0xFF4299E1),
      Color(0xFF48BB78),
      Color(0xFF9F7AEA),
      Color(0xFFED8936),
      Color(0xFFEC4899),
      Color(0xFF38B2AC),
    ];
    final seed = carrier?.fullName.isNotEmpty == true
        ? carrier!.fullName
        : fallbackSeed;
    return palette[seed.hashCode.abs() % palette.length];
  }

  @override
  Widget build(BuildContext context) {
    final url = carrier?.profilePictureUrl;
    final color = _color();
    final initial = carrier?.initial ?? '?';

    return Column(
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            gradient: (url == null || url.isEmpty)
                ? LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [color, color.withValues(alpha: 0.65)],
                  )
                : null,
            image: (url != null && url.isNotEmpty)
                ? DecorationImage(
                    image: NetworkImage(url), fit: BoxFit.cover)
                : null,
            borderRadius: BorderRadius.circular(13),
          ),
          child: (url == null || url.isEmpty)
              ? Center(
                  child: Text(
                    initial,
                    style: TextStyle(
                      fontFamily: 'Manrope',
                      fontSize: size * 0.41,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                )
              : null,
        ),
        if (carrier?.isVerified == true) ...[
          const SizedBox(height: 3),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
            decoration: BoxDecoration(
              color: AppColors.success.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(5),
            ),
            child: const Text(
              'Verified',
              style: TextStyle(
                fontFamily: 'Manrope',
                fontSize: 9,
                fontWeight: FontWeight.w700,
                color: AppColors.success,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

// ── Browse offer card (sender view) ─────────────────────────────────────────

class BrowseOfferCard extends StatelessWidget {
  final OfferResponse offer;
  final bool isDark;
  final VoidCallback? onMatch;

  const BrowseOfferCard({
    super.key,
    required this.offer,
    required this.isDark,
    this.onMatch,
  });

  void _openDetails(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => OfferDetailScreen(
          offer: offer,
          showMatchAction: true,
          onMatch: onMatch,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final surface = isDark ? AppColors.darkSurface : Colors.white;
    final textPrimary =
        isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;
    final textSecondary =
        isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;
    final textTertiary =
        isDark ? AppColors.darkTextTertiary : AppColors.textTertiary;

    final name = offer.carrier?.displayName ?? 'Carrier';
    final rating = offer.carrier?.rating;
    final symbol = offer.currencyEnum.symbol;
    final fromCode = offer.fromCode ?? '—';
    final fromCity = offer.fromCity ?? '';
    final toCode = offer.toCode ?? '—';
    final toCity = offer.toCity ?? '';
    final date = offer.formattedDepartureDate;
    final itemCount = offer.items.length;
    final capacity = OfferResponse.formatQuantity(offer.totalRemainingCapacity);

    return GestureDetector(
      onTap: () => _openDetails(context),
      behavior: HitTestBehavior.opaque,
      child: Container(
        decoration: BoxDecoration(
          color: surface,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.28 : 0.07),
              blurRadius: 24,
              offset: const Offset(0, 6),
            ),
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.10 : 0.03),
              blurRadius: 6,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CarrierAvatar(
                    carrier: offer.carrier,
                    fallbackSeed: offer.carrierId,
                  ),
                  const SizedBox(width: 12),
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
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: textPrimary,
                                  letterSpacing: -0.3,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const Spacer(),
                            GestureDetector(
                              onTap: () => _openDetails(context),
                              child: Row(
                                children: [
                                  Text(
                                    'View details',
                                    style: TextStyle(
                                      fontFamily: 'Manrope',
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.info,
                                    ),
                                  ),
                                  const SizedBox(width: 2),
                                  const Icon(Icons.arrow_forward_ios_rounded,
                                      size: 10, color: AppColors.info),
                                ],
                              ),
                            ),
                          ],
                        ),
                        if (rating != null) ...[
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(Icons.star_rounded,
                                  color: Color(0xFFF6AD55), size: 13),
                              const SizedBox(width: 3),
                              Text(
                                rating.toStringAsFixed(1),
                                style: TextStyle(
                                  fontFamily: 'Manrope',
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: textPrimary,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 0),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkBackground : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          fromCode,
                          style: TextStyle(
                            fontFamily: 'Manrope',
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.6,
                            color: textPrimary,
                          ),
                        ),
                        if (fromCity.isNotEmpty)
                          Text(
                            fromCity,
                            style: TextStyle(
                              fontFamily: 'Manrope',
                              fontSize: 9,
                              color: textTertiary,
                            ),
                          ),
                      ],
                    ),
                    Expanded(
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _DottedLine(isDark: isDark),
                              const Padding(
                                padding: EdgeInsets.symmetric(horizontal: 4),
                                child: Icon(Icons.flight_rounded,
                                    size: 11, color: AppColors.primary),
                              ),
                              _DottedLine(isDark: isDark),
                            ],
                          ),
                          if (date.isNotEmpty) ...[
                            const SizedBox(height: 2),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.calendar_today_outlined,
                                    size: 8, color: textTertiary),
                                const SizedBox(width: 3),
                                Text(
                                  date,
                                  style: TextStyle(
                                    fontFamily: 'Manrope',
                                    fontSize: 9,
                                    fontWeight: FontWeight.w500,
                                    color: textTertiary,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          toCode,
                          style: TextStyle(
                            fontFamily: 'Manrope',
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.6,
                            color: textPrimary,
                          ),
                        ),
                        if (toCity.isNotEmpty)
                          Text(
                            toCity,
                            style: TextStyle(
                              fontFamily: 'Manrope',
                              fontSize: 9,
                              color: textTertiary,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 14),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Starting from',
                          style: TextStyle(
                            fontFamily: 'Manrope',
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                            color: textTertiary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Text(
                              '$symbol${offer.startingPrice.toStringAsFixed(2)}',
                              style: TextStyle(
                                fontFamily: 'Manrope',
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                                color: textPrimary,
                                letterSpacing: -0.6,
                              ),
                            ),
                            const SizedBox(width: 3),
                            Text(
                              '/ ${offer.priceUnitLabel}',
                              style: TextStyle(
                                fontFamily: 'Manrope',
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: textSecondary,
                              ),
                            ),
                            if (itemCount > 0) ...[
                              const SizedBox(width: 6),
                              Text('·',
                                  style: TextStyle(
                                      fontFamily: 'Manrope',
                                      fontSize: 11,
                                      color: textTertiary)),
                              const SizedBox(width: 6),
                              Flexible(
                                child: Text(
                                  'Up to $capacity ${offer.capacityUnitLabel}  ·  $itemCount ${itemCount == 1 ? 'slot' : 'slots'}',
                                  style: TextStyle(
                                    fontFamily: 'Manrope',
                                    fontSize: 10,
                                    color: textTertiary,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  GestureDetector(
                    onTap: () {
                      if (onMatch != null) onMatch!();
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 28, vertical: 9),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.14),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'Match',
                        style: TextStyle(
                          fontFamily: 'Manrope',
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                          letterSpacing: -0.1,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DottedLine extends StatelessWidget {
  final bool isDark;
  const _DottedLine({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 36,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(
          4,
          (_) => Container(
            width: 4,
            height: 1.5,
            decoration: BoxDecoration(
              color:
                  isDark ? AppColors.darkBorder : const Color(0xFFD1D5DB),
              borderRadius: BorderRadius.circular(1),
            ),
          ),
        ),
      ),
    );
  }
}
