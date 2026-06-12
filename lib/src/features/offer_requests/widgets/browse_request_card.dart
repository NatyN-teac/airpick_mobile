import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../models/offer_request_models.dart';

// ── Shipper avatar (photo, or initial + "Verified" chip beneath) ──────────────

class ShipperAvatar extends StatelessWidget {
  final Shipper? shipper;
  final double size;
  const ShipperAvatar({super.key, required this.shipper, this.size = 46});

  // Deterministic colour from the name so initials look intentional.
  Color _color() {
    const palette = [
      Color(0xFF4299E1),
      Color(0xFF48BB78),
      Color(0xFF9F7AEA),
      Color(0xFFED8936),
      Color(0xFFEC4899),
      Color(0xFF38B2AC),
    ];
    final name = shipper?.fullName ?? '?';
    return palette[name.hashCode.abs() % palette.length];
  }

  @override
  Widget build(BuildContext context) {
    final url = shipper?.profilePictureUrl;
    final color = _color();
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
                    shipper?.initial ?? '?',
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
    );
  }
}

// ── Browse request card (carrier view) ────────────────────────────────────────

class BrowseRequestCard extends StatelessWidget {
  final OfferRequestResponse request;
  final bool isDark;
  final VoidCallback onTap;
  final VoidCallback onSendProposal;

  const BrowseRequestCard({
    super.key,
    required this.request,
    required this.isDark,
    required this.onTap,
    required this.onSendProposal,
  });

  @override
  Widget build(BuildContext context) {
    final surface = isDark ? AppColors.darkSurface : Colors.white;
    final textPrimary =
        isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;
    final textTertiary =
        isDark ? AppColors.darkTextTertiary : AppColors.textTertiary;

    final name = request.shipper?.fullName.isNotEmpty == true
        ? request.shipper!.fullName
        : 'Sender';

    return GestureDetector(
      onTap: onTap,
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
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: avatar + name + urgency
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ShipperAvatar(shipper: request.shipper),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
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
                            _UrgencyBadge(label: request.urgencyLabel),
                          ],
                        ),
                        const SizedBox(height: 6),
                        // Route: country + city → country
                        _RouteRow(
                          fromCity: request.sourceCity,
                          fromCountry: request.sourceCountry,
                          toCountry: request.destinationCountry,
                          isDark: isDark,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Footer: item count + send proposal
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.category_rounded,
                            size: 11, color: AppColors.primary),
                        const SizedBox(width: 4),
                        Text(
                          '${request.items.length} item${request.items.length == 1 ? '' : 's'}',
                          style: const TextStyle(
                            fontFamily: 'Manrope',
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (request.partialProposalAccepted) ...[
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.info.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'Partial ✓',
                        style: TextStyle(
                          fontFamily: 'Manrope',
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppColors.info,
                        ),
                      ),
                    ),
                  ],
                  const Spacer(),
                  GestureDetector(
                    onTap: onSendProposal,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 18, vertical: 9),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.14),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'Send Proposal',
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

            // Divider + created-ago bottom-right
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 14, 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Icon(Icons.schedule_rounded, size: 11, color: textTertiary),
                  const SizedBox(width: 4),
                  Text(
                    request.createdAgo,
                    style: TextStyle(
                      fontFamily: 'Manrope',
                      fontSize: 10,
                      color: textTertiary,
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

class _RouteRow extends StatelessWidget {
  final String fromCity, fromCountry, toCountry;
  final bool isDark;
  const _RouteRow({
    required this.fromCity,
    required this.fromCountry,
    required this.toCountry,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final textSecondary =
        isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;
    final textTertiary =
        isDark ? AppColors.darkTextTertiary : AppColors.textTertiary;
    return Row(
      children: [
        Flexible(
          child: Text(
            '$fromCity, $fromCountry',
            style: TextStyle(
              fontFamily: 'Manrope',
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: textSecondary,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 5),
          child: Icon(Icons.arrow_forward_rounded,
              size: 12, color: textTertiary),
        ),
        Flexible(
          child: Text(
            toCountry,
            style: TextStyle(
              fontFamily: 'Manrope',
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: textSecondary,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

class _UrgencyBadge extends StatelessWidget {
  final String label;
  const _UrgencyBadge({required this.label});

  Color get _color => switch (label) {
        'Urgent' => AppColors.error,
        'Flexible' => AppColors.info,
        _ => AppColors.textSecondary,
      };

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: _color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: 'Manrope',
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: _color,
          ),
        ),
      );
}

// ── Detail popup (carrier viewing a request) ──────────────────────────────────

Future<void> showBrowseRequestDetail(
  BuildContext context,
  OfferRequestResponse request, {
  required VoidCallback onSendProposal,
}) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _BrowseRequestDetailSheet(
      request: request,
      isDark: isDark,
      onSendProposal: onSendProposal,
    ),
  );
}

class _BrowseRequestDetailSheet extends StatelessWidget {
  final OfferRequestResponse request;
  final bool isDark;
  final VoidCallback onSendProposal;

  const _BrowseRequestDetailSheet({
    required this.request,
    required this.isDark,
    required this.onSendProposal,
  });

  @override
  Widget build(BuildContext context) {
    final bg = isDark ? AppColors.darkSurface : Colors.white;
    final textPrimary =
        isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;
    final textSecondary =
        isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;
    final name = request.shipper?.fullName.isNotEmpty == true
        ? request.shipper!.fullName
        : 'Sender';

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.82,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 10),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.textDisabled.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      ShipperAvatar(shipper: request.shipper, size: 44),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              name,
                              style: TextStyle(
                                fontFamily: 'Manrope',
                                fontSize: 17,
                                fontWeight: FontWeight.w800,
                                color: textPrimary,
                                letterSpacing: -0.3,
                              ),
                            ),
                            const SizedBox(height: 2),
                            _RouteRow(
                              fromCity: request.sourceCity,
                              fromCountry: request.sourceCountry,
                              toCountry: request.destinationCountry,
                              isDark: isDark,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _kv('Preferred date', request.preferredDate, isDark),
                  _kv('Urgency', request.urgencyLabel, isDark),
                  _kv(
                      'Partial proposals',
                      request.partialProposalAccepted
                          ? 'Accepted'
                          : 'Not accepted',
                      isDark),
                  if (request.specialNote?.isNotEmpty == true)
                    _kv('Note', request.specialNote!, isDark),
                  const SizedBox(height: 16),
                  Text(
                    'Items (${request.items.length})',
                    style: TextStyle(
                      fontFamily: 'Manrope',
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...request.items.map((it) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          children: [
                            Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color:
                                    AppColors.primary.withValues(alpha: 0.08),
                                borderRadius: BorderRadius.circular(9),
                              ),
                              child: const Icon(Icons.category_rounded,
                                  size: 15, color: AppColors.primary),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                it.name,
                                style: TextStyle(
                                  fontFamily: 'Manrope',
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: textPrimary,
                                ),
                              ),
                            ),
                            Text(
                              '× ${it.quantity}${it.measurementUnit != null ? '  ${it.measurementUnit}' : ''}',
                              style: TextStyle(
                                fontFamily: 'Manrope',
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: textSecondary,
                              ),
                            ),
                          ],
                        ),
                      )),
                  const SizedBox(height: 8),
                  Text(
                    'Requested ${request.createdAgo}',
                    style: TextStyle(
                      fontFamily: 'Manrope',
                      fontSize: 11,
                      color: textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Sticky CTA
          Padding(
            padding: EdgeInsets.fromLTRB(
                20, 8, 20, MediaQuery.of(context).padding.bottom + 16),
            child: SizedBox(
              width: double.infinity,
              child: GestureDetector(
                onTap: () {
                  Navigator.of(context).pop();
                  onSendProposal();
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Text(
                    'Send Proposal',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Manrope',
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _kv(String k, String v, bool isDark) {
    final textPrimary =
        isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;
    final textSecondary =
        isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(
              k,
              style: TextStyle(
                  fontFamily: 'Manrope', fontSize: 12, color: textSecondary),
            ),
          ),
          Expanded(
            child: Text(
              v,
              style: TextStyle(
                fontFamily: 'Manrope',
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
