import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/engagement_cubit.dart';
import '../cubit/nav_cubit.dart';
import '../cubit/user_mode_cubit.dart';
import '../models/engagement_models.dart';
import '../../items/repository/item_repository.dart';
import '../../offer_requests/cubit/browse_offer_requests_cubit.dart';
import '../../offer_requests/cubit/offer_requests_cubit.dart';
import '../../offer_requests/models/offer_request_models.dart';
import '../../offer_requests/repository/offer_request_repository.dart';
import '../../matches/repository/match_repository.dart';
import '../../offer_requests/screens/browse_offer_requests_screen.dart';
import '../../offer_requests/screens/offer_requests_screen.dart';
import '../../offer_requests/widgets/create_offer_request_bubble.dart';
import '../widgets/home_app_bar.dart';
import '../widgets/app_nav_bar.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/verification_gate.dart';
import '../../../core/widgets/skeleton_list.dart';
import '../../chat/cubit/chats_list_cubit.dart';
import '../../chat/cubit/chats_list_state.dart';
import '../../chat/repository/chat_repository.dart';
import '../../chat/screens/chats_list_screen.dart';
import '../../notifications/cubit/notifications_cubit.dart';
import '../../notifications/cubit/notifications_state.dart';
import '../../notifications/screens/notifications_screen.dart';
import '../../airports/repository/airport_repository.dart';
import '../../countries/repository/country_repository.dart';
import '../../flights/repository/flight_repository.dart';
import '../../offers/cubit/browse_offers_cubit.dart';
import '../../offers/cubit/offers_cubit.dart';
import '../../offers/repository/offer_repository.dart';
import '../../offers/screens/browse_offers_screen.dart';
import '../../offers/screens/edit_offer_screen.dart';
import '../../offers/screens/offers_screen.dart';
import '../../offers/widgets/create_offer_bubble.dart';
import '../../profile/cubit/current_user_cubit.dart';
import '../../profile/repository/user_repository.dart';
import '../../profile/screens/profile_screen.dart';
import '../../../core/storage/token_storage.dart';
import '../../search/screens/search_screen.dart';
import '../../matches/cubit/delivery_track_cubit.dart';
import '../../matches/screens/delivery_track_list_screen.dart';
import '../../matches/models/delivery_track_models.dart';
import '../../matches/widgets/delivery_track_card.dart';
import '../../chat/screens/chat_screen.dart';
import '../widgets/mode_picker_dialog.dart';
import 'engagements_list_screen.dart';

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
        BlocProvider(
          create: (context) =>
              BrowseOffersCubit(context.read<OfferRepository>()),
        ),
        BlocProvider(
          create: (context) => EngagementCubit(
            context.read<UserRepository>(),
            context.read<OfferRequestRepository>(),
          )..load(),
        ),
        BlocProvider(
          create: (context) =>
              DeliveryTrackCubit(context.read<MatchRepository>()),
        ),
        BlocProvider(
          create: (context) =>
              ChatsListCubit(context.read<ChatRepository>())..load(),
        ),
        BlocProvider(create: (_) => NotificationsCubit()),
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
  @override
  void initState() {
    super.initState();
    // Warm reference-data caches once (now that we're authenticated) so the
    // create bubbles open instantly without waiting on the network. The repos
    // are singletons and cache in-memory, so later reads come from cache.
    context.read<ItemRepository>().fetchItems().ignore();
    context.read<CountryRepository>().fetchCountries().ignore();
    context.read<CurrentUserCubit>().refreshFromServer(
      context.read<UserRepository>(),
      context.read<TokenStorage>(),
    );
    context.read<DeliveryTrackCubit>().load(
      mode: context.read<UserModeCubit>().state,
    );
  }

  // Opens the mode-appropriate create form as a bottom sheet.
  void _onCreateTap(BuildContext context) {
    final mode = context.read<UserModeCubit>().state;
    if (mode == UserMode.carrier) {
      // Offers require a verified identity — show an offer-specific message.
      if (!requireVerified(context, action: 'create an offer')) return;
      final offersCubit = context.read<OffersCubit>();
      showCreateOfferBubble(
        context,
        airports: context.read<AirportRepository>(),
        flights: context.read<FlightRepository>(),
        offers: context.read<OfferRepository>(),
        items: context.read<ItemRepository>(),
        onCreated: offersCubit.prepend, // optimistic — new offer on top
      );
    } else {
      _openRequestBubble(context);
    }
  }

  // Opens the offer-request bubble for create (existing == null) or edit.
  void _openRequestBubble(
    BuildContext context, {
    OfferRequestResponse? existing,
  }) {
    final listCubit = context.read<OfferRequestsCubit>();
    showCreateOfferRequestBubble(
      context,
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
    return BlocBuilder<ChatsListCubit, ChatsListState>(
      builder: (context, chatsState) {
        return BlocBuilder<NotificationsCubit, NotificationsState>(
          builder: (context, notificationsState) {
            return BlocBuilder<NavCubit, int>(
              builder: (context, currentIndex) {
                final badgeCounts = <int, int>{
                  if (chatsState.totalUnread > 0) 1: chatsState.totalUnread,
                  if (notificationsState.unreadCount > 0)
                    3: notificationsState.unreadCount,
                };

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
                      const ChatsListScreen(),
                      // Third tab switches with sender/carrier mode
                      BlocBuilder<UserModeCubit, UserMode>(
                        builder: (context, mode) => mode == UserMode.sender
                            ? OfferRequestsScreen(
                                onCreate: () => _onCreateTap(context),
                                onEdit: (req) =>
                                    _openRequestBubble(context, existing: req),
                              )
                            : OffersScreen(
                                onCreate: () => _onCreateTap(context),
                                onEdit: (offer) =>
                                    openEditOffer(context, offer),
                              ),
                      ),
                      const NotificationsScreen(),
                      const ProfileScreen(),
                    ],
                  ),
                  bottomNavigationBar: AppNavBar(
                    currentIndex: currentIndex,
                    onTap: (index) => context.read<NavCubit>().setTab(index),
                    badgeCounts: badgeCounts,
                    centerLabel:
                        context.watch<UserModeCubit>().state == UserMode.sender
                        ? 'Requests'
                        : 'Offers',
                  ),
                );
              },
            );
          },
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
  void _openEngagements(BuildContext context) {
    final engagementCubit = context.read<EngagementCubit>();
    final navCubit = context.read<NavCubit>();
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => MultiBlocProvider(
          providers: [
            BlocProvider.value(value: engagementCubit),
            BlocProvider.value(value: navCubit),
          ],
          child: const EngagementsListScreen(),
        ),
      ),
    );
  }

  Future<void> _refreshHome(UserMode mode) async {
    final futures = <Future<void>>[
      context.read<CurrentUserCubit>().refreshFromServer(
        context.read<UserRepository>(),
        context.read<TokenStorage>(),
      ),
      context.read<ItemRepository>().fetchItems(),
      context.read<CountryRepository>().fetchCountries(),
    ];
    if (mode == UserMode.sender) {
      futures.add(context.read<BrowseOffersCubit>().load(force: true));
    } else {
      futures.add(context.read<BrowseOfferRequestsCubit>().load(force: true));
    }
    futures.add(context.read<EngagementCubit>().load(force: true));
    futures.add(
      context.read<DeliveryTrackCubit>().load(mode: mode, force: true),
    );
    await Future.wait(futures);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark
        ? AppColors.darkTextPrimary
        : AppColors.textPrimary;
    final textSecondary = isDark
        ? AppColors.darkTextSecondary
        : AppColors.textSecondary;

    return BlocListener<UserModeCubit, UserMode>(
      listenWhen: (prev, next) => prev != next,
      listener: (context, mode) {
        context.read<DeliveryTrackCubit>().load(mode: mode, force: true);
      },
      child: BlocBuilder<UserModeCubit, UserMode>(
        builder: (context, mode) {
          return RefreshIndicator(
            color: AppColors.primary,
            onRefresh: () => _refreshHome(mode),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
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
                  BlocBuilder<DeliveryTrackCubit, DeliveryTrackState>(
                    builder: (context, trackState) {
                      if (trackState.loading && !trackState.hasDeliveries) {
                        return const Column(
                          children: [
                            SizedBox(height: 20),
                            _InDeliverySkeleton(),
                            SizedBox(height: 15),
                          ],
                        );
                      }
                      if (!trackState.hasDeliveries) {
                        return const SizedBox.shrink();
                      }
                      final preview = trackState.data!.preview(limit: 5);
                      return Column(
                        children: [
                          const SizedBox(height: 20),
                          _SectionHeader(
                            title: 'In delivery',
                            isDark: isDark,
                            onSeeAll: () => openDeliveryTrackList(context),
                          ),
                          const SizedBox(height: 12),
                          _InDeliveryPreview(
                            items: preview,
                            isDark: isDark,
                            viewerIsCarrier: mode == UserMode.carrier,
                          ),
                          const SizedBox(height: 15),
                        ],
                      );
                    },
                  ),

                  // ── Engagements ───────────────────────────────────────────
                  BlocBuilder<EngagementCubit, EngagementState>(
                    builder: (context, engState) {
                      if (engState.loading && engState.items.isEmpty) {
                        return const Column(
                          children: [
                            SizedBox(height: 20),
                            SkeletonEngagementTeaser(),
                            SizedBox(height: 28),
                          ],
                        );
                      }
                      if (engState.items.isEmpty) {
                        return const SizedBox.shrink();
                      }
                      return Column(
                        children: [
                          _SectionHeader(
                            title: 'Engagements',
                            isDark: isDark,
                            onSeeAll: () => _openEngagements(context),
                          ),
                          const SizedBox(height: 14),
                          _EngagementTeaser(
                            isDark: isDark,
                            items: engState.items,
                            onSeeAll: () => _openEngagements(context),
                          ),
                          const SizedBox(height: 28),
                        ],
                      );
                    },
                  ),

                  // ── Available carriers / Offer requests ───────────────────
                  BlocBuilder<EngagementCubit, EngagementState>(
                    builder: (context, engState) {
                      final noEngagements =
                          !engState.loading && engState.items.isEmpty;
                      final noDeliveries = !context
                          .watch<DeliveryTrackCubit>()
                          .state
                          .hasDeliveries;
                      final sectionTitle = mode == UserMode.sender
                          ? 'Available carriers'
                          : 'Offer requests';
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (noDeliveries && noEngagements)
                            const SizedBox(height: 20),
                          if (mode == UserMode.sender)
                            BlocBuilder<BrowseOffersCubit, BrowseOffersState>(
                              builder: (context, offerState) => _SectionHeader(
                                title: sectionTitle,
                                isDark: isDark,
                                onSeeAll: offerState.offers.isEmpty
                                    ? null
                                    : () => openBrowseOffersSeeAll(context),
                              ),
                            )
                          else
                            _SectionHeader(
                              title: sectionTitle,
                              isDark: isDark,
                              onSeeAll: () => openBrowseSeeAll(context),
                            ),
                          const SizedBox(height: 14),
                          if (mode == UserMode.sender)
                            BrowseOffersPreview(isDark: isDark)
                          else
                            BrowseOfferRequestsPreview(isDark: isDark),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _showModePicker(BuildContext context, UserMode current) {
    showModePickerDialog(
      context,
      currentMode: current,
      onSelect: (mode) async {
        await context.read<UserModeCubit>().setMode(mode);
        if (!context.mounted) return;
        if (mode == UserMode.sender) {
          context.read<BrowseOffersCubit>().load(force: true);
        } else {
          context.read<BrowseOfferRequestsCubit>().load(force: true);
        }
        context.read<EngagementCubit>().load(force: true);
        context.read<DeliveryTrackCubit>().load(mode: mode, force: true);
        if (context.mounted) Navigator.of(context).pop();
      },
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
    final textPrimary = isDark
        ? AppColors.darkTextPrimary
        : AppColors.textPrimary;
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
          if (onSeeAll != null)
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
                  const Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 11,
                    color: AppColors.primary,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

// ── In delivery ───────────────────────────────────────────────────────────────

class _InDeliveryPreview extends StatelessWidget {
  final List<TrackedDeliveryItem> items;
  final bool isDark;
  final bool viewerIsCarrier;

  const _InDeliveryPreview({
    required this.items,
    required this.isDark,
    required this.viewerIsCarrier,
  });

  @override
  Widget build(BuildContext context) {
    // A single delivery should fill the row instead of leaving a horizontal
    // gap on the right; multiple deliveries peek the next card at 72% width.
    const horizontalPadding = 20.0;
    final screenWidth = MediaQuery.of(context).size.width;
    final cardWidth = items.length == 1
        ? screenWidth - horizontalPadding * 2
        : screenWidth * 0.72;
    return SizedBox(
      height: 172,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(
            horizontalPadding, 2, horizontalPadding, 16),
        itemCount: items.length,
        separatorBuilder: (context, _) => const SizedBox(width: 10),
        itemBuilder: (_, i) => DeliveryTrackCard(
          item: items[i],
          isDark: isDark,
          viewerIsCarrier: viewerIsCarrier,
          width: cardWidth,
          onTap: () => openChatScreen(
            context,
            items[i].match.id,
            initialMatch: items[i].match,
          ),
        ),
      ),
    );
  }
}

class _InDeliverySkeleton extends StatelessWidget {
  const _InDeliverySkeleton();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surface = isDark ? AppColors.darkSurface : Colors.white;
    final cardWidth = MediaQuery.of(context).size.width * 0.72;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 100,
                height: 16,
                decoration: BoxDecoration(
                  color: surface,
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              Container(
                width: 56,
                height: 14,
                decoration: BoxDecoration(
                  color: surface,
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 172,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.fromLTRB(20, 2, 20, 16),
            itemCount: 2,
            separatorBuilder: (context, _) => const SizedBox(width: 10),
            itemBuilder: (context, _) => Container(
              width: cardWidth,
              decoration: BoxDecoration(
                color: surface,
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ── Engagements ───────────────────────────────────────────────────────────────

// Non-scrollable, attention-seeking teaser. Pulses softly to invite a tap
// to "See all". Performant — a single repeating controller drives a glow.
class _EngagementTeaser extends StatefulWidget {
  final bool isDark;
  final List<EngagementListItem> items;
  final VoidCallback onSeeAll;
  const _EngagementTeaser({
    required this.isDark,
    required this.items,
    required this.onSeeAll,
  });

  @override
  State<_EngagementTeaser> createState() => _EngagementTeaserState();
}

class _EngagementTeaserState extends State<_EngagementTeaser>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1600),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDark;
    final latest = widget.items.first;
    final count = widget.items.length;
    // `AppColors.secondary` is a dark charcoal that vanishes against the dark
    // card, so the bolt icon needs a light-on-dark accent in dark mode.
    final accent = isDark ? AppColors.darkTextPrimary : AppColors.secondary;
    final textPrimary = isDark
        ? AppColors.darkTextPrimary
        : AppColors.textPrimary;
    final textSecondary = isDark
        ? AppColors.darkTextSecondary
        : AppColors.textSecondary;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GestureDetector(
        onTap: widget.onSeeAll,
        child: AnimatedBuilder(
          animation: _c,
          builder: (context, child) {
            final t = Curves.easeInOut.transform(_c.value);
            return Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.secondary.withValues(
                      alpha: 0.08 + 0.16 * t,
                    ),
                    blurRadius: 14 + 14 * t,
                    spreadRadius: 0.5 * t,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: child,
            );
          },
          child: Container(
            padding: const EdgeInsets.fromLTRB(14, 13, 12, 13),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isDark
                    ? [
                        AppColors.secondaryLight.withValues(alpha: 0.30),
                        AppColors.darkSurface,
                      ]
                    : [
                        AppColors.secondary.withValues(alpha: 0.10),
                        Colors.white,
                      ],
              ),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: AppColors.secondary.withValues(alpha: 0.18),
              ),
            ),
            child: Row(
              children: [
                // Pulsing live badge
                AnimatedBuilder(
                  animation: _c,
                  builder: (context, _) {
                    final t = Curves.easeInOut.transform(_c.value);
                    return Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: accent.withValues(
                          alpha: 0.10 + 0.08 * t,
                        ),
                        borderRadius: BorderRadius.circular(13),
                      ),
                      child: Icon(
                        Icons.bolt_rounded,
                        size: 22,
                        color: accent,
                      ),
                    );
                  },
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          _LiveDot(controller: _c),
                          const SizedBox(width: 6),
                          Text(
                            '$count active engagement${count == 1 ? '' : 's'}',
                            style: TextStyle(
                              fontFamily: 'Manrope',
                              fontSize: 13.5,
                              fontWeight: FontWeight.w800,
                              color: textPrimary,
                              letterSpacing: -0.2,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 3),
                      Text(
                        'Latest: ${latest.title} · ${latest.fromCode}→${latest.toCode} · ${latest.status.label}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontFamily: 'Manrope',
                          fontSize: 11.5,
                          color: textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                // See all pill
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [AppColors.secondary, AppColors.secondaryLight],
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'See all',
                        style: TextStyle(
                          fontFamily: 'Manrope',
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(width: 2),
                      Icon(
                        Icons.arrow_forward_rounded,
                        size: 13,
                        color: Colors.white,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _LiveDot extends StatelessWidget {
  final Animation<double> controller;
  const _LiveDot({required this.controller});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final t = Curves.easeInOut.transform(controller.value);
        return Container(
          width: 7,
          height: 7,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.success,
            boxShadow: [
              BoxShadow(
                color: AppColors.success.withValues(alpha: 0.5 * (1 - t)),
                blurRadius: 6 * t,
                spreadRadius: 2 * t,
              ),
            ],
          ),
        );
      },
    );
  }
}
