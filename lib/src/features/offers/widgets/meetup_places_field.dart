import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../models/offer_models.dart';

/// Chips + picker for adding meetup places (used in offer & proposal forms).
class MeetupPlacesField extends StatelessWidget {
  final bool isDark;
  final List<String> places;
  final ValueChanged<String> onAdd;
  final ValueChanged<int> onRemove;

  const MeetupPlacesField({
    super.key,
    required this.isDark,
    required this.places,
    required this.onAdd,
    required this.onRemove,
  });

  Future<void> _pickPlace(BuildContext context) async {
    final choice = await showDialog<MeetupPlace>(
      context: context,
      builder: (_) => _MeetupPickerDialog(isDark: isDark),
    );
    if (choice == null || !context.mounted) return;

    if (choice == MeetupPlace.other) {
      final custom = await showDialog<String>(
        context: context,
        builder: (_) => _CustomMeetupDialog(isDark: isDark),
      );
      if (custom != null && custom.trim().isNotEmpty) {
        onAdd(custom.trim());
      }
    } else {
      onAdd(choice.label);
    }
  }

  @override
  Widget build(BuildContext context) {
    final border = isDark ? AppColors.darkBorder : AppColors.border;
    final surface = isDark ? AppColors.darkBackground : AppColors.surface;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (places.isNotEmpty)
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: places.asMap().entries.map((e) {
              return Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                      color: AppColors.primary.withValues(alpha: 0.3)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      e.value,
                      style: const TextStyle(
                        fontFamily: 'Manrope',
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: 6),
                    GestureDetector(
                      onTap: () => onRemove(e.key),
                      child: const Icon(Icons.close_rounded,
                          size: 12, color: AppColors.primary),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        if (places.isNotEmpty) const SizedBox(height: 8),
        GestureDetector(
          onTap: () => _pickPlace(context),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: surface,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: places.isEmpty
                    ? border
                    : AppColors.primary.withValues(alpha: 0.35),
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.add_location_alt_outlined,
                    size: 15, color: AppColors.primary),
                const SizedBox(width: 8),
                Text(
                  places.isEmpty
                      ? 'Add meetup place (required)'
                      : 'Add another meetup place',
                  style: TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 13,
                    color: isDark
                        ? AppColors.darkTextTertiary
                        : AppColors.textTertiary,
                  ),
                ),
                const Spacer(),
                Icon(Icons.keyboard_arrow_down_rounded,
                    size: 16,
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.textSecondary),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _MeetupPickerDialog extends StatelessWidget {
  final bool isDark;
  const _MeetupPickerDialog({required this.isDark});

  @override
  Widget build(BuildContext context) {
    final bg = isDark ? AppColors.darkSurface : Colors.white;
    final border = isDark ? AppColors.darkBorder : AppColors.border;
    final textPrimary =
        isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;

    return Dialog(
      backgroundColor: bg,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 0, 18, 12),
              child: Text(
                'Select meetup place',
                style: TextStyle(
                  fontFamily: 'Manrope',
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: textPrimary,
                ),
              ),
            ),
            ...MeetupPlace.values.map((p) => InkWell(
                  onTap: () => Navigator.of(context).pop(p),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 18, vertical: 12),
                    decoration: BoxDecoration(
                      border:
                          Border(top: BorderSide(color: border, width: 0.5)),
                    ),
                    child: Text(
                      p.label,
                      style: TextStyle(
                        fontFamily: 'Manrope',
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: p == MeetupPlace.other
                            ? AppColors.primary
                            : textPrimary,
                      ),
                    ),
                  ),
                )),
          ],
        ),
      ),
    );
  }
}

class _CustomMeetupDialog extends StatefulWidget {
  final bool isDark;
  const _CustomMeetupDialog({required this.isDark});

  @override
  State<_CustomMeetupDialog> createState() => _CustomMeetupDialogState();
}

class _CustomMeetupDialogState extends State<_CustomMeetupDialog> {
  final _ctrl = TextEditingController();

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bg = widget.isDark ? AppColors.darkSurface : Colors.white;
    final textPrimary =
        widget.isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;
    final surface =
        widget.isDark ? AppColors.darkBackground : AppColors.surface;
    final border = widget.isDark ? AppColors.darkBorder : AppColors.border;

    return Dialog(
      backgroundColor: bg,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Custom meetup place',
              style: TextStyle(
                fontFamily: 'Manrope',
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _ctrl,
              autofocus: true,
              style: TextStyle(
                  fontFamily: 'Manrope', fontSize: 13, color: textPrimary),
              decoration: InputDecoration(
                hintText: 'e.g. Starbucks on 5th Ave',
                hintStyle: TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 13,
                    color: widget.isDark
                        ? AppColors.darkTextTertiary
                        : AppColors.textTertiary),
                filled: true,
                fillColor: surface,
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 10),
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
            ),
            const SizedBox(height: 14),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    child: Text('Cancel',
                        style: TextStyle(
                          fontFamily: 'Manrope',
                          fontSize: 13,
                          color: AppColors.textDisabled,
                        )),
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(_ctrl.text),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Text('Add',
                        style: TextStyle(
                          fontFamily: 'Manrope',
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        )),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
