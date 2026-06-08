import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../airports/models/airport.dart';

// ── Label ─────────────────────────────────────────────────────────────────────

class FormLabel extends StatelessWidget {
  final String text;
  final bool isDark;

  const FormLabel(this.text, {super.key, required this.isDark});

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

// ── Text field ────────────────────────────────────────────────────────────────

class FormTextField extends StatelessWidget {
  final bool isDark;
  final String hint;
  final ValueChanged<String> onChanged;
  final TextInputType? keyboardType;
  final int maxLines;
  final TextEditingController? controller;

  const FormTextField({
    super.key,
    required this.isDark,
    required this.hint,
    required this.onChanged,
    this.keyboardType,
    this.maxLines = 1,
    this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final surface =
        isDark ? AppColors.darkBackground : AppColors.surface;
    final border =
        isDark ? AppColors.darkBorder : AppColors.border;
    final textPrimary =
        isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;
    final placeholder =
        isDark ? AppColors.darkTextTertiary : AppColors.textTertiary;

    return TextField(
      controller: controller,
      onChanged: onChanged,
      keyboardType: keyboardType,
      maxLines: maxLines,
      style: TextStyle(
        fontFamily: 'Manrope',
        fontSize: 13,
        color: textPrimary,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(
          fontFamily: 'Manrope',
          fontSize: 13,
          color: placeholder,
        ),
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
    );
  }
}

// ── Airport picker ────────────────────────────────────────────────────────────

class AirportPicker extends StatefulWidget {
  final bool isDark;
  final List<Airport> airports;
  final Airport? selected;
  final String hint;
  final ValueChanged<Airport> onSelected;

  const AirportPicker({
    super.key,
    required this.isDark,
    required this.airports,
    required this.selected,
    required this.hint,
    required this.onSelected,
  });

  @override
  State<AirportPicker> createState() => _AirportPickerState();
}

class _AirportPickerState extends State<AirportPicker> {
  final _controller = TextEditingController();
  final _focus = FocusNode();
  final _fieldKey = GlobalKey();
  List<Airport> _filtered = [];
  bool _open = false;

  @override
  void initState() {
    super.initState();
    if (widget.selected != null) {
      _controller.text = widget.selected!.displayLabel;
    }
    _focus.addListener(() {
      if (_focus.hasFocus) {
        // Scroll this field above the keyboard after it appears
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
  void dispose() {
    _controller.dispose();
    _focus.dispose();
    super.dispose();
  }

  void _onChanged(String query) {
    final q = query.toLowerCase();
    setState(() {
      _open = q.isNotEmpty;
      _filtered = widget.airports
          .where((a) =>
              a.iataCode.toLowerCase().contains(q) ||
              a.city.toLowerCase().contains(q) ||
              a.name.toLowerCase().contains(q))
          .take(6)
          .toList();
    });
  }

  void _select(Airport airport) {
    widget.onSelected(airport);
    _controller.text = airport.displayLabel;
    _focus.unfocus();
    setState(() => _open = false);
  }

  @override
  Widget build(BuildContext context) {
    final surface =
        widget.isDark ? AppColors.darkBackground : AppColors.surface;
    final dropdownBg =
        widget.isDark ? AppColors.darkSurface : Colors.white;
    final border =
        widget.isDark ? AppColors.darkBorder : AppColors.border;
    final textPrimary = widget.isDark
        ? AppColors.darkTextPrimary
        : AppColors.textPrimary;
    final textSecondary = widget.isDark
        ? AppColors.darkTextSecondary
        : AppColors.textSecondary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          key: _fieldKey,
          controller: _controller,
          focusNode: _focus,
          onChanged: _onChanged,
          style: TextStyle(
            fontFamily: 'Manrope',
            fontSize: 13,
            color: textPrimary,
          ),
          decoration: InputDecoration(
            hintText: widget.hint,
            hintStyle: TextStyle(
              fontFamily: 'Manrope',
              fontSize: 13,
              color: widget.isDark
                  ? AppColors.darkTextTertiary
                  : AppColors.textTertiary,
            ),
            prefixIcon: Icon(Icons.flight_rounded,
                size: 16,
                color: widget.isDark
                    ? AppColors.darkTextTertiary
                    : AppColors.textTertiary),
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
              borderSide: const BorderSide(
                  color: AppColors.primary, width: 1.5),
            ),
          ),
        ),
        if (_open && _filtered.isNotEmpty)
          Container(
            margin: const EdgeInsets.only(top: 4),
            decoration: BoxDecoration(
              color: dropdownBg,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: border),
            ),
            child: Column(
              children: _filtered.map((airport) {
                return GestureDetector(
                  onTap: () => _select(airport),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 10),
                    child: Row(
                      children: [
                        Text(
                          airport.iataCode,
                          style: const TextStyle(
                            fontFamily: 'Manrope',
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: AppColors.primary,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                airport.name,
                                style: TextStyle(
                                  fontFamily: 'Manrope',
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: textPrimary,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                '${airport.city}, ${airport.country}',
                                style: TextStyle(
                                  fontFamily: 'Manrope',
                                  fontSize: 10,
                                  color: textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
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

// ── Date / Time tile ──────────────────────────────────────────────────────────

class DateTimeTile extends StatelessWidget {
  final bool isDark, isTime;
  final String label;
  final DateTime? value;
  final TimeOfDay? timeValue;
  final VoidCallback onTap;

  const DateTimeTile({
    super.key,
    required this.isDark,
    required this.label,
    required this.onTap,
    this.value,
    this.timeValue,
    this.isTime = false,
  });

  String get _display {
    if (isTime) {
      if (timeValue == null) return '––:––';
      final h = timeValue!.hour.toString().padLeft(2, '0');
      final m = timeValue!.minute.toString().padLeft(2, '0');
      return '$h:$m';
    }
    if (value == null) return '––/––/––';
    return '${value!.day.toString().padLeft(2, '0')}/'
        '${value!.month.toString().padLeft(2, '0')}/'
        '${value!.year}';
  }

  @override
  Widget build(BuildContext context) {
    final surface =
        isDark ? AppColors.darkBackground : AppColors.surface;
    final border = isDark ? AppColors.darkBorder : AppColors.border;
    final textPrimary =
        isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;
    final textTertiary =
        isDark ? AppColors.darkTextTertiary : AppColors.textTertiary;
    final hasValue = isTime ? timeValue != null : value != null;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
          color: surface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: border),
        ),
        child: Row(
          children: [
            Icon(
              isTime ? Icons.access_time_rounded : Icons.calendar_today_outlined,
              size: 13,
              color: hasValue ? AppColors.primary : textTertiary,
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontFamily: 'Manrope',
                      fontSize: 9,
                      color: textTertiary,
                    ),
                  ),
                  Text(
                    _display,
                    style: TextStyle(
                      fontFamily: 'Manrope',
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: hasValue ? textPrimary : textTertiary,
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

// ── Dropdown — matches FormTextField sizing ────────────────────────────────────

class FormDropdown<T> extends StatelessWidget {
  final bool isDark;
  final T value;
  final List<T> options;
  final String Function(T) label;
  final ValueChanged<T> onChanged;

  const FormDropdown({
    super.key,
    required this.isDark,
    required this.value,
    required this.options,
    required this.label,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final surface = isDark ? AppColors.darkBackground : AppColors.surface;
    final border = isDark ? AppColors.darkBorder : AppColors.border;
    final textPrimary =
        isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;
    final textSecondary =
        isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;

    return DropdownButtonFormField<T>(
      value: value,
      style: TextStyle(
          fontFamily: 'Manrope', fontSize: 13, color: textPrimary),
      dropdownColor: isDark ? AppColors.darkSurface : Colors.white,
      icon: Icon(Icons.keyboard_arrow_down_rounded,
          size: 18, color: textSecondary),
      decoration: InputDecoration(
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
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
      ),
      items: options
          .map((o) => DropdownMenuItem<T>(
                value: o,
                child: Text(label(o),
                    style: TextStyle(
                        fontFamily: 'Manrope',
                        fontSize: 13,
                        color: textPrimary)),
              ))
          .toList(),
      onChanged: (v) {
        if (v != null) onChanged(v);
      },
    );
  }
}
