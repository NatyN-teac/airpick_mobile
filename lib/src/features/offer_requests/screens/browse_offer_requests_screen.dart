import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/skeleton_list.dart';
import '../../countries/models/country.dart';
import '../../countries/repository/country_repository.dart';
import '../../countries/widgets/country_picker_field.dart';
import '../cubit/browse_offer_requests_cubit.dart';
import '../models/offer_request_models.dart';
import '../repository/offer_request_repository.dart';
import '../widgets/browse_request_card.dart';
import 'create_proposal_screen.dart';

// Send Proposal opens the full proposal flow (creates a flight, then proposal).
// On success the request is no longer OPEN, so drop it from the browse list.
void launchSendProposal(BuildContext context, OfferRequestResponse req) {
  final cubit = context.read<BrowseOfferRequestsCubit>();
  openCreateProposal(context, req, onSent: () => cubit.remove(req.id));
}

// ── Home preview (top few) ────────────────────────────────────────────────────

class BrowseOfferRequestsPreview extends StatefulWidget {
  final bool isDark;
  const BrowseOfferRequestsPreview({super.key, required this.isDark});

  @override
  State<BrowseOfferRequestsPreview> createState() =>
      _BrowseOfferRequestsPreviewState();
}

class _BrowseOfferRequestsPreviewState
    extends State<BrowseOfferRequestsPreview> {
  @override
  void initState() {
    super.initState();
    context.read<BrowseOfferRequestsCubit>().load();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BrowseOfferRequestsCubit, BrowseOfferRequestsState>(
      builder: (context, state) {
        if (state.loading && state.requests.isEmpty) {
          return const SkeletonPreviewList(count: 3);
        }
        if (state.requests.isEmpty) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: Text(
              'No requests available right now.',
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
        final preview = state.requests.take(3).toList();
        return Column(
          children: [
            for (final req in preview)
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 14),
                child: BrowseRequestCard(
                  request: req,
                  isDark: widget.isDark,
                  onTap: () => showBrowseRequestDetail(context, req,
                      onSendProposal: () => launchSendProposal(context, req)),
                  onSendProposal: () => launchSendProposal(context, req),
                ),
              ),
          ],
        );
      },
    );
  }
}

// ── See-all screen (full list + filters) ──────────────────────────────────────

void openBrowseSeeAll(BuildContext context) {
  final repo = context.read<OfferRequestRepository>();
  Navigator.of(context).push(
    MaterialPageRoute(
      builder: (_) => BlocProvider(
        create: (_) => BrowseOfferRequestsCubit(repo)..load(),
        child: const BrowseOfferRequestsScreen(),
      ),
    ),
  );
}

class BrowseOfferRequestsScreen extends StatelessWidget {
  const BrowseOfferRequestsScreen({super.key});

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
        title: Text('Browse Requests',
            style: TextStyle(
              fontFamily: 'Manrope',
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: textPrimary,
              letterSpacing: -0.3,
            )),
        actions: [
          BlocBuilder<BrowseOfferRequestsCubit, BrowseOfferRequestsState>(
            builder: (context, state) => IconButton(
              icon: Stack(
                clipBehavior: Clip.none,
                children: [
                  Icon(Icons.tune_rounded, color: textPrimary, size: 22),
                  if (state.hasFilters)
                    const Positioned(
                      right: -1,
                      top: -1,
                      child: CircleAvatar(
                          radius: 4, backgroundColor: AppColors.primary),
                    ),
                ],
              ),
              onPressed: () => _openFilterSheet(context, state),
            ),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: BlocBuilder<BrowseOfferRequestsCubit, BrowseOfferRequestsState>(
        builder: (context, state) {
          if (state.loading && state.requests.isEmpty) {
            return const SkeletonList();
          }
          if (state.requests.isEmpty) {
            return Center(
              child: Text(
                state.hasFilters
                    ? 'No requests match your filters.'
                    : 'No requests available.',
                style: TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 13,
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.textSecondary),
              ),
            );
          }
          return RefreshIndicator(
            color: AppColors.primary,
            onRefresh: () =>
                context.read<BrowseOfferRequestsCubit>().load(force: true),
            child: ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
              itemCount: state.requests.length,
              itemBuilder: (_, i) {
                final req = state.requests[i];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: BrowseRequestCard(
                    request: req,
                    isDark: isDark,
                    onTap: () => showBrowseRequestDetail(context, req,
                        onSendProposal: () => launchSendProposal(context, req)),
                    onSendProposal: () => launchSendProposal(context, req),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  void _openFilterSheet(
      BuildContext context, BrowseOfferRequestsState state) {
    final cubit = context.read<BrowseOfferRequestsCubit>();
    final countryRepo = context.read<CountryRepository>();
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _FilterSheet(
        initial: state,
        countryRepo: countryRepo,
        onApply: (src, dst, city) =>
            cubit.applyFilters(
                sourceCountry: src, destinationCountry: dst, sourceCity: city),
        onClear: cubit.clearFilters,
      ),
    );
  }
}

// ── Filter sheet ──────────────────────────────────────────────────────────────

class _FilterSheet extends StatefulWidget {
  final BrowseOfferRequestsState initial;
  final CountryRepository countryRepo;
  final void Function(String?, String?, String?) onApply;
  final VoidCallback onClear;

  const _FilterSheet({
    required this.initial,
    required this.countryRepo,
    required this.onApply,
    required this.onClear,
  });

  @override
  State<_FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<_FilterSheet> {
  late final TextEditingController _city =
      TextEditingController(text: widget.initial.sourceCity ?? '');
  List<Country> _countries = [];
  bool _loading = true;
  Country? _src;
  Country? _dst;

  @override
  void initState() {
    super.initState();
    _loadCountries();
  }

  Future<void> _loadCountries() async {
    try {
      final list = await widget.countryRepo.fetchCountries();
      if (!mounted) return;
      Country? match(String? name) {
        if (name == null || name.isEmpty) return null;
        final hit = list.where((c) => c.name == name);
        return hit.isNotEmpty ? hit.first : null;
      }

      setState(() {
        _countries = list;
        _src = match(widget.initial.sourceCountry);
        _dst = match(widget.initial.destinationCountry);
        _loading = false;
      });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _city.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.darkSurface : Colors.white;
    final textPrimary =
        isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      padding: EdgeInsets.fromLTRB(
          20, 16, 20, MediaQuery.of(context).viewInsets.bottom + 28),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.textDisabled.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text('Filter requests',
              style: TextStyle(
                fontFamily: 'Manrope',
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: textPrimary,
                letterSpacing: -0.3,
              )),
          const SizedBox(height: 16),
          Flexible(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _FilterLabel('Source country', isDark: isDark),
                  const SizedBox(height: 6),
                  CountryPickerField(
                    isDark: isDark,
                    countries: _countries,
                    selected: _src,
                    loading: _loading,
                    hint: 'Any country',
                    onSelected: (c) => setState(() => _src = c),
                  ),
                  const SizedBox(height: 12),
                  _FilterLabel('Destination country', isDark: isDark),
                  const SizedBox(height: 6),
                  CountryPickerField(
                    isDark: isDark,
                    countries: _countries,
                    selected: _dst,
                    loading: _loading,
                    hint: 'Any country',
                    onSelected: (c) => setState(() => _dst = c),
                  ),
                  const SizedBox(height: 12),
                  _FilterLabel('Source city', isDark: isDark),
                  const SizedBox(height: 6),
                  _CityField(controller: _city, isDark: isDark),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    widget.onClear();
                    Navigator.of(context).pop();
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    decoration: BoxDecoration(
                      color:
                          isDark ? AppColors.darkBackground : AppColors.surface,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text('Clear',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'Manrope',
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: textPrimary,
                        )),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    widget.onApply(
                      _src?.name,
                      _dst?.name,
                      _city.text.trim().isEmpty ? null : _city.text.trim(),
                    );
                    Navigator.of(context).pop();
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text('Apply',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'Manrope',
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        )),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _FilterLabel extends StatelessWidget {
  final String text;
  final bool isDark;
  const _FilterLabel(this.text, {required this.isDark});

  @override
  Widget build(BuildContext context) => Text(
        text,
        style: TextStyle(
          fontFamily: 'Manrope',
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.3,
          color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
        ),
      );
}

class _CityField extends StatelessWidget {
  final TextEditingController controller;
  final bool isDark;
  const _CityField({required this.controller, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final surface = isDark ? AppColors.darkBackground : AppColors.surface;
    final border = isDark ? AppColors.darkBorder : AppColors.border;
    final textPrimary =
        isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;

    return TextField(
      controller: controller,
      style:
          TextStyle(fontFamily: 'Manrope', fontSize: 13, color: textPrimary),
      decoration: InputDecoration(
        hintText: 'Any',
        hintStyle: TextStyle(
            fontFamily: 'Manrope',
            fontSize: 13,
            color:
                isDark ? AppColors.darkTextTertiary : AppColors.textTertiary),
        filled: true,
        fillColor: surface,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: border)),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: border)),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide:
                const BorderSide(color: AppColors.primary, width: 1.5)),
      ),
    );
  }
}
