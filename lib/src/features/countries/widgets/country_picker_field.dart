import 'package:flutter/material.dart';
import '../../../core/l10n/l10n.dart';
import '../../../core/theme/app_colors.dart';
import '../models/country.dart';

// Country field: tap to open a bottom sheet listing every supported country.
// Users pick from the list; the search box in the sheet is optional and never
// opens the keyboard on its own. Free text is not accepted.

class CountryPickerField extends StatelessWidget {
  final bool isDark;
  final List<Country> countries;
  final Country? selected;
  final String hint;
  final bool loading;
  final bool locked;
  final ValueChanged<Country> onSelected;

  const CountryPickerField({
    super.key,
    required this.isDark,
    required this.countries,
    required this.selected,
    required this.hint,
    required this.onSelected,
    this.loading = false,
    this.locked = false,
  });

  bool get _enabled => !loading && !locked && countries.isNotEmpty;

  Future<void> _open(BuildContext context) async {
    FocusScope.of(context).unfocus();
    final picked = await showCountryPickerSheet(
      context,
      countries: countries,
      selected: selected,
      isDark: isDark,
    );
    if (picked != null) onSelected(picked);
  }

  @override
  Widget build(BuildContext context) {
    final surface = isDark ? AppColors.darkBackground : AppColors.surface;
    final border = isDark ? AppColors.darkBorder : AppColors.border;
    final textPrimary =
        isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;
    final textSecondary =
        isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;
    final textTertiary =
        isDark ? AppColors.darkTextTertiary : AppColors.textTertiary;
    final country = selected;
    final hasValue = country != null;

    return Material(
      color: surface,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: _enabled ? () => _open(context) : null,
        child: Container(
          constraints: const BoxConstraints(minHeight: 44),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: hasValue ? AppColors.primary : border,
              width: hasValue ? 1.5 : 1.0,
            ),
          ),
          child: Row(
            children: [
              if (hasValue)
                Text(country.flag, style: const TextStyle(fontSize: 16))
              else
                Icon(Icons.public_rounded, size: 16, color: textTertiary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  loading
                      ? 'Loading countries…'
                      : (hasValue ? country.name : hint),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 13,
                    color: hasValue && !loading ? textPrimary : textTertiary,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              if (loading)
                const SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.primary,
                  ),
                )
              else if (locked)
                Icon(Icons.lock_outline_rounded, size: 15, color: textTertiary)
              else
                Icon(
                  Icons.keyboard_arrow_down_rounded,
                  size: 18,
                  color: textSecondary,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Shows every country in [countries] in a scrollable bottom sheet and returns
/// the one the user taps, or null if they dismiss the sheet.
Future<Country?> showCountryPickerSheet(
  BuildContext context, {
  required List<Country> countries,
  required Country? selected,
  required bool isDark,
}) {
  return showModalBottomSheet<Country>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (_) => _CountryPickerSheet(
      countries: countries,
      selected: selected,
      isDark: isDark,
    ),
  );
}

class _CountryPickerSheet extends StatefulWidget {
  final List<Country> countries;
  final Country? selected;
  final bool isDark;

  const _CountryPickerSheet({
    required this.countries,
    required this.selected,
    required this.isDark,
  });

  @override
  State<_CountryPickerSheet> createState() => _CountryPickerSheetState();
}

class _CountryPickerSheetState extends State<_CountryPickerSheet> {
  static const _rowHeight = 52.0;

  late final List<Country> _all;
  late List<Country> _visible;
  late final ScrollController _scroll;
  final _search = TextEditingController();

  @override
  void initState() {
    super.initState();
    _all = [...widget.countries]
      ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    _visible = _all;
    // Open with the current selection in view (a couple of rows below the top).
    final index = widget.selected == null
        ? -1
        : _all.indexWhere((c) => c.id == widget.selected!.id);
    _scroll = ScrollController(
      initialScrollOffset: index > 2 ? (index - 2) * _rowHeight : 0,
    );
  }

  @override
  void dispose() {
    _scroll.dispose();
    _search.dispose();
    super.dispose();
  }

  void _filter(String query) {
    final q = query.toLowerCase().trim();
    setState(() {
      _visible = q.isEmpty
          ? _all
          : _all
              .where((c) =>
                  c.name.toLowerCase().contains(q) ||
                  c.countryCode.toLowerCase() == q)
              .toList();
    });
    if (_scroll.hasClients) _scroll.jumpTo(0);
  }

  @override
  Widget build(BuildContext context) {
    final l = l10n(context);
    final isDark = widget.isDark;
    final media = MediaQuery.of(context);
    final border = isDark ? AppColors.darkBorder : AppColors.border;
    final surface = isDark ? AppColors.darkBackground : AppColors.surface;
    final textPrimary =
        isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;
    final textTertiary =
        isDark ? AppColors.darkTextTertiary : AppColors.textTertiary;

    return SizedBox(
      height: media.size.height * 0.85,
      child: Column(
        children: [
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: border,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 8, 8),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    l.countryPickerTitle,
                    style: TextStyle(
                      fontFamily: 'Manrope',
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: textPrimary,
                      letterSpacing: -0.3,
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.close_rounded, color: textTertiary),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
            child: TextField(
              controller: _search,
              onChanged: _filter,
              textInputAction: TextInputAction.search,
              style: TextStyle(
                fontFamily: 'Manrope',
                fontSize: 13,
                color: textPrimary,
              ),
              decoration: InputDecoration(
                isDense: true,
                hintText: l.countryPickerSearch,
                hintStyle: TextStyle(
                  fontFamily: 'Manrope',
                  fontSize: 13,
                  color: textTertiary,
                ),
                prefixIcon:
                    Icon(Icons.search_rounded, size: 18, color: textTertiary),
                filled: true,
                fillColor: surface,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: border),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide:
                      const BorderSide(color: AppColors.primary, width: 1.5),
                ),
              ),
            ),
          ),
          Expanded(
            child: _visible.isEmpty
                ? Center(
                    child: Text(
                      l.countryPickerEmpty,
                      style: TextStyle(
                        fontFamily: 'Manrope',
                        fontSize: 13,
                        color: textTertiary,
                      ),
                    ),
                  )
                : ListView.builder(
                    controller: _scroll,
                    keyboardDismissBehavior:
                        ScrollViewKeyboardDismissBehavior.onDrag,
                    itemExtent: _rowHeight,
                    padding: EdgeInsets.only(bottom: media.padding.bottom + 8),
                    itemCount: _visible.length,
                    itemBuilder: (context, i) {
                      final country = _visible[i];
                      final isSel = widget.selected?.id == country.id;
                      return InkWell(
                        onTap: () => Navigator.of(context).pop(country),
                        child: Container(
                          color: isSel
                              ? AppColors.primary.withValues(alpha: 0.06)
                              : Colors.transparent,
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Row(
                            children: [
                              Text(
                                country.flag,
                                style: const TextStyle(fontSize: 20),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  country.name,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontFamily: 'Manrope',
                                    fontSize: 14,
                                    fontWeight: isSel
                                        ? FontWeight.w700
                                        : FontWeight.w600,
                                    color: textPrimary,
                                  ),
                                ),
                              ),
                              if (isSel)
                                const Icon(
                                  Icons.check_rounded,
                                  size: 18,
                                  color: AppColors.primary,
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
          SizedBox(height: media.viewInsets.bottom),
        ],
      ),
    );
  }
}
