import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/utils/app_logger.dart';
import '../models/country.dart';
import '../repository/country_repository.dart';
import 'country_picker_field.dart';

/// [CountryPickerField] for forms that store a country as plain text
/// (e.g. the profile's country of residence). Loads the country list itself
/// and keeps [controller] holding the picked country's name, so existing
/// validation and save code that reads `controller.text` keeps working.
class CountryNameField extends StatefulWidget {
  final TextEditingController controller;
  final bool isDark;
  final String hint;
  final bool enabled;
  final ValueChanged<String>? onChanged;

  const CountryNameField({
    super.key,
    required this.controller,
    required this.isDark,
    required this.hint,
    this.enabled = true,
    this.onChanged,
  });

  @override
  State<CountryNameField> createState() => _CountryNameFieldState();
}

class _CountryNameFieldState extends State<CountryNameField> {
  List<Country> _countries = const [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onText);
    _load();
  }

  @override
  void didUpdateWidget(CountryNameField old) {
    super.didUpdateWidget(old);
    if (old.controller != widget.controller) {
      old.controller.removeListener(_onText);
      widget.controller.addListener(_onText);
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onText);
    super.dispose();
  }

  // The controller may be filled after the profile loads.
  void _onText() {
    if (mounted) setState(() {});
  }

  Future<void> _load() async {
    try {
      final list = await context.read<CountryRepository>().fetchCountries();
      if (mounted) setState(() => _countries = list);
    } catch (e, st) {
      appLogger.e('[CountryNameField] countries failed', e, st);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  /// The country matching the controller's text. Older profiles may hold a
  /// name that isn't in the list; show it as-is so it isn't silently lost.
  Country? get _selected {
    final name = widget.controller.text.trim();
    if (name.isEmpty) return null;
    final lower = name.toLowerCase();
    for (final c in _countries) {
      if (c.name.toLowerCase() == lower) return c;
    }
    return Country(id: 'text:$name', name: name, countryCode: '');
  }

  @override
  Widget build(BuildContext context) {
    return CountryPickerField(
      isDark: widget.isDark,
      countries: _countries,
      selected: _selected,
      hint: widget.hint,
      loading: _loading,
      locked: !widget.enabled,
      onSelected: (c) {
        widget.controller.text = c.name;
        widget.onChanged?.call(c.name);
      },
    );
  }
}
