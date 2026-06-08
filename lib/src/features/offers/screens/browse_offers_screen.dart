import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/skeleton_list.dart';
import '../cubit/browse_offers_cubit.dart';
import '../models/offer_response.dart';
import '../repository/offer_repository.dart';
import '../widgets/browse_offer_card.dart';
import '../../matches/screens/create_match_screen.dart';

// ── Home preview (top few) ────────────────────────────────────────────────────

void launchBrowseMatch(BuildContext context, OfferResponse offer) {
  final browseCubit = context.read<BrowseOffersCubit>();
  openCreateMatch(
    context,
    offer,
    onMatched: (response) => browseCubit.afterMatch(offer, response),
  );
}

class BrowseOffersPreview extends StatefulWidget {
  final bool isDark;
  const BrowseOffersPreview({super.key, required this.isDark});

  @override
  State<BrowseOffersPreview> createState() => _BrowseOffersPreviewState();
}

class _BrowseOffersPreviewState extends State<BrowseOffersPreview> {
  @override
  void initState() {
    super.initState();
    context.read<BrowseOffersCubit>().load();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BrowseOffersCubit, BrowseOffersState>(
      builder: (context, state) {
        if (state.loading && state.offers.isEmpty) {
          return const SkeletonPreviewList(count: 3);
        }
        if (state.error != null && state.offers.isEmpty) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: Column(
              children: [
                Text(
                  'Could not load carriers.',
                  style: TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 13,
                    color: widget.isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () =>
                      context.read<BrowseOffersCubit>().load(force: true),
                  child: const Text('Retry',
                      style: TextStyle(fontFamily: 'Manrope')),
                ),
              ],
            ),
          );
        }
        if (state.offers.isEmpty) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: Text(
              'No carriers available right now.',
              style: TextStyle(
                fontFamily: 'Manrope',
                fontSize: 13,
                color: widget.isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.textSecondary,
              ),
            ),
          );
        }
        final preview = state.offers.take(3).toList();
        return Column(
          children: [
            for (final offer in preview)
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 14),
                child: BrowseOfferCard(
                  offer: offer,
                  isDark: widget.isDark,
                  onMatch: () => launchBrowseMatch(context, offer),
                ),
              ),
          ],
        );
      },
    );
  }
}

// ── See-all screen ────────────────────────────────────────────────────────────

void openBrowseOffersSeeAll(BuildContext context) {
  final repo = context.read<OfferRepository>();
  Navigator.of(context).push(
    MaterialPageRoute(
      builder: (_) => BlocProvider(
        create: (_) => BrowseOffersCubit(repo)..load(),
        child: const BrowseOffersScreen(),
      ),
    ),
  );
}

class BrowseOffersScreen extends StatelessWidget {
  const BrowseOffersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.darkBackground : AppColors.background;
    final textPrimary =
        isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;

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
        title: Text(
          'Available Carriers',
          style: TextStyle(
            fontFamily: 'Manrope',
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: textPrimary,
            letterSpacing: -0.3,
          ),
        ),
      ),
      body: BlocBuilder<BrowseOffersCubit, BrowseOffersState>(
        builder: (context, state) {
          if (state.loading && state.offers.isEmpty) {
            return const SkeletonList();
          }
          if (state.offers.isEmpty) {
            return Center(
              child: Text(
                'No carriers available.',
                style: TextStyle(
                  fontFamily: 'Manrope',
                  fontSize: 13,
                  color: isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.textSecondary,
                ),
              ),
            );
          }
          return RefreshIndicator(
            color: AppColors.primary,
            onRefresh: () =>
                context.read<BrowseOffersCubit>().load(force: true),
            child: ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
              itemCount: state.offers.length,
              itemBuilder: (_, i) => Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: BrowseOfferCard(
                  offer: state.offers[i],
                  isDark: isDark,
                  onMatch: () =>
                      launchBrowseMatch(context, state.offers[i]),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
