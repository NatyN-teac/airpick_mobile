import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_colors.dart';
import '../../settings/repository/settings_repository.dart';
import '../cubit/current_user_cubit.dart';
import '../models/user_profile_detail.dart';
import '../repository/user_repository.dart';

/// Mandatory, one-time prompt asking a user to complete their basic profile
/// (first name, last name, date of birth, country of residence). Cannot be
/// dismissed until saved successfully; city and the rest stay editable later.
Future<void> showCompleteProfileDialog(BuildContext context) {
  return showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (_) => const _CompleteProfileDialog(),
  );
}

class _CompleteProfileDialog extends StatefulWidget {
  const _CompleteProfileDialog();

  @override
  State<_CompleteProfileDialog> createState() => _CompleteProfileDialogState();
}

class _CompleteProfileDialogState extends State<_CompleteProfileDialog> {
  final _firstName = TextEditingController();
  final _lastName = TextEditingController();
  final _country = TextEditingController();
  DateTime? _dob;
  bool _busy = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    // Pre-fill anything we already have so the user only completes the gaps.
    final p = context.read<CurrentUserCubit>().state;
    _firstName.text = p?.firstName ?? '';
    _lastName.text = p?.lastName ?? '';
    _country.text = p?.country ?? '';
    _dob = parseProfileDob(p?.dob);
  }

  @override
  void dispose() {
    _firstName.dispose();
    _lastName.dispose();
    _country.dispose();
    super.dispose();
  }

  bool get _isValid =>
      _firstName.text.trim().isNotEmpty &&
      _lastName.text.trim().isNotEmpty &&
      _country.text.trim().isNotEmpty &&
      _dob != null;

  Future<void> _pickDob() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _dob ?? DateTime(now.year - 25, now.month, now.day),
      firstDate: DateTime(now.year - 100),
      lastDate: now,
    );
    if (picked != null) setState(() => _dob = picked);
  }

  Future<void> _submit() async {
    if (!_isValid || _busy) return;
    setState(() {
      _busy = true;
      _error = null;
    });

    // Preserve every other profile field we already hold so the partial update
    // doesn't wipe them (city is intentionally left for the user to add later).
    final current = context.read<CurrentUserCubit>().state;
    final request = UpdateUserProfileRequest(
      firstName: _firstName.text.trim(),
      lastName: _lastName.text.trim(),
      middleName: current?.middleName,
      city: current?.city ?? '',
      state: current?.state,
      country: _country.text.trim(),
      bio: current?.bio,
      profilePictureUrl: current?.profilePictureUrl,
      dob: formatProfileDob(_dob!),
    );

    try {
      final detail =
          await context.read<UserRepository>().updateUserProfile(request);
      if (!mounted) return;
      context.read<CurrentUserCubit>().applySavedDetails(
            request: request,
            detail: detail,
            emailFallback: current?.email,
          );
      await context.read<SettingsRepository>().setBasicsPrompted();
      if (!mounted) return;
      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _busy = false;
        _error = e.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surface = isDark ? AppColors.darkSurface : Colors.white;
    final textPrimary =
        isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;
    final textSecondary =
        isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;

    // Mandatory: block the system back button too.
    return PopScope(
      canPop: false,
      child: Dialog(
        backgroundColor: surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        insetPadding: const EdgeInsets.symmetric(horizontal: 24),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(22, 22, 22, 18),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Complete your profile',
                style: TextStyle(
                  fontFamily: 'Manrope',
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: textPrimary,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'We need a few basics before you continue. You can add the rest '
                'from your profile later.',
                style: TextStyle(
                  fontFamily: 'Manrope',
                  fontSize: 13,
                  height: 1.4,
                  color: textSecondary,
                ),
              ),
              const SizedBox(height: 18),
              _field('First name', _firstName, isDark),
              const SizedBox(height: 12),
              _field('Last name', _lastName, isDark),
              const SizedBox(height: 12),
              _dobField(isDark, textPrimary, textSecondary),
              const SizedBox(height: 12),
              _field('Country of residence', _country, isDark),
              if (_error != null) ...[
                const SizedBox(height: 12),
                Text(
                  _error!,
                  style: const TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 12.5,
                    color: AppColors.error,
                  ),
                ),
              ],
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: FilledButton(
                  onPressed: _isValid && !_busy ? _submit : null,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                  child: _busy
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white),
                        )
                      : const Text(
                          'Save and continue',
                          style: TextStyle(
                            fontFamily: 'Manrope',
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _field(String label, TextEditingController c, bool isDark) {
    final textPrimary =
        isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;
    final fill = isDark ? AppColors.darkInputBackground : AppColors.inputBackground;
    final border = isDark ? AppColors.darkBorder : AppColors.border;
    return TextField(
      controller: c,
      enabled: !_busy,
      onChanged: (_) => setState(() {}),
      textCapitalization: TextCapitalization.words,
      style: TextStyle(
        fontFamily: 'Manrope',
        fontSize: 14,
        color: textPrimary,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(fontFamily: 'Manrope', fontSize: 13),
        filled: true,
        fillColor: fill,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: border),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary),
        ),
      ),
    );
  }

  Widget _dobField(bool isDark, Color textPrimary, Color textSecondary) {
    final fill = isDark ? AppColors.darkInputBackground : AppColors.inputBackground;
    final border = isDark ? AppColors.darkBorder : AppColors.border;
    return InkWell(
      onTap: _busy ? null : _pickDob,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 15),
        decoration: BoxDecoration(
          color: fill,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: border),
        ),
        child: Row(
          children: [
            Icon(Icons.calendar_today_rounded, size: 16, color: textSecondary),
            const SizedBox(width: 10),
            Text(
              _dob != null
                  ? DateFormat('MMM d, yyyy').format(_dob!)
                  : 'Date of birth',
              style: TextStyle(
                fontFamily: 'Manrope',
                fontSize: 14,
                color: _dob != null ? textPrimary : textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
