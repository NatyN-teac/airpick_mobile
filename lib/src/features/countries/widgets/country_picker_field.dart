import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../models/country.dart';

// Searchable country field: type to filter, tap a suggestion to select.
// Constrains input to the supported country list — free text is not accepted.

class CountryPickerField extends StatefulWidget {
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

  @override
  State<CountryPickerField> createState() => _CountryPickerFieldState();
}

class _CountryPickerFieldState extends State<CountryPickerField> {
  final _controller = TextEditingController();
  final _focus = FocusNode();
  final _fieldKey = GlobalKey();
  List<Country> _filtered = [];
  bool _open = false;

  @override
  void initState() {
    super.initState();
    if (widget.selected != null) {
      _controller.text = widget.selected!.name;
    }
    _focus.addListener(() {
      if (_focus.hasFocus) {
        // Show all on focus when empty so it acts as a dropdown too
        setState(() {
          _open = true;
          if (_controller.text.isEmpty) {
            _filtered = widget.countries.take(8).toList();
          }
        });
        WidgetsBinding.instance.addPostFrameCallback((_) {
          final ctx = _fieldKey.currentContext;
          if (ctx != null) {
            Scrollable.ensureVisible(
              ctx,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
              alignment: 0.1,
            );
          }
        });
      } else {
        setState(() => _open = false);
      }
    });
  }

  @override
  void didUpdateWidget(CountryPickerField old) {
    super.didUpdateWidget(old);
    // Keep field text in sync if selection changes externally
    if (widget.selected != null &&
        widget.selected != old.selected &&
        _controller.text != widget.selected!.name) {
      _controller.text = widget.selected!.name;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _focus.dispose();
    super.dispose();
  }

  void _onChanged(String query) {
    final q = query.toLowerCase().trim();
    setState(() {
      _open = true;
      if (q.isEmpty) {
        _filtered = widget.countries.take(8).toList();
      } else {
        _filtered = widget.countries
            .where((c) =>
                c.name.toLowerCase().contains(q) ||
                c.countryCode.toLowerCase().contains(q))
            .take(8)
            .toList();
      }
    });
  }

  void _select(Country country) {
    widget.onSelected(country);
    _controller.text = country.name;
    _focus.unfocus();
    setState(() => _open = false);
  }

  @override
  Widget build(BuildContext context) {
    final surface =
        widget.isDark ? AppColors.darkBackground : AppColors.surface;
    final dropdownBg =
        widget.isDark ? AppColors.darkSurface : Colors.white;
    final border = widget.isDark ? AppColors.darkBorder : AppColors.border;
    final textPrimary =
        widget.isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;
    final textSecondary =
        widget.isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;
    final textTertiary =
        widget.isDark ? AppColors.darkTextTertiary : AppColors.textTertiary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          key: _fieldKey,
          controller: _controller,
          focusNode: _focus,
          onChanged: _onChanged,
          enabled: !widget.loading && !widget.locked,
          style: TextStyle(
              fontFamily: 'Manrope', fontSize: 13, color: textPrimary),
          decoration: InputDecoration(
            hintText: widget.loading ? 'Loading countries…' : widget.hint,
            hintStyle: TextStyle(
                fontFamily: 'Manrope', fontSize: 13, color: textTertiary),
            prefixIcon: widget.selected != null
                ? Padding(
                    padding: const EdgeInsets.only(left: 12, right: 6),
                    child: Text(
                      widget.selected!.flag,
                      style: const TextStyle(fontSize: 16),
                    ),
                  )
                : Icon(Icons.public_rounded, size: 16, color: textTertiary),
            prefixIconConstraints:
                const BoxConstraints(minWidth: 34, minHeight: 0),
            suffixIcon: widget.loading
                ? const Padding(
                    padding: EdgeInsets.all(12),
                    child: SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: AppColors.primary),
                    ),
                  )
                : widget.locked
                    ? Icon(Icons.lock_outline_rounded,
                        size: 15, color: textTertiary)
                    : Icon(Icons.keyboard_arrow_down_rounded,
                        size: 18, color: textSecondary),
            filled: true,
            fillColor: surface,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: border)),
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(
                    color:
                        widget.selected != null ? AppColors.primary : border,
                    width: widget.selected != null ? 1.5 : 1.0)),
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(
                    color: AppColors.primary, width: 1.5)),
          ),
        ),
        if (_open && _filtered.isNotEmpty)
          Container(
            margin: const EdgeInsets.only(top: 4),
            constraints: const BoxConstraints(maxHeight: 220),
            decoration: BoxDecoration(
              color: dropdownBg,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: border),
              boxShadow: [
                BoxShadow(
                  color: Colors.black
                      .withValues(alpha: widget.isDark ? 0.3 : 0.08),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ListView(
              padding: EdgeInsets.zero,
              shrinkWrap: true,
              children: _filtered.map((country) {
                final isSel = widget.selected?.id == country.id;
                return GestureDetector(
                  onTap: () => _select(country),
                  child: Container(
                    color: isSel
                        ? AppColors.primary.withValues(alpha: 0.06)
                        : Colors.transparent,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 11),
                    child: Row(
                      children: [
                        Text(country.flag,
                            style: const TextStyle(fontSize: 16)),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            country.name,
                            style: TextStyle(
                              fontFamily: 'Manrope',
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: textPrimary,
                            ),
                          ),
                        ),
                        Text(
                          country.countryCode,
                          style: TextStyle(
                            fontFamily: 'Manrope',
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
                            color: textTertiary,
                          ),
                        ),
                        if (isSel) ...[
                          const SizedBox(width: 8),
                          const Icon(Icons.check_rounded,
                              size: 15, color: AppColors.primary),
                        ],
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
      ],
    );
  }
}
