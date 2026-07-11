import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/state_message.dart';
import '../../home/cubit/user_mode_cubit.dart';
import '../../offer_requests/models/offer_request_models.dart';
import '../../offer_requests/repository/offer_request_repository.dart';
import '../../offer_requests/screens/create_proposal_screen.dart';
import '../../offer_requests/widgets/browse_request_card.dart';
import '../../offers/models/offer_response.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final FocusNode _focusNode = FocusNode();
  final TextEditingController _controller = TextEditingController();
  Timer? _debounce;
  int _searchVersion = 0;
  UserMode? _mode;
  String _query = '';
  _SearchScope _scope = _SearchScope.anywhere;
  bool _loading = false;
  bool _hasSearched = false;
  String? _error;
  List<OfferRequestResponse> _requestResults = const [];
  List<OfferResponse> _offerResults = const [];

  static const _initialRecentSearches = [
    'London, United Kingdom',
    'Dubai, UAE',
    'Addis Ababa, Ethiopia',
  ];
  late final List<String> _recentSearches = List<String>.from(
    _initialRecentSearches,
  );

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() => setState(() {}));
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _mode ??= context.read<UserModeCubit>().state;
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _focusNode.dispose();
    _controller.dispose();
    super.dispose();
  }

  Future<void> _performSearch({
    String? rawQuery,
    bool saveRecent = false,
  }) async {
    final query = (rawQuery ?? _query).trim();
    if (query.isEmpty) {
      if (!mounted) return;
      setState(() {
        _query = '';
        _loading = false;
        _hasSearched = false;
        _error = null;
        _requestResults = const [];
        _offerResults = const [];
      });
      return;
    }

    final version = ++_searchVersion;
    if (saveRecent) {
      _rememberSearch(query);
    }

    if (!mounted) return;
    setState(() {
      _query = query;
      _loading = true;
      _hasSearched = true;
      _error = null;
    });

    try {
      final results = await _searchRequests(query, _scope);

      if (!mounted || version != _searchVersion) return;
      setState(() {
        _requestResults = results;
        _offerResults = const [];
        _loading = false;
      });
    } catch (e) {
      if (!mounted || version != _searchVersion) return;
      setState(() {
        _loading = false;
        _requestResults = const [];
        _offerResults = const [];
        _error = e.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  Future<List<OfferRequestResponse>> _searchRequests(
    String query,
    _SearchScope scope,
  ) async {
    final repo = context.read<OfferRequestRepository>();
    return switch (scope) {
      _SearchScope.sourceCountry => repo.searchShipperRequests(
        sourceCountry: query,
      ),
      _SearchScope.sourceCity => repo.searchShipperRequests(sourceCity: query),
      _SearchScope.destinationCountry => repo.searchShipperRequests(
        destinationCountry: query,
      ),
      // "Anywhere" is a free-text search: the backend filters are AND-combined
      // per field, so run each field query and merge the unique results. This
      // makes a general search match on origin OR destination (previously it
      // only matched the source country, so destinations never surfaced).
      _SearchScope.anywhere => _searchAnywhere(repo, query),
    };
  }

  Future<List<OfferRequestResponse>> _searchAnywhere(
    OfferRequestRepository repo,
    String query,
  ) async {
    final batches = await Future.wait([
      repo.searchShipperRequests(sourceCountry: query),
      repo.searchShipperRequests(sourceCity: query),
      repo.searchShipperRequests(destinationCountry: query),
    ]);
    final seen = <String>{};
    final merged = <OfferRequestResponse>[];
    for (final batch in batches) {
      for (final request in batch) {
        if (seen.add(request.id)) merged.add(request);
      }
    }
    return merged;
  }

  void _onQueryChanged(String value) {
    setState(() => _query = value);
    _debounce?.cancel();
    if (value.trim().isEmpty) {
      setState(() {
        _loading = false;
        _hasSearched = false;
        _error = null;
        _requestResults = const [];
        _offerResults = const [];
      });
      return;
    }
    _debounce = Timer(
      const Duration(milliseconds: 350),
      () => _performSearch(rawQuery: value),
    );
  }

  void _rememberSearch(String value) {
    final query = value.trim();
    if (query.isEmpty) return;
    _recentSearches.removeWhere(
      (entry) => entry.toLowerCase() == query.toLowerCase(),
    );
    _recentSearches.insert(0, query);
    if (_recentSearches.length > 8) {
      _recentSearches.removeLast();
    }
  }

  void _useSearch(String value, {bool saveRecent = true}) {
    _controller.value = TextEditingValue(
      text: value,
      selection: TextSelection.collapsed(offset: value.length),
    );
    _debounce?.cancel();
    _performSearch(rawQuery: value, saveRecent: saveRecent);
  }

  void _onScopeSelected(_SearchScope scope) {
    if (_scope == scope) return;
    setState(() => _scope = scope);
    if (_query.trim().isNotEmpty) {
      _performSearch(rawQuery: _query);
    }
  }

  void _onModeChanged(UserMode mode) {
    if (_mode == mode) return;
    setState(() {
      _mode = mode;
      _loading = false;
      _hasSearched = false;
      _error = null;
      _requestResults = const [];
      _offerResults = const [];

      _scope = _SearchScope.anywhere;
    });
    if (_query.trim().isNotEmpty) {
      _performSearch(rawQuery: _query);
    }
  }

  List<String> _quickSearches(UserMode mode) => switch ((mode, _scope)) {
    (UserMode.carrier, _SearchScope.sourceCountry) => const [
      'Ethiopia',
      'China',
      'United States',
      'Canada',
    ],
    (UserMode.carrier, _SearchScope.sourceCity) => const [
      'Addis Ababa',
      'Adama',
      'Dire Dawa',
      'Bahir Dar',
    ],
    (UserMode.carrier, _SearchScope.destinationCountry) => const [
      'China',
      'United States',
      'UAE',
      'United Kingdom',
    ],
    (UserMode.carrier, _) => const [
      'Ethiopia',
      'Addis Ababa',
      'China',
      'United States',
    ],
    (UserMode.sender, _SearchScope.sourceCountry) => const [
      'Ethiopia',
      'UAE',
      'United Kingdom',
      'Canada',
    ],
    (UserMode.sender, _SearchScope.sourceCity) => const [
      'Dubai',
      'London',
      'Addis Ababa',
      'Toronto',
    ],
    (UserMode.sender, _SearchScope.destinationCountry) => const [
      'Ethiopia',
      'United States',
      'Canada',
      'France',
    ],
    (UserMode.sender, _) => const ['Dubai', 'London', 'Addis Ababa', 'Toronto'],
  };

  String _hintText(UserMode mode) => switch ((mode, _scope)) {
    (UserMode.carrier, _SearchScope.sourceCountry) =>
      'Enter source country, e.g. Ethiopia',
    (UserMode.carrier, _SearchScope.sourceCity) =>
      'Enter source city, e.g. Addis Ababa',
    (UserMode.carrier, _SearchScope.destinationCountry) =>
      'Enter destination country, e.g. China',
    (UserMode.carrier, _) => 'Enter source country, e.g. Ethiopia',
    (UserMode.sender, _SearchScope.sourceCountry) =>
      'Enter carrier origin country',
    (UserMode.sender, _SearchScope.sourceCity) => 'Enter carrier origin city',
    (UserMode.sender, _SearchScope.destinationCountry) =>
      'Enter carrier destination country',
    (UserMode.sender, _) => 'Search carriers by route, city or item',
  };

  String _scopeTitle(UserMode mode) => mode == UserMode.carrier
      ? 'Filter shipper requests by'
      : 'Filter carriers by';

  String _scopeDescription(UserMode mode) => switch ((mode, _scope)) {
    (UserMode.carrier, _SearchScope.sourceCountry) =>
      'The text field matches the request source country only.',
    (UserMode.carrier, _SearchScope.sourceCity) =>
      'The text field matches the request source city only.',
    (UserMode.carrier, _SearchScope.destinationCountry) =>
      'The text field matches the request destination country only.',
    (UserMode.carrier, _) =>
      'Uses source country for the search request. Pick a filter for city or destination.',
    (UserMode.sender, _SearchScope.sourceCountry) =>
      'The text field matches the carrier origin country.',
    (UserMode.sender, _SearchScope.sourceCity) =>
      'The text field matches the carrier origin city or pickup area.',
    (UserMode.sender, _SearchScope.destinationCountry) =>
      'The text field matches the carrier destination or delivery area.',
    (UserMode.sender, _) =>
      'The text field searches broadly across route, carrier, and item fields.',
  };

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final mode = _mode ?? context.read<UserModeCubit>().state;
    final bg = isDark ? AppColors.darkBackground : AppColors.background;
    final surface = isDark ? AppColors.darkSurface : AppColors.surface;
    final textPrimary = isDark
        ? AppColors.darkTextPrimary
        : AppColors.textPrimary;
    final textSecondary = isDark
        ? AppColors.darkTextSecondary
        : AppColors.textSecondary;
    final textTertiary = isDark
        ? AppColors.darkTextTertiary
        : AppColors.textTertiary;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.border;

    return BlocListener<UserModeCubit, UserMode>(
      listener: (context, state) => _onModeChanged(state),
      child: Scaffold(
        backgroundColor: bg,
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 52,
                        decoration: BoxDecoration(
                          color: surface,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: _focusNode.hasFocus
                                ? AppColors.primary
                                : borderColor,
                            width: _focusNode.hasFocus ? 1.5 : 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            const SizedBox(width: 14),
                            Icon(
                              Icons.search_rounded,
                              size: 20,
                              color: textTertiary,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: TextField(
                                controller: _controller,
                                focusNode: _focusNode,
                                textInputAction: TextInputAction.search,
                                onChanged: _onQueryChanged,
                                onSubmitted: (value) => _useSearch(value),
                                style: TextStyle(
                                  fontFamily: 'Manrope',
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                  color: textPrimary,
                                ),
                                decoration: InputDecoration(
                                  hintText: _hintText(mode),
                                  hintStyle: TextStyle(
                                    fontFamily: 'Manrope',
                                    fontSize: 14,
                                    color: textTertiary,
                                  ),
                                  border: InputBorder.none,
                                  enabledBorder: InputBorder.none,
                                  focusedBorder: InputBorder.none,
                                  disabledBorder: InputBorder.none,
                                  errorBorder: InputBorder.none,
                                  focusedErrorBorder: InputBorder.none,
                                  filled: false,
                                  isDense: true,
                                  contentPadding: EdgeInsets.zero,
                                ),
                              ),
                            ),
                            if (_query.isNotEmpty)
                              GestureDetector(
                                onTap: () {
                                  _debounce?.cancel();
                                  _controller.clear();
                                  _onQueryChanged('');
                                },
                                child: Padding(
                                  padding: const EdgeInsets.only(right: 12),
                                  child: Icon(
                                    Icons.cancel_rounded,
                                    size: 18,
                                    color: textTertiary,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: Text(
                        'Cancel',
                        style: TextStyle(
                          fontFamily: 'Manrope',
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: _ModeBanner(
                  isDark: isDark,
                  mode: mode,
                  resultCount: mode == UserMode.carrier
                      ? _requestResults.length
                      : _offerResults.length,
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
                child: _FilterSelector(
                  isDark: isDark,
                  title: _scopeTitle(mode),
                  selectedLabel: _scope.label,
                  helper: _scopeDescription(mode),
                  onTap: () => _openScopePicker(context, mode),
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: _query.trim().isEmpty
                    ? _IdleSearchView(
                        isDark: isDark,
                        surface: surface,
                        textPrimary: textPrimary,
                        textSecondary: textSecondary,
                        quickSearches: _quickSearches(mode),
                        recentSearches: _recentSearches,
                        onClearRecent: () =>
                            setState(() => _recentSearches.clear()),
                        onRecentTap: _useSearch,
                        onQuickSearchTap: _useSearch,
                      )
                    : _SearchResultsView(
                        isDark: isDark,
                        query: _query.trim(),
                        loading: _loading,
                        error: _error,
                        hasSearched: _hasSearched,
                        requestResults: _requestResults,
                        onRefresh: () => _performSearch(rawQuery: _query),
                        onSendProposal: (request) {
                          _rememberSearch(_query);
                          openCreateProposal(
                            context,
                            request,
                            onSent: () {
                              if (!mounted) return;
                              setState(() {
                                _requestResults = _requestResults
                                    .where((it) => it.id != request.id)
                                    .toList();
                              });
                            },
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _openScopePicker(BuildContext context, UserMode mode) async {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final selected = await showModalBottomSheet<_SearchScope>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) =>
          _ScopePickerSheet(isDark: isDark, mode: mode, selected: _scope),
    );
    if (selected != null) {
      _onScopeSelected(selected);
    }
  }
}

enum _SearchScope { anywhere, sourceCountry, sourceCity, destinationCountry }

extension _SearchScopeX on _SearchScope {
  String get label => switch (this) {
    _SearchScope.anywhere => 'Anywhere',
    _SearchScope.sourceCountry => 'Origin country',
    _SearchScope.sourceCity => 'Origin city',
    _SearchScope.destinationCountry => 'Destination',
  };
}

class _RecentItem extends StatelessWidget {
  final String label;
  final Color surface, textPrimary, textSecondary;
  final VoidCallback onTap;

  const _RecentItem({
    required this.label,
    required this.surface,
    required this.textPrimary,
    required this.textSecondary,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        decoration: BoxDecoration(
          color: surface,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(Icons.history_rounded, size: 18, color: textSecondary),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontFamily: 'Manrope',
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: textPrimary,
                ),
              ),
            ),
            Icon(Icons.north_west_rounded, size: 14, color: textSecondary),
          ],
        ),
      ),
    );
  }
}

class _IdleSearchView extends StatelessWidget {
  final bool isDark;
  final Color surface;
  final Color textPrimary;
  final Color textSecondary;
  final List<String> recentSearches;
  final List<String> quickSearches;
  final VoidCallback onClearRecent;
  final ValueChanged<String> onRecentTap;
  final ValueChanged<String> onQuickSearchTap;

  const _IdleSearchView({
    required this.isDark,
    required this.surface,
    required this.textPrimary,
    required this.textSecondary,
    required this.recentSearches,
    required this.quickSearches,
    required this.onClearRecent,
    required this.onRecentTap,
    required this.onQuickSearchTap,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (recentSearches.isNotEmpty) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Recent searches',
                  style: TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: textSecondary,
                    letterSpacing: 0.2,
                  ),
                ),
                GestureDetector(
                  onTap: onClearRecent,
                  child: Text(
                    'Clear',
                    style: TextStyle(
                      fontFamily: 'Manrope',
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...recentSearches.map(
              (search) => _RecentItem(
                label: search,
                surface: surface,
                textPrimary: textPrimary,
                textSecondary: textSecondary,
                onTap: () => onRecentTap(search),
              ),
            ),
            const SizedBox(height: 28),
          ],
          Text(
            'Quick searches',
            style: TextStyle(
              fontFamily: 'Manrope',
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: textSecondary,
              letterSpacing: 0.2,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: quickSearches
                .map(
                  (label) => _QuickSearchChip(
                    label: label,
                    isDark: isDark,
                    surface: surface,
                    textPrimary: textPrimary,
                    onTap: () => onQuickSearchTap(label),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }
}

class _QuickSearchChip extends StatelessWidget {
  final String label;
  final bool isDark;
  final Color surface;
  final Color textPrimary;
  final VoidCallback onTap;

  const _QuickSearchChip({
    required this.label,
    required this.isDark,
    required this.surface,
    required this.textPrimary,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDark ? AppColors.darkBorder : AppColors.border,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: 'Manrope',
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: textPrimary,
          ),
        ),
      ),
    );
  }
}

class _ModeBanner extends StatelessWidget {
  final bool isDark;
  final UserMode mode;
  final int resultCount;

  const _ModeBanner({
    required this.isDark,
    required this.mode,
    required this.resultCount,
  });

  @override
  Widget build(BuildContext context) {
    final surface = isDark ? AppColors.darkSurface : Colors.white;
    final textPrimary = isDark
        ? AppColors.darkTextPrimary
        : AppColors.textPrimary;
    final textSecondary = isDark
        ? AppColors.darkTextSecondary
        : AppColors.textSecondary;

    final title = mode == UserMode.carrier
        ? 'Search shipper requests'
        : 'Search available carriers';
    final subtitle = mode == UserMode.carrier
        ? 'Searches open shipper requests via the shipper search endpoint.'
        : 'Filters available carriers by route, area, carrier name, and item.';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.border,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              mode == UserMode.carrier
                  ? Icons.inventory_2_rounded
                  : Icons.flight_takeoff_rounded,
              size: 18,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: textPrimary,
                    letterSpacing: -0.2,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 12,
                    color: textSecondary,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
          if (resultCount > 0)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                '$resultCount',
                style: const TextStyle(
                  fontFamily: 'Manrope',
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _FilterSelector extends StatelessWidget {
  final bool isDark;
  final VoidCallback onTap;
  final String title;
  final String selectedLabel;
  final String helper;

  const _FilterSelector({
    required this.isDark,
    required this.onTap,
    required this.title,
    required this.selectedLabel,
    required this.helper,
  });

  @override
  Widget build(BuildContext context) {
    final surface = isDark ? AppColors.darkSurface : Colors.white;
    final textPrimary = isDark
        ? AppColors.darkTextPrimary
        : AppColors.textPrimary;
    final textSecondary = isDark
        ? AppColors.darkTextSecondary
        : AppColors.textSecondary;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
        decoration: BoxDecoration(
          color: surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark ? AppColors.darkBorder : AppColors.border,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: AppColors.info.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.tune_rounded,
                size: 18,
                color: AppColors.info,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontFamily: 'Manrope',
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: textSecondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          selectedLabel,
                          style: TextStyle(
                            fontFamily: 'Manrope',
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: textPrimary,
                            letterSpacing: -0.2,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(
                        Icons.keyboard_arrow_down_rounded,
                        size: 18,
                        color: AppColors.primary,
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    helper,
                    style: TextStyle(
                      fontFamily: 'Manrope',
                      fontSize: 11,
                      color: textSecondary,
                      height: 1.35,
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

class _ScopePickerSheet extends StatelessWidget {
  final bool isDark;
  final UserMode mode;
  final _SearchScope selected;

  const _ScopePickerSheet({
    required this.isDark,
    required this.mode,
    required this.selected,
  });

  @override
  Widget build(BuildContext context) {
    final bg = isDark ? AppColors.darkSurface : Colors.white;
    final textPrimary = isDark
        ? AppColors.darkTextPrimary
        : AppColors.textPrimary;
    final textSecondary = isDark
        ? AppColors.darkTextSecondary
        : AppColors.textSecondary;

    String descriptionFor(_SearchScope scope) => switch ((mode, scope)) {
      (UserMode.carrier, _SearchScope.sourceCountry) =>
        'Use the typed value only as source country.',
      (UserMode.carrier, _SearchScope.sourceCity) =>
        'Use the typed value only as source city.',
      (UserMode.carrier, _SearchScope.destinationCountry) =>
        'Use the typed value only as destination country.',
      (UserMode.carrier, _) =>
        'Search across source country, source city, and destination.',
      (UserMode.sender, _SearchScope.sourceCountry) =>
        'Use the typed value as carrier origin country.',
      (UserMode.sender, _SearchScope.sourceCity) =>
        'Use the typed value as carrier origin city.',
      (UserMode.sender, _SearchScope.destinationCountry) =>
        'Use the typed value as carrier destination country.',
      (UserMode.sender, _) => 'Search broadly across available carrier fields.',
    };

    IconData iconFor(_SearchScope scope) => switch (scope) {
      _SearchScope.anywhere => Icons.travel_explore_rounded,
      _SearchScope.sourceCountry => Icons.public_rounded,
      _SearchScope.sourceCity => Icons.location_city_rounded,
      _SearchScope.destinationCountry => Icons.flag_rounded,
    };

    return Container(
      decoration: BoxDecoration(
        color: bg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
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
              Text(
                'Choose search filter',
                style: TextStyle(
                  fontFamily: 'Manrope',
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: textPrimary,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Your single text field will use the selected filter below.',
                style: TextStyle(
                  fontFamily: 'Manrope',
                  fontSize: 12,
                  color: textSecondary,
                  height: 1.35,
                ),
              ),
              const SizedBox(height: 14),
              ..._SearchScope.values.map(
                (scope) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _ScopeOptionTile(
                    isDark: isDark,
                    title: scope.label,
                    description: descriptionFor(scope),
                    icon: iconFor(scope),
                    selected: selected == scope,
                    onTap: () => Navigator.of(context).pop(scope),
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

class _ScopeOptionTile extends StatelessWidget {
  final bool isDark;
  final String title;
  final String description;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _ScopeOptionTile({
    required this.isDark,
    required this.title,
    required this.description,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final surface = isDark ? AppColors.darkBackground : AppColors.surface;
    final textPrimary = isDark
        ? AppColors.darkTextPrimary
        : AppColors.textPrimary;
    final textSecondary = isDark
        ? AppColors.darkTextSecondary
        : AppColors.textSecondary;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary.withValues(alpha: 0.09) : surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected
                ? AppColors.primary
                : (isDark ? AppColors.darkBorder : AppColors.border),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: selected
                    ? AppColors.primary.withValues(alpha: 0.15)
                    : AppColors.info.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                size: 18,
                color: selected ? AppColors.primary : AppColors.info,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontFamily: 'Manrope',
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: textPrimary,
                      letterSpacing: -0.2,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(
                      fontFamily: 'Manrope',
                      fontSize: 12,
                      color: textSecondary,
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Icon(
              selected
                  ? Icons.radio_button_checked_rounded
                  : Icons.radio_button_off_rounded,
              size: 20,
              color: selected ? AppColors.primary : textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}

class _SearchResultsView extends StatelessWidget {
  final bool isDark;
  final String query;
  final bool loading;
  final String? error;
  final bool hasSearched;
  final List<OfferRequestResponse> requestResults;
  final Future<void> Function() onRefresh;
  final ValueChanged<OfferRequestResponse> onSendProposal;

  const _SearchResultsView({
    required this.isDark,
    required this.query,
    required this.loading,
    required this.error,
    required this.hasSearched,
    required this.requestResults,
    required this.onRefresh,
    required this.onSendProposal,
  });

  @override
  Widget build(BuildContext context) {
    final textSecondary = isDark
        ? AppColors.darkTextSecondary
        : AppColors.textSecondary;

    final resultCount = requestResults.length;

    if (loading && resultCount == 0) {
      return const Center(
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: AppColors.primary,
        ),
      );
    }

    if (error != null && resultCount == 0) {
      return Center(
        child: AppErrorState(
          title: 'Search failed',
          message: error!,
          onRetry: onRefresh,
          padding: const EdgeInsets.symmetric(horizontal: 28),
        ),
      );
    }

    if (hasSearched && resultCount == 0) {
      return RefreshIndicator(
        color: AppColors.primary,
        onRefresh: onRefresh,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            SizedBox(height: MediaQuery.of(context).size.height * 0.18),
            AppEmptyState(
              icon: Icons.search_off_rounded,
              title: 'No shipper requests matched "$query".',
              message: 'Try a different country, city, or destination.',
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: onRefresh,
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 28),
        itemCount: resultCount + 1,
        itemBuilder: (context, index) {
          if (index == 0) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(4, 0, 4, 14),
              child: Row(
                children: [
                  Text(
                    '$resultCount result${resultCount == 1 ? '' : 's'} for "$query"',
                    style: TextStyle(
                      fontFamily: 'Manrope',
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: textSecondary,
                    ),
                  ),
                  if (loading) ...[
                    const SizedBox(width: 8),
                    const SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ],
              ),
            );
          }

          final resultIndex = index - 1;
          final request = requestResults[resultIndex];
          return Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: BrowseRequestCard(
              request: request,
              isDark: isDark,
              onTap: () => showBrowseRequestDetail(
                context,
                request,
                onSendProposal: () => onSendProposal(request),
              ),
              onSendProposal: () => onSendProposal(request),
            ),
          );
        },
      ),
    );
  }
}
