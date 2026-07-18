import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Shows a consistent "which fields are missing" message when a user tries to
/// submit an incomplete form. Used by the create forms so the feedback is the
/// same everywhere instead of a generic error.
void showMissingFields(BuildContext context, List<String> missing) {
  if (missing.isEmpty) return;
  final label = missing.length == 1
      ? missing.first
      : missing.join(', ');
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(
          missing.length == 1
              ? 'Please add: $label'
              : 'Please complete: $label',
          style: const TextStyle(fontFamily: 'Manrope'),
        ),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
}
