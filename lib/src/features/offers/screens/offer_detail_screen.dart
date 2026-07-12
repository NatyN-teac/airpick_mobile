import 'package:flutter/material.dart';
import '../../../core/l10n/l10n.dart';
import '../../../core/theme/app_colors.dart';
import '../cubit/offers_cubit.dart';
import '../models/offer_response.dart';

class OfferDetailScreen extends StatelessWidget {
  final OfferResponse offer;
  final bool showMatchAction;
  final VoidCallback? onMatch;

  const OfferDetailScreen({
    super.key,
    required this.offer,
    this.showMatchAction = false,
    this.onMatch,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.darkBackground : AppColors.background;
    final l = l10n(context);
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
        title: Text(l.stepOfferDetails,
            style: TextStyle(
              fontFamily: 'Manrope',
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: textPrimary,
              letterSpacing: -0.3,
            )),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _FlightCard(offer: offer, isDark: isDark),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.schedule_rounded, size: 14, color: textSecondary),
                const SizedBox(width: 5),
                Text(l.offerCreatedAgo(offer.createdAgo),
                    style: TextStyle(
                        fontFamily: 'Manrope',
                        fontSize: 12,
                        color: textSecondary)),
                const Spacer(),
                _StatusChip(status: offer.status),
              ],
            ),
            const SizedBox(height: 20),

            _Tile(Icons.flight_takeoff_rounded, l.pickupArea, offer.pickupArea,
                isDark),
            _Tile(Icons.flight_land_rounded, l.deliveryArea, offer.deliveryArea,
                isDark),
            _Tile(Icons.bolt_rounded, l.urgencyLevel, offer.urgencyLabel, isDark),
            _Tile(Icons.payments_rounded, l.offerCurrency, offer.currency, isDark),
            if (offer.discount != null && offer.discount! > 0)
              _Tile(Icons.local_offer_rounded, l.offerDiscountLabel,
                  '${offer.currency} ${offer.discount!.toStringAsFixed(2)}', isDark),
            if (offer.paymentMethods.isNotEmpty)
              _Tile(Icons.account_balance_wallet_rounded, l.offerPayment,
                  offer.paymentMethods.join(', '), isDark),
            if (offer.meetupPlaces.isNotEmpty)
              _Tile(Icons.place_rounded, l.offerMeetup,
                  offer.meetupPlaces.join(', '), isDark),
            if (offer.specialNote?.isNotEmpty == true)
              _Tile(Icons.sticky_note_2_outlined, l.offerNote, offer.specialNote!,
                  isDark),
            const SizedBox(height: 20),

            // ── Items ─────────────────────────────────────────────
            Row(
              children: [
                Text(l.offerItems,
                    style: TextStyle(
                      fontFamily: 'Manrope',
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: textPrimary,
                      letterSpacing: -0.2,
                    )),
                const SizedBox(width: 6),
                Text('· ${offer.totalQuantity} total',
                    style: TextStyle(
                        fontFamily: 'Manrope',
                        fontSize: 12,
                        color: textSecondary)),
              ],
            ),
            const SizedBox(height: 10),
            ...offer.items.map((it) => _ItemRow(item: it, isDark: isDark)),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.07),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Text(l.offerTotalValue,
                      style: TextStyle(
                          fontFamily: 'Manrope',
                          fontSize: 12,
                          color: textSecondary)),
                  const Spacer(),
                  Text(
                    '${offer.currency} ${offer.totalValue.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontFamily: 'Manrope',
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
            ),
          ),
          if (showMatchAction && onMatch != null)
            Container(
              width: double.infinity,
              padding: EdgeInsets.fromLTRB(
                16,
                12,
                16,
                MediaQuery.of(context).padding.bottom + 12,
              ),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurface : Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.06),
                    blurRadius: 16,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: FilledButton(
                onPressed: onMatch,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  minimumSize: const Size.fromHeight(48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: Text(
                  l.offerMatchThis,
                  style: const TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _FlightCard extends StatelessWidget {
  final OfferResponse offer;
  final bool isDark;
  const _FlightCard({required this.offer, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final surface = isDark ? AppColors.darkSurface : Colors.white;
    final textPrimary =
        isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;
    final textTertiary =
        isDark ? AppColors.darkTextTertiary : AppColors.textTertiary;
    final leg = offer.firstLeg;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.06),
            blurRadius: 18,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: leg == null
          ? Text(l10n(context).offerNoFlight,
              style: TextStyle(
                  fontFamily: 'Manrope', fontSize: 13, color: textTertiary))
          : Row(
              children: [
                _Airport(
                    code: leg.srcAirport.iataCode,
                    city: leg.srcAirport.city,
                    align: CrossAxisAlignment.start,
                    isDark: isDark),
                Expanded(
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _dot(textTertiary),
                          Expanded(
                            child: Container(
                                height: 1.5,
                                color: textTertiary.withValues(alpha: 0.4)),
                          ),
                          const Icon(Icons.flight_rounded,
                              size: 16, color: AppColors.primary),
                          Expanded(
                            child: Container(
                                height: 1.5,
                                color: textTertiary.withValues(alpha: 0.4)),
                          ),
                          _dot(textTertiary),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(leg.departureDate,
                          style: TextStyle(
                            fontFamily: 'Manrope',
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: textPrimary,
                          )),
                    ],
                  ),
                ),
                _Airport(
                    code: leg.destAirport.iataCode,
                    city: leg.destAirport.city,
                    align: CrossAxisAlignment.end,
                    isDark: isDark),
              ],
            ),
    );
  }

  Widget _dot(Color c) => Container(
      width: 5,
      height: 5,
      decoration: BoxDecoration(color: c, shape: BoxShape.circle));
}

class _Airport extends StatelessWidget {
  final String code, city;
  final CrossAxisAlignment align;
  final bool isDark;
  const _Airport(
      {required this.code,
      required this.city,
      required this.align,
      required this.isDark});

  @override
  Widget build(BuildContext context) {
    final textPrimary =
        isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;
    final textTertiary =
        isDark ? AppColors.darkTextTertiary : AppColors.textTertiary;
    return Column(
      crossAxisAlignment: align,
      children: [
        Text(code,
            style: TextStyle(
              fontFamily: 'Manrope',
              fontSize: 20,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.5,
              color: textPrimary,
            )),
        const SizedBox(height: 1),
        Text(city,
            style: TextStyle(
                fontFamily: 'Manrope', fontSize: 10, color: textTertiary)),
      ],
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String status;
  const _StatusChip({required this.status});

  Color get _c => switch (status) {
        'OPEN' => AppColors.success,
        'MATCHED' || 'ACCEPTED' => AppColors.info,
        'IN_DELIVERY' => const Color(0xFF9F7AEA),
        'COMPLETED' => AppColors.textSecondary,
        _ => AppColors.warning,
      };

  @override
  Widget build(BuildContext context) {
    final label = offerStatusLabel(status, l10n(context));
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: _c.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(label,
          style: TextStyle(
            fontFamily: 'Manrope',
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: _c,
          )),
    );
  }
}

class _Tile extends StatelessWidget {
  final IconData icon;
  final String label, value;
  final bool isDark;
  const _Tile(this.icon, this.label, this.value, this.isDark);

  @override
  Widget build(BuildContext context) {
    if (value.isEmpty) return const SizedBox.shrink();
    final textPrimary =
        isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;
    final textSecondary =
        isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 17, color: AppColors.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: TextStyle(
                        fontFamily: 'Manrope',
                        fontSize: 11,
                        color: textSecondary)),
                const SizedBox(height: 2),
                Text(value,
                    style: TextStyle(
                      fontFamily: 'Manrope',
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: textPrimary,
                      height: 1.4,
                    )),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ItemRow extends StatelessWidget {
  final OfferItemResponse item;
  final bool isDark;
  const _ItemRow({required this.item, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final surface = isDark ? AppColors.darkSurface : Colors.white;
    final border = isDark ? AppColors.darkBorder : AppColors.border;
    final textPrimary =
        isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;
    final textSecondary =
        isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: border),
      ),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(9),
            ),
            child: const Icon(Icons.category_rounded,
                size: 16, color: AppColors.primary),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.name,
                    style: TextStyle(
                      fontFamily: 'Manrope',
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: textPrimary,
                    )),
                Text('× ${item.quantity}',
                    style: TextStyle(
                        fontFamily: 'Manrope',
                        fontSize: 10,
                        color: textSecondary)),
              ],
            ),
          ),
          Text(item.pricePerItem.toStringAsFixed(2),
              style: TextStyle(
                fontFamily: 'Manrope',
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: textPrimary,
              )),
        ],
      ),
    );
  }
}
