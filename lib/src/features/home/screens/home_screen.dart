import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/nav_cubit.dart';
import '../cubit/user_mode_cubit.dart';
import '../../items/repository/item_repository.dart';
import '../../offer_requests/cubit/browse_offer_requests_cubit.dart';
import '../../offer_requests/cubit/offer_requests_cubit.dart';
import '../../offer_requests/models/offer_request_models.dart';
import '../../offer_requests/repository/offer_request_repository.dart';
import '../../offer_requests/screens/browse_offer_requests_screen.dart';
import '../../offer_requests/screens/offer_requests_screen.dart';
import '../../offer_requests/widgets/create_offer_request_bubble.dart';
import '../widgets/home_app_bar.dart';
import '../widgets/app_nav_bar.dart';
import '../../../core/theme/app_colors.dart';
import '../../airports/repository/airport_repository.dart';
import '../../countries/repository/country_repository.dart';
import '../../flights/repository/flight_repository.dart';
import '../../items/repository/item_repository.dart';
import '../../offers/repository/offer_repository.dart';
import '../../offers/screens/offers_screen.dart';
import '../../offers/widgets/create_offer_bubble.dart';
import '../../search/screens/search_screen.dart';
import 'carrier_offer_detail_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // UserModeCubit + OfferRequestsCubit are provided app-wide in main.dart.
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => NavCubit()),
        BlocProvider(
          create: (context) =>
              BrowseOfferRequestsCubit(context.read<OfferRequestRepository>()),
        ),
      ],
      child: const _HomeView(),
    );
  }
}

class _HomeView extends StatefulWidget {
  const _HomeView();

  @override
  State<_HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<_HomeView> {
  final _plusKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    // Warm reference-data caches once (now that we're authenticated) so the
    // create bubbles open instantly without waiting on the network. The repos
    // are singletons and cache in-memory, so later reads come from cache.
    context.read<ItemRepository>().fetchItems().ignore();
    context.read<CountryRepository>().fetchCountries().ignore();
  }

  void _onPlusTap(BuildContext context) {
    // Switch to the activity tab (index 2) so created items land there
    context.read<NavCubit>().setTab(2);

    final mode = context.read<UserModeCubit>().state;
    if (mode == UserMode.carrier) {
      showCreateOfferBubble(
        context,
        plusKey: _plusKey,
        airports: context.read<AirportRepository>(),
        flights: context.read<FlightRepository>(),
        offers: context.read<OfferRepository>(),
        items: context.read<ItemRepository>(),
      );
    } else {
      _openRequestBubble(context);
    }
  }

  // Opens the offer-request bubble for create (existing == null) or edit.
  void _openRequestBubble(BuildContext context,
      {OfferRequestResponse? existing}) {
    final listCubit = context.read<OfferRequestsCubit>();
    showCreateOfferRequestBubble(
      context,
      plusKey: _plusKey,
      items: context.read<ItemRepository>(),
      offerRequests: context.read<OfferRequestRepository>(),
      countries: context.read<CountryRepository>(),
      existing: existing,
      onSaved: (response) => existing == null
          ? listCubit.prepend(response)
          : listCubit.update(response),
    );
  }

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
            children: [
              const _HomeTab(),
              const _PlaceholderTab(
                  icon: Icons.chat_bubble_outline_rounded, label: 'Chat'),
              // Third tab switches with sender/carrier mode
              BlocBuilder<UserModeCubit, UserMode>(
                builder: (context, mode) => mode == UserMode.sender
                    ? OfferRequestsScreen(
                        onEdit: (req) =>
                            _openRequestBubble(context, existing: req),
                      )
                    : const OffersScreen(),
              ),
              const _PlaceholderTab(
                  icon: Icons.notifications_outlined, label: 'Notifications'),
              const _PlaceholderTab(
                  icon: Icons.person_outline_rounded, label: 'Profile'),
            ],
          ),
          bottomNavigationBar: AppNavBar(
            currentIndex: currentIndex,
            onTap: (index) => context.read<NavCubit>().setTab(index),
            badgeCounts: const {1: 2, 3: 3},
            plusKey: _plusKey,
            onPlusTap: () => _onPlusTap(context),
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
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;
    final textSecondary = isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;

    return BlocBuilder<UserModeCubit, UserMode>(
      builder: (context, mode) {
        return SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Greeting + mode pill ──────────────────────────────────
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
                      "What's happening today?",
                      style: TextStyle(
                        fontFamily: 'Manrope',
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.4,
                        color: textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _ModePill(
                      mode: mode,
                      onTap: () => _showModePicker(context, mode),
                    ),
                  ],
                ),
              ),

              // ── In delivery ───────────────────────────────────────────
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

              // ── Engagements ───────────────────────────────────────────
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

              // ── Available carriers / Offer requests ───────────────────
              if (_deliveries.isEmpty && _engagements.isEmpty)
                const SizedBox(height: 20),
              _SectionHeader(
                title: mode == UserMode.sender
                    ? 'Available carriers'
                    : 'Offer requests',
                isDark: isDark,
                onSeeAll: mode == UserMode.carrier
                    ? () => openBrowseSeeAll(context)
                    : () {},
              ),
              const SizedBox(height: 14),
              if (mode == UserMode.sender)
                _CarrierOfferList(isDark: isDark)
              else
                BrowseOfferRequestsPreview(isDark: isDark),
            ],
          ),
        );
      },
    );
  }

  void _showModePicker(BuildContext context, UserMode current) {
    showDialog<void>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.4),
      builder: (_) => _ModePickerDialog(
        currentMode: current,
        onSelect: (mode) {
          context.read<UserModeCubit>().setMode(mode);
          Navigator.of(context).pop();
        },
      ),
    );
  }
}

// ── Mode pill ─────────────────────────────────────────────────────────────────

class _ModePill extends StatelessWidget {
  final UserMode mode;
  final VoidCallback onTap;
  const _ModePill({required this.mode, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: AppColors.success.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 6,
              height: 6,
              decoration: const BoxDecoration(
                color: AppColors.success,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 5),
            Text(
              mode.pillLabel,
              style: const TextStyle(
                fontFamily: 'Manrope',
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppColors.success,
              ),
            ),
            const SizedBox(width: 3),
            const Icon(
              Icons.keyboard_arrow_down_rounded,
              size: 13,
              color: AppColors.success,
            ),
          ],
        ),
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
    return SizedBox(
      height: 88,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: _engagements.length,
        separatorBuilder: (context, _) => const SizedBox(height: 6),
        itemBuilder: (_, i) =>
            _EngagementCard(item: _engagements[i], isDark: isDark),
      ),
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
  final double rating, startingPrice, maxCapacity;
  final String priceUnit, capacityUnit;
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
    required this.startingPrice,
    required this.priceUnit,
    required this.maxCapacity,
    required this.capacityUnit,
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
    startingPrice: 3.20,
    priceUnit: 'kg',
    maxCapacity: 12,
    capacityUnit: 'kg',
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
    startingPrice: 1.50,
    priceUnit: 'piece',
    maxCapacity: 20,
    capacityUnit: 'pieces',
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
    startingPrice: 4.50,
    priceUnit: 'kg',
    maxCapacity: 5,
    capacityUnit: 'kg',
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
    final textPrimary = isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;
    final textSecondary = isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;
    final textTertiary = isDark ? AppColors.darkTextTertiary : AppColors.textTertiary;

    return Container(
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
          // ── Header ─────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
            child: Row(
              children: [
                Column(
                  children: [
                    Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            offer.avatarColor,
                            offer.avatarColor.withValues(alpha: 0.65),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(13),
                      ),
                      child: Center(
                        child: Text(
                          offer.name[0],
                          style: const TextStyle(
                            fontFamily: 'Manrope',
                            fontSize: 19,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    if (offer.isVerified) ...[
                      const SizedBox(height: 3),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 5, vertical: 2),
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
                              offer.name,
                              style: TextStyle(
                                fontFamily: 'Manrope',
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: textPrimary,
                                letterSpacing: -0.3,
                              ),
                            ),
                          ),
                          const Spacer(),
                          GestureDetector(
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => CarrierOfferDetailScreen(
                                  name: offer.name,
                                  fromCode: offer.fromCode,
                                  fromCity: offer.fromCity,
                                  toCode: offer.toCode,
                                  toCity: offer.toCity,
                                  date: offer.date,
                                  rating: offer.rating,
                                  reviews: offer.reviews,
                                  startingPrice: offer.startingPrice,
                                  priceUnit: offer.priceUnit,
                                  maxCapacity: offer.maxCapacity,
                                  capacityUnit: offer.capacityUnit,
                                  itemCount: offer.itemCount,
                                  avatarColor: offer.avatarColor,
                                  isVerified: offer.isVerified,
                                ),
                              ),
                            ),
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
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.star_rounded,
                              color: Color(0xFFF6AD55), size: 13),
                          const SizedBox(width: 3),
                          Text(
                            offer.rating.toStringAsFixed(1),
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

          // ── Route strip ────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 0, 14, 0),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkBackground : Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  // Origin
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        offer.fromCode,
                        style: TextStyle(
                          fontFamily: 'Manrope',
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.6,
                          color: textPrimary,
                        ),
                      ),
                      Text(
                        offer.fromCity,
                        style: TextStyle(
                          fontFamily: 'Manrope',
                          fontSize: 9,
                          color: textTertiary,
                        ),
                      ),
                    ],
                  ),

                  // Flight path + date
                  Expanded(
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _DottedLine(isDark: isDark),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 4),
                              child: Icon(Icons.flight_rounded,
                                  size: 11, color: AppColors.primary),
                            ),
                            _DottedLine(isDark: isDark),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.calendar_today_outlined,
                                size: 8, color: textTertiary),
                            const SizedBox(width: 3),
                            Text(
                              offer.date,
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
                    ),
                  ),

                  // Destination
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        offer.toCode,
                        style: TextStyle(
                          fontFamily: 'Manrope',
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.6,
                          color: textPrimary,
                        ),
                      ),
                      Text(
                        offer.toCity,
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

          // ── Price + CTA ─────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
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
                                '\$${offer.startingPrice.toStringAsFixed(2)}',
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
                                '/ ${offer.priceUnit}',
                                style: TextStyle(
                                  fontFamily: 'Manrope',
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: textSecondary,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                '·',
                                style: TextStyle(
                                  fontFamily: 'Manrope',
                                  fontSize: 11,
                                  color: textTertiary,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Flexible(
                                child: Text(
                                  'Up to ${offer.maxCapacity % 1 == 0 ? offer.maxCapacity.toInt() : offer.maxCapacity} ${offer.capacityUnit}  ·  ${offer.itemCount} ${offer.itemCount == 1 ? 'slot' : 'slots'}',
                                  style: TextStyle(
                                    fontFamily: 'Manrope',
                                    fontSize: 10,
                                    color: textTertiary,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    GestureDetector(
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

// ── Mode picker dialog ────────────────────────────────────────────────────────

class _ModePickerDialog extends StatelessWidget {
  final UserMode currentMode;
  final ValueChanged<UserMode> onSelect;

  const _ModePickerDialog({
    required this.currentMode,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.darkSurface : Colors.white;
    final textPrimary =
        isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;
    final textSecondary =
        isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.88, end: 1.0),
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeOutBack,
      builder: (_, scale, child) =>
          Transform.scale(scale: scale, child: child),
      child: Dialog(
        backgroundColor: bg,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        insetPadding: const EdgeInsets.symmetric(horizontal: 32),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 22, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.swap_horiz_rounded,
                        size: 18, color: AppColors.primary),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Switch mode',
                        style: TextStyle(
                          fontFamily: 'Manrope',
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: textPrimary,
                          letterSpacing: -0.3,
                        ),
                      ),
                      Text(
                        'How are you using Airpick today?',
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
              const SizedBox(height: 20),
              // Mode cards
              Row(
                children: [
                  Expanded(
                    child: _ModeCard(
                      mode: UserMode.sender,
                      isActive: currentMode == UserMode.sender,
                      isDark: isDark,
                      onTap: () => onSelect(UserMode.sender),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _ModeCard(
                      mode: UserMode.carrier,
                      isActive: currentMode == UserMode.carrier,
                      isDark: isDark,
                      onTap: () => onSelect(UserMode.carrier),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ModeCard extends StatelessWidget {
  final UserMode mode;
  final bool isActive;
  final bool isDark;
  final VoidCallback onTap;

  const _ModeCard({
    required this.mode,
    required this.isActive,
    required this.isDark,
    required this.onTap,
  });

  IconData get _icon => mode == UserMode.sender
      ? Icons.inventory_2_rounded
      : Icons.flight_rounded;

  @override
  Widget build(BuildContext context) {
    final surface = isDark ? AppColors.darkBackground : AppColors.surface;
    final textPrimary =
        isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;
    final textSecondary =
        isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
        decoration: BoxDecoration(
          color: isActive
              ? AppColors.primary.withValues(alpha: 0.07)
              : surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isActive
                ? AppColors.primary
                : (isDark ? AppColors.darkBorder : AppColors.border),
            width: isActive ? 1.5 : 1.0,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: isActive
                    ? AppColors.primary.withValues(alpha: 0.12)
                    : (isDark ? AppColors.darkSurface : Colors.white),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                _icon,
                size: 20,
                color: isActive
                    ? AppColors.primary
                    : (isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.textSecondary),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              mode.label,
              style: TextStyle(
                fontFamily: 'Manrope',
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: isActive ? AppColors.primary : textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              mode.description,
              style: TextStyle(
                fontFamily: 'Manrope',
                fontSize: 10,
                color: textSecondary,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 10),
            AnimatedOpacity(
              opacity: isActive ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 200),
              child: Row(
                children: [
                  const Icon(Icons.check_circle_rounded,
                      size: 13, color: AppColors.primary),
                  const SizedBox(width: 4),
                  const Text(
                    'Active',
                    style: TextStyle(
                      fontFamily: 'Manrope',
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
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
