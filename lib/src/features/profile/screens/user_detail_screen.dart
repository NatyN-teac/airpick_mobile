import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/storage/token_storage.dart';
import '../../../core/theme/app_colors.dart';
import '../../offers/widgets/form_widgets.dart';
import '../cubit/current_user_cubit.dart';
import '../models/profile_snapshot.dart';
import '../models/user_profile_detail.dart';
import '../repository/user_repository.dart';
import '../widgets/profile_sub_screen_app_bar.dart';

class UserDetailScreen extends StatefulWidget {
  const UserDetailScreen({super.key});

  @override
  State<UserDetailScreen> createState() => _UserDetailScreenState();
}

class _UserDetailScreenState extends State<UserDetailScreen> {
  final _firstName = TextEditingController();
  final _middleName = TextEditingController();
  final _lastName = TextEditingController();
  final _city = TextEditingController();
  final _state = TextEditingController();
  final _country = TextEditingController();
  final _bio = TextEditingController();

  bool _loading = true;
  bool _saving = false;
  String? _email;
  String? _error;

  @override
  void initState() {
    super.initState();
    _seedFromSnapshot(context.read<CurrentUserCubit>().state);
    _load();
  }

  @override
  void dispose() {
    _firstName.dispose();
    _middleName.dispose();
    _lastName.dispose();
    _city.dispose();
    _state.dispose();
    _country.dispose();
    _bio.dispose();
    super.dispose();
  }

  void _seedFromSnapshot(ProfileSnapshot? snap) {
    if (snap == null) return;
    _email = snap.email;
    _firstName.text = snap.firstName ?? '';
    _middleName.text = snap.middleName ?? '';
    _lastName.text = snap.lastName ?? '';
    _city.text = snap.city ?? '';
    _state.text = snap.state ?? '';
    _country.text = snap.country ?? '';
    _bio.text = snap.bio ?? '';
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final userId = await context.read<TokenStorage>().getUserId();
      if (userId == null || userId.isEmpty) {
        throw Exception('User ID not found.');
      }
      final detail =
          await context.read<UserRepository>().getUserProfile(userId);
      if (!mounted) return;
      final current = context.read<CurrentUserCubit>().state;
      if (current != null) {
        context
            .read<CurrentUserCubit>()
            .updateProfile(ProfileSnapshot.fromDetail(detail, current: current));
      }
      setState(() {
        _email = detail.email ?? _email;
        _firstName.text = detail.firstName ?? _firstName.text;
        _middleName.text = detail.middleName ?? _middleName.text;
        _lastName.text = detail.lastName ?? _lastName.text;
        _city.text = detail.city ?? _city.text;
        _state.text = detail.state ?? _state.text;
        _country.text = detail.country ?? _country.text;
        _bio.text = detail.bio ?? _bio.text;
        _loading = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          _loading = false;
          _error = e.toString().replaceFirst('Exception: ', '');
        });
      }
    }
  }

  Future<void> _save() async {
    final first = _firstName.text.trim();
    final last = _lastName.text.trim();
    if (first.isEmpty || last.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('First name and last name are required.')),
      );
      return;
    }

    setState(() => _saving = true);
    try {
      final userId = await context.read<TokenStorage>().getUserId();
      if (userId == null || userId.isEmpty) {
        throw Exception('User ID not found.');
      }
      final request = UpdateUserProfileRequest(
        firstName: first,
        middleName: _middleName.text.trim(),
        lastName: last,
        city: _city.text.trim(),
        state: _state.text.trim(),
        country: _country.text.trim(),
        bio: _bio.text.trim(),
      );
      final detail = await context
          .read<UserRepository>()
          .updateUserProfile(userId, request);
      if (!mounted) return;
      final current = context.read<CurrentUserCubit>().state;
      if (current != null) {
        context
            .read<CurrentUserCubit>()
            .updateProfile(ProfileSnapshot.fromDetail(detail, current: current));
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Profile updated'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.success,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceFirst('Exception: ', '')),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.darkBackground : AppColors.background;

    return Scaffold(
      backgroundColor: bg,
      appBar: const ProfileSubScreenAppBar(title: 'User details'),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            )
          : _error != null && _email == null
              ? _ErrorBody(message: _error!, onRetry: _load)
              : SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (_error != null) ...[
                        Text(
                          _error!,
                          style: const TextStyle(
                            fontFamily: 'Manrope',
                            fontSize: 12,
                            color: AppColors.warning,
                          ),
                        ),
                        const SizedBox(height: 12),
                      ],
                      FormLabel('Email', isDark: isDark),
                      const SizedBox(height: 6),
                      _ReadOnlyField(value: _email ?? '—', isDark: isDark),
                      const SizedBox(height: 16),
                      FormLabel('First name', isDark: isDark),
                      const SizedBox(height: 6),
                      FormTextField(
                        isDark: isDark,
                        hint: 'First name',
                        controller: _firstName,
                        onChanged: (_) {},
                      ),
                      const SizedBox(height: 16),
                      FormLabel('Middle name', isDark: isDark),
                      const SizedBox(height: 6),
                      FormTextField(
                        isDark: isDark,
                        hint: 'Optional',
                        controller: _middleName,
                        onChanged: (_) {},
                      ),
                      const SizedBox(height: 16),
                      FormLabel('Last name', isDark: isDark),
                      const SizedBox(height: 6),
                      FormTextField(
                        isDark: isDark,
                        hint: 'Last name',
                        controller: _lastName,
                        onChanged: (_) {},
                      ),
                      const SizedBox(height: 16),
                      FormLabel('City', isDark: isDark),
                      const SizedBox(height: 6),
                      FormTextField(
                        isDark: isDark,
                        hint: 'City',
                        controller: _city,
                        onChanged: (_) {},
                      ),
                      const SizedBox(height: 16),
                      FormLabel('State / Region', isDark: isDark),
                      const SizedBox(height: 6),
                      FormTextField(
                        isDark: isDark,
                        hint: 'State or region',
                        controller: _state,
                        onChanged: (_) {},
                      ),
                      const SizedBox(height: 16),
                      FormLabel('Country', isDark: isDark),
                      const SizedBox(height: 6),
                      FormTextField(
                        isDark: isDark,
                        hint: 'Country',
                        controller: _country,
                        onChanged: (_) {},
                      ),
                      const SizedBox(height: 16),
                      FormLabel('Bio', isDark: isDark),
                      const SizedBox(height: 6),
                      FormTextField(
                        isDark: isDark,
                        hint: 'Tell others a little about yourself',
                        controller: _bio,
                        maxLines: 3,
                        onChanged: (_) {},
                      ),
                      const SizedBox(height: 28),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          onPressed: _saving ? null : _save,
                          style: FilledButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            disabledBackgroundColor:
                                AppColors.primary.withValues(alpha: 0.5),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: _saving
                              ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Text(
                                  'Save changes',
                                  style: TextStyle(
                                    fontFamily: 'Manrope',
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }
}

class _ReadOnlyField extends StatelessWidget {
  final String value;
  final bool isDark;

  const _ReadOnlyField({required this.value, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final surface = isDark ? AppColors.darkBackground : AppColors.surface;
    final border = isDark ? AppColors.darkBorder : AppColors.border;
    final textSecondary =
        isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: surface.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: border),
      ),
      child: Text(
        value,
        style: TextStyle(
          fontFamily: 'Manrope',
          fontSize: 13,
          color: textSecondary,
        ),
      ),
    );
  }
}

class _ErrorBody extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorBody({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline_rounded,
                size: 48, color: AppColors.error),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: onRetry,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
              ),
              child: const Text('Retry',
                  style: TextStyle(fontFamily: 'Manrope')),
            ),
          ],
        ),
      ),
    );
  }
}
