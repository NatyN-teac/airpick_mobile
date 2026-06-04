import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/nav_cubit.dart';
import '../widgets/home_app_bar.dart';
import '../widgets/app_nav_bar.dart';
import '../../../core/theme/app_colors.dart';
import '../../search/screens/search_screen.dart';

// ignore: unused_field — carrier mode used when profile role-switching is wired
enum _UserMode { sender, carrier }

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => NavCubit(),
      child: const _HomeView(),
    );
  }
}

class _HomeView extends StatelessWidget {
  const _HomeView();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NavCubit, int>(
      builder: (context, currentIndex) {
        return Scaffold(
          appBar: HomeAppBar(
            onSearchTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const SearchScreen()),
            ),
          ),
          body: IndexedStack(
            index: currentIndex,
            children: const [
              _HomeTab(),
              _PlaceholderTab(icon: Icons.chat_bubble_outline_rounded, label: 'Chat'),
              _PlaceholderTab(icon: Icons.add_circle_outline_rounded, label: 'New'),
              _PlaceholderTab(icon: Icons.notifications_outlined, label: 'Notifications'),
              _PlaceholderTab(icon: Icons.person_outline_rounded, label: 'Profile'),
            ],
          ),
          bottomNavigationBar: AppNavBar(
            currentIndex: currentIndex,
            onTap: (index) => context.read<NavCubit>().setTab(index),
            badgeCounts: const {1: 2, 3: 3},
          ),
        );
      },
    );
  }
}

// ── Home tab ──────────────────────────────────────────────────────────────────

class _HomeTab extends StatefulWidget {
  const _HomeTab();

  @override
  State<_HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<_HomeTab> {
  // Mode managed here for now; will move to profile settings later
  final _UserMode _mode = _UserMode.sender;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;
    final textSecondary = isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;

    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Greeting + mode pill ────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Good to have you back 👋',
                  style: TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: textSecondary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'What\'s happening today?',
                  style: TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.4,
                    color: textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                _ModePill(mode: _mode),
              ],
            ),
          ),

          // ── In delivery ─────────────────────────────────────────────
          if (_deliveries.isNotEmpty) ...[
            const SizedBox(height: 20),
            _SectionHeader(
              title: 'In delivery',
              isDark: isDark,
              onSeeAll: () {},
            ),
            const SizedBox(height: 12),
            _InDeliveryList(isDark: isDark),
            const SizedBox(height: 15),
          ],

          // ── Engagements ─────────────────────────────────────────────
          if (_engagements.isNotEmpty) ...[
            _SectionHeader(
              title: 'Engagements',
              isDark: isDark,
              onSeeAll: () {},
            ),
            const SizedBox(height: 14),
            _EngagementList(isDark: isDark),
            const SizedBox(height: 28),
          ],

          // ── Available carriers / Offer requests ─────────────────────
          if (_deliveries.isEmpty && _engagements.isEmpty)
            const SizedBox(height: 20),
          _SectionHeader(
            title: _mode == _UserMode.sender
                ? 'Available carriers'
                : 'Offer requests',
            isDark: isDark,
            onSeeAll: () {},
          ),
          const SizedBox(height: 14),
          if (_mode == _UserMode.sender)
            _CarrierOfferList(isDark: isDark)
          else
            _OfferRequestList(isDark: isDark),
        ],
      ),
    );
  }
}

// ── Mode pill ─────────────────────────────────────────────────────────────────

class _ModePill extends StatelessWidget {
  final _UserMode mode;
  const _ModePill({required this.mode});

  @override
  Widget build(BuildContext context) {
    final label = mode == _UserMode.sender ? 'Sender mode' : 'Carrier mode';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: const BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 5),
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'Manrope',
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Section header ────────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String title;
  final bool isDark;
  final VoidCallback? onSeeAll;

  const _SectionHeader({
    required this.title,
    required this.isDark,
    this.onSeeAll,
  });

  @override
  Widget build(BuildContext context) {
    final textPrimary = isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              fontFamily: 'Manrope',
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: textPrimary,
            ),
          ),
          GestureDetector(
            onTap: onSeeAll,
            child: Row(
              children: [
                const Text(
                  'See all',
                  style: TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: 2),
                const Icon(Icons.arrow_forward_ios_rounded,
                    size: 11, color: AppColors.primary),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── In delivery ───────────────────────────────────────────────────────────────

class _DeliveryItem {
  final String item, from, fromCode, to, toCode, partner, partnerRole, updatedAt;
  final _DeliveryStatus status;

  const _DeliveryItem({
    required this.item,
    required this.from,
    required this.fromCode,
    required this.to,
    required this.toCode,
    required this.partner,
    required this.partnerRole,
    required this.updatedAt,
    required this.status,
  });
}

enum _DeliveryStatus { pickedUp, inTransit, nearDestination }

extension _DeliveryStatusX on _DeliveryStatus {
  String get label => switch (this) {
        _DeliveryStatus.pickedUp => 'Picked up',
        _DeliveryStatus.inTransit => 'In transit',
        _DeliveryStatus.nearDestination => 'Almost there',
      };

  Color get color => switch (this) {
        _DeliveryStatus.pickedUp => const Color(0xFFED8936),
        _DeliveryStatus.inTransit => const Color(0xFF4299E1),
        _DeliveryStatus.nearDestination => const Color(0xFF48BB78),
      };

  double get progress => switch (this) {
        _DeliveryStatus.pickedUp => 0.25,
        _DeliveryStatus.inTransit => 0.6,
        _DeliveryStatus.nearDestination => 0.88,
      };
}

final _deliveries = [
  const _DeliveryItem(
    item: 'Consumer Electronics',
    from: 'New York',
    fromCode: 'JFK',
    to: 'London',
    toCode: 'LHR',
    partner: 'Samuel K.',
    partnerRole: 'Carrier',
    updatedAt: '2h ago',
    status: _DeliveryStatus.inTransit,
  ),
  const _DeliveryItem(
    item: 'Fashion & Clothing',
    from: 'Paris',
    fromCode: 'CDG',
    to: 'Nairobi',
    toCode: 'NBO',
    partner: 'Aisha M.',
    partnerRole: 'Carrier',
    updatedAt: '5h ago',
    status: _DeliveryStatus.pickedUp,
  ),
];

class _InDeliveryList extends StatelessWidget {
  final bool isDark;
  const _InDeliveryList({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 148,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(20, 2, 20, 16),
        itemCount: _deliveries.length,
        separatorBuilder: (context, _) => const SizedBox(width: 10),
        itemBuilder: (_, i) =>
            _DeliveryCard(item: _deliveries[i], isDark: isDark),
      ),
    );
  }
}

class _DeliveryCard extends StatelessWidget {
  final _DeliveryItem item;
  final bool isDark;

  const _DeliveryCard({required this.item, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final textPrimary = isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;
    final textSecondary = isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;
    final screenWidth = MediaQuery.of(context).size.width;

    return Container(
      width: screenWidth * 0.68,
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 4),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.07),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Status + time
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                item.status.label,
                style: TextStyle(
                  fontFamily: 'Manrope',
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: item.status.color,
                ),
              ),
              Text(
                item.updatedAt,
                style: TextStyle(
                  fontFamily: 'Manrope',
                  fontSize: 10,
                  color: textSecondary,
                ),
              ),
            ],
          ),

          const SizedBox(height: 6),

          Text(
            item.item,
            style: TextStyle(
              fontFamily: 'Manrope',
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: textPrimary,
            ),
          ),

          const SizedBox(height: 4),

          Row(
            children: [
              Text(
                item.fromCode,
                style: TextStyle(
                  fontFamily: 'Manrope',
                  fontSize: 11,
                  color: textSecondary,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Icon(Icons.arrow_forward_rounded,
                    size: 10, color: textSecondary),
              ),
              Text(
                item.toCode,
                style: TextStyle(
                  fontFamily: 'Manrope',
                  fontSize: 11,
                  color: textSecondary,
                ),
              ),
              const Spacer(),
              Text(
                item.partner,
                style: TextStyle(
                  fontFamily: 'Manrope',
                  fontSize: 10,
                  color: textSecondary,
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // Progress bar
          LinearProgressIndicator(
            value: item.status.progress,
            minHeight: 3,
            borderRadius: BorderRadius.circular(3),
            backgroundColor: isDark
                ? AppColors.darkBorder
                : const Color(0xFFEEF0F3),
            valueColor: AlwaysStoppedAnimation<Color>(item.status.color),
          ),
        ],
      ),
    );
  }
}

// ── Engagements ───────────────────────────────────────────────────────────────

class _EngagementItem {
  final String title, fromCode, toCode, partner, date;
  final _EngagementStatus status;

  const _EngagementItem({
    required this.title,
    required this.fromCode,
    required this.toCode,
    required this.partner,
    required this.date,
    required this.status,
  });
}

enum _EngagementStatus { matched, proposalSent, proposalReceived, pending }

extension _EngagementStatusX on _EngagementStatus {
  String get label => switch (this) {
        _EngagementStatus.matched => 'Matched',
        _EngagementStatus.proposalSent => 'Proposal sent',
        _EngagementStatus.proposalReceived => 'Proposal received',
        _EngagementStatus.pending => 'Pending',
      };

  Color get color => switch (this) {
        _EngagementStatus.matched => const Color(0xFF48BB78),
        _EngagementStatus.proposalSent => const Color(0xFF4299E1),
        _EngagementStatus.proposalReceived => const Color(0xFF9F7AEA),
        _EngagementStatus.pending => const Color(0xFFA0AEC0),
      };
}

final _engagements = [
  const _EngagementItem(
    title: 'Tokyo Electronics',
    fromCode: 'JFK',
    toCode: 'NRT',
    partner: 'Aisha M.',
    date: 'Jun 12',
    status: _EngagementStatus.matched,
  ),
  const _EngagementItem(
    title: 'Books — London',
    fromCode: 'YYZ',
    toCode: 'LHR',
    partner: 'Carlos R.',
    date: 'Jun 18',
    status: _EngagementStatus.proposalSent,
  ),
  const _EngagementItem(
    title: 'Fashion Package',
    fromCode: 'CDG',
    toCode: 'LOS',
    partner: 'Sara T.',
    date: 'Jun 20',
    status: _EngagementStatus.proposalReceived,
  ),
];

class _EngagementList extends StatelessWidget {
  final bool isDark;
  const _EngagementList({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: _engagements.length.clamp(0, 2),
      separatorBuilder: (context, _) => const SizedBox(height: 6),
      itemBuilder: (_, i) =>
          _EngagementCard(item: _engagements[i], isDark: isDark),
    );
  }
}

class _EngagementCard extends StatelessWidget {
  final _EngagementItem item;
  final bool isDark;

  const _EngagementCard({required this.item, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final surface = isDark ? AppColors.darkSurface : AppColors.surface;
    final textPrimary = isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;
    final textSecondary = isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          // Status dot
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(
              color: item.status.color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),

          // Info
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
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: textPrimary,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 7, vertical: 2),
                      decoration: BoxDecoration(
                        color: item.status.color.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
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
                const SizedBox(height: 3),
                Row(
                  children: [
                    _RouteChip(code: item.fromCode, isDark: isDark),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 5),
                      child: Icon(Icons.arrow_forward_rounded,
                          size: 11, color: textSecondary),
                    ),
                    _RouteChip(code: item.toCode, isDark: isDark),
                    const SizedBox(width: 8),
                    Text(
                      '· ${item.partner} · ${item.date}',
                      style: TextStyle(
                        fontFamily: 'Manrope',
                        fontSize: 11,
                        color: textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(width: 8),
          Icon(Icons.chevron_right_rounded,
              size: 18,
              color: isDark
                  ? AppColors.darkTextTertiary
                  : const Color(0xFFD1D5DB)),
        ],
      ),
    );
  }
}

// ── Carrier offer list (Sender mode) ─────────────────────────────────────────

class _CarrierOffer {
  final String name, fromCity, fromCode, toCity, toCode, date;
  final double rating, startingPricePerKg, maxWeightKg;
  final int reviews, itemCount;
  final Color avatarColor;
  final bool isVerified;

  const _CarrierOffer({
    required this.name,
    required this.rating,
    required this.reviews,
    required this.fromCity,
    required this.fromCode,
    required this.toCity,
    required this.toCode,
    required this.date,
    required this.startingPricePerKg,
    required this.maxWeightKg,
    required this.itemCount,
    required this.avatarColor,
    this.isVerified = true,
  });
}

final _carrierOffers = [
  const _CarrierOffer(
    name: 'Samuel K.',
    rating: 4.9,
    reviews: 128,
    fromCity: 'New York',
    fromCode: 'JFK',
    toCity: 'London',
    toCode: 'LHR',
    date: 'Jun 12',
    startingPricePerKg: 3.20,
    maxWeightKg: 12,
    itemCount: 4,
    avatarColor: Color(0xFF4299E1),
  ),
  const _CarrierOffer(
    name: 'Aisha M.',
    rating: 5.0,
    reviews: 64,
    fromCity: 'Dubai',
    fromCode: 'DXB',
    toCity: 'Addis Ababa',
    toCode: 'ADD',
    date: 'Jun 14',
    startingPricePerKg: 2.80,
    maxWeightKg: 8,
    itemCount: 3,
    avatarColor: Color(0xFF48BB78),
  ),
  const _CarrierOffer(
    name: 'Carlos R.',
    rating: 4.7,
    reviews: 43,
    fromCity: 'Madrid',
    fromCode: 'MAD',
    toCity: 'Lagos',
    toCode: 'LOS',
    date: 'Jun 18',
    startingPricePerKg: 4.50,
    maxWeightKg: 5,
    itemCount: 2,
    avatarColor: Color(0xFF9F7AEA),
    isVerified: false,
  ),
];

class _CarrierOfferList extends StatelessWidget {
  final bool isDark;
  const _CarrierOfferList({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: _carrierOffers.length,
      separatorBuilder: (context, _) => const SizedBox(height: 14),
      itemBuilder: (_, i) =>
          _CarrierOfferCard(offer: _carrierOffers[i], isDark: isDark),
    );
  }
}

class _CarrierOfferCard extends StatelessWidget {
  final _CarrierOffer offer;
  final bool isDark;

  const _CarrierOfferCard({required this.offer, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final surface = isDark ? AppColors.darkSurface : Colors.white;
    final textPrimary =
        isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;
    final textSecondary =
        isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;
    final textTertiary =
        isDark ? AppColors.darkTextTertiary : AppColors.textTertiary;
    final divider =
        isDark ? AppColors.darkBorder : const Color(0xFFF3F4F6);

    return Container(
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.22 : 0.06),
            blurRadius: 14,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header: avatar + identity ───────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Avatar
                Stack(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            offer.avatarColor,
                            offer.avatarColor.withValues(alpha: 0.7),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Center(
                        child: Text(
                          offer.name[0],
                          style: const TextStyle(
                            fontFamily: 'Manrope',
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    if (offer.isVerified)
                      Positioned(
                        bottom: -2,
                        right: -2,
                        child: Container(
                          width: 18,
                          height: 18,
                          decoration: BoxDecoration(
                            color: AppColors.success,
                            shape: BoxShape.circle,
                            border: Border.all(color: surface, width: 2),
                          ),
                          child: const Icon(
                            Icons.check,
                            size: 10,
                            color: Colors.white,
                          ),
                        ),
                      ),
                  ],
                ),

                const SizedBox(width: 12),

                // Name + rating
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            offer.name,
                            style: TextStyle(
                              fontFamily: 'Manrope',
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: textPrimary,
                              letterSpacing: -0.2,
                            ),
                          ),
                          const SizedBox(width: 6),
                          if (offer.isVerified)
                            Text(
                              'Verified',
                              style: TextStyle(
                                fontFamily: 'Manrope',
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: AppColors.success,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 3),
                      Row(
                        children: [
                          const Icon(Icons.star_rounded,
                              color: Color(0xFFF6AD55), size: 13),
                          const SizedBox(width: 3),
                          Text(
                            offer.rating.toString(),
                            style: TextStyle(
                              fontFamily: 'Manrope',
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: textPrimary,
                            ),
                          ),
                          Text(
                            '  ·  ${offer.reviews} reviews',
                            style: TextStyle(
                              fontFamily: 'Manrope',
                              fontSize: 11,
                              color: textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          Divider(height: 1, color: divider),

          // ── Route: dotted flight path ───────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
            child: Row(
              children: [
                // From
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      offer.fromCode,
                      style: TextStyle(
                        fontFamily: 'Manrope',
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: textPrimary,
                        letterSpacing: -0.5,
                      ),
                    ),
                    Text(
                      offer.fromCity,
                      style: TextStyle(
                        fontFamily: 'Manrope',
                        fontSize: 10,
                        color: textTertiary,
                      ),
                    ),
                  ],
                ),

                // Dotted path
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(width: 8),
                        _DottedLine(isDark: isDark),
                        const SizedBox(width: 4),
                        Icon(Icons.flight,
                            size: 16, color: AppColors.primary),
                        const SizedBox(width: 4),
                        _DottedLine(isDark: isDark),
                        const SizedBox(width: 8),
                      ],
                    ),
                  ),
                ),

                // To
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      offer.toCode,
                      style: TextStyle(
                        fontFamily: 'Manrope',
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: textPrimary,
                        letterSpacing: -0.5,
                      ),
                    ),
                    Text(
                      offer.toCity,
                      style: TextStyle(
                        fontFamily: 'Manrope',
                        fontSize: 10,
                        color: textTertiary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // ── Date ────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 14),
            child: Row(
              children: [
                Icon(Icons.calendar_today_outlined,
                    size: 11, color: textTertiary),
                const SizedBox(width: 4),
                Text(
                  offer.date,
                  style: TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 12,
                    color: textSecondary,
                  ),
                ),
              ],
            ),
          ),

          Divider(height: 1, color: divider),

          // ── Stats row ───────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
            child: Row(
              children: [
                _StatCell(
                  label: 'From',
                  value:
                      '\$${offer.startingPricePerKg.toStringAsFixed(2)}/kg',
                  valueColor: AppColors.primary,
                  isDark: isDark,
                ),
                _StatDivider(isDark: isDark),
                _StatCell(
                  label: 'Capacity',
                  value: '${offer.maxWeightKg} kg',
                  isDark: isDark,
                ),
                _StatDivider(isDark: isDark),
                _StatCell(
                  label: 'Offers',
                  value: '${offer.itemCount} items',
                  isDark: isDark,
                ),
                const Spacer(),
                // Match CTA
                GestureDetector(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 18, vertical: 9),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppColors.primary, AppColors.primaryLight],
                      ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Text(
                      'Match',
                      style: const TextStyle(
                        fontFamily: 'Manrope',
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
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
              color: isDark
                  ? AppColors.darkBorder
                  : const Color(0xFFD1D5DB),
              borderRadius: BorderRadius.circular(1),
            ),
          ),
        ),
      ),
    );
  }
}

class _StatCell extends StatelessWidget {
  final String label, value;
  final Color? valueColor;
  final bool isDark;

  const _StatCell({
    required this.label,
    required this.value,
    required this.isDark,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    final textPrimary =
        isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;
    final textSecondary =
        isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontFamily: 'Manrope',
            fontSize: 10,
            color: textSecondary,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            fontFamily: 'Manrope',
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: valueColor ?? textPrimary,
          ),
        ),
      ],
    );
  }
}

class _StatDivider extends StatelessWidget {
  final bool isDark;
  const _StatDivider({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 28,
      margin: const EdgeInsets.symmetric(horizontal: 14),
      color: isDark ? AppColors.darkBorder : const Color(0xFFF3F4F6),
    );
  }
}

// ── Offer request list (Carrier mode) ────────────────────────────────────────

final _offerRequests = [
  _OfferRequest(
    title: 'Consumer Electronics',
    icon: Icons.devices_rounded,
    iconColor: const Color(0xFF4299E1),
    fromCode: 'LHR',
    toCode: 'NBO',
    weightKg: 3.5,
    deadline: 'Jun 15',
    budgetUsd: 55,
  ),
  _OfferRequest(
    title: 'Fashion & Clothing',
    icon: Icons.checkroom_rounded,
    iconColor: const Color(0xFF9F7AEA),
    fromCode: 'CDG',
    toCode: 'ACC',
    weightKg: 2.0,
    deadline: 'Jun 20',
    budgetUsd: 38,
  ),
];

class _OfferRequest {
  final String title, fromCode, toCode, deadline;
  final IconData icon;
  final Color iconColor;
  final double weightKg;
  final int budgetUsd;

  const _OfferRequest({
    required this.title,
    required this.icon,
    required this.iconColor,
    required this.fromCode,
    required this.toCode,
    required this.weightKg,
    required this.deadline,
    required this.budgetUsd,
  });
}

class _OfferRequestList extends StatelessWidget {
  final bool isDark;
  const _OfferRequestList({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: _offerRequests.length,
      separatorBuilder: (context, _) => const SizedBox(height: 12),
      itemBuilder: (_, i) =>
          _OfferRequestCard(request: _offerRequests[i], isDark: isDark),
    );
  }
}

class _OfferRequestCard extends StatelessWidget {
  final _OfferRequest request;
  final bool isDark;

  const _OfferRequestCard({required this.request, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final surface = isDark ? AppColors.darkSurface : Colors.white;
    final textPrimary = isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;
    final textSecondary = isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;
    final divider = isDark ? AppColors.darkBorder : const Color(0xFFF1F5F9);

    return Container(
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(18),
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 12,
                  offset: const Offset(0, 2),
                )
              ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: request.iconColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(request.icon, color: request.iconColor, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(request.title,
                          style: TextStyle(
                            fontFamily: 'Manrope',
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: textPrimary,
                          )),
                      const SizedBox(height: 2),
                      Text('${request.weightKg} kg · By ${request.deadline}',
                          style: TextStyle(
                              fontFamily: 'Manrope',
                              fontSize: 12,
                              color: textSecondary)),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: AppColors.success.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '\$${request.budgetUsd}',
                    style: const TextStyle(
                      fontFamily: 'Manrope',
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.success,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Divider(height: 1, color: divider),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
            child: Row(
              children: [
                Expanded(
                  child: Row(children: [
                    _RouteChip(code: request.fromCode, isDark: isDark),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      child: Icon(Icons.arrow_forward_rounded,
                          size: 13, color: textSecondary),
                    ),
                    _RouteChip(code: request.toCode, isDark: isDark),
                  ]),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppColors.darkBackground
                        : const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isDark
                          ? AppColors.darkBorder
                          : const Color(0xFFE2E8F0),
                    ),
                  ),
                  child: Text(
                    'Send Proposal',
                    style: TextStyle(
                      fontFamily: 'Manrope',
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: textPrimary,
                    ),
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

// ── Shared route chip ─────────────────────────────────────────────────────────

class _RouteChip extends StatelessWidget {
  final String code;
  final bool isDark;

  const _RouteChip({required this.code, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkBackground : const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(5),
      ),
      child: Text(
        code,
        style: TextStyle(
          fontFamily: 'Manrope',
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
        ),
      ),
    );
  }
}

// ── Generic tab placeholder ───────────────────────────────────────────────────

class _PlaceholderTab extends StatelessWidget {
  final IconData icon;
  final String label;

  const _PlaceholderTab({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 48,
              color: isDark
                  ? AppColors.darkTextTertiary
                  : const Color(0xFFD1D5DB)),
          const SizedBox(height: 12),
          Text(
            '$label — coming soon',
            style: TextStyle(
              fontFamily: 'Manrope',
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: isDark
                  ? AppColors.darkTextSecondary
                  : AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
