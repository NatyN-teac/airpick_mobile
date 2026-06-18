import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../core/storage/token_storage.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/state_message.dart';
import '../../offers/widgets/airpick_bubble_shell.dart';
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

class _UserDetailScreenState extends State<UserDetailScreen>
    with SingleTickerProviderStateMixin {
  final _firstName = TextEditingController();
  final _middleName = TextEditingController();
  final _lastName = TextEditingController();
  final _city = TextEditingController();
  final _state = TextEditingController();
  final _country = TextEditingController();
  final _bio = TextEditingController();

  late final AnimationController _enterCtrl;
  bool _loading = true;
  bool _saving = false;
  bool _showForm = false;
  bool _hasChanges = false;
  bool _ignoreFormChanges = false;
  bool _showSuccess = false;
  String? _email;
  String? _error;
  DateTime? _dob;
  ProfileSnapshot? _snapshot;
  _FormBaseline? _baseline;

  List<TextEditingController> get _textControllers => [
    _firstName,
    _middleName,
    _lastName,
    _city,
    _state,
    _country,
    _bio,
  ];

  @override
  void initState() {
    super.initState();
    _enterCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    for (final controller in _textControllers) {
      controller.addListener(_onFormChanged);
    }
    _snapshot = context.read<CurrentUserCubit>().state;
    _seedFromSnapshot(_snapshot);
    _captureBaseline();
    _load();
  }

  @override
  void dispose() {
    for (final controller in _textControllers) {
      controller.removeListener(_onFormChanged);
    }
    _enterCtrl.dispose();
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
    _ignoreFormChanges = true;
    _email = snap.email;
    _firstName.text = snap.firstName ?? '';
    _middleName.text = snap.middleName ?? '';
    _lastName.text = snap.lastName ?? '';
    _city.text = snap.city ?? '';
    _state.text = snap.state ?? '';
    _country.text = snap.country ?? '';
    _bio.text = snap.bio ?? '';
    _dob = parseProfileDob(snap.dob);
    _ignoreFormChanges = false;
  }

  void _applyDetail(UserProfileDetail detail, {ProfileSnapshot? fallback}) {
    _ignoreFormChanges = true;
    _email = detail.email ?? _email;
    _firstName.text = detail.firstName ?? fallback?.firstName ?? '';
    _middleName.text = detail.middleName ?? fallback?.middleName ?? '';
    _lastName.text = detail.lastName ?? fallback?.lastName ?? '';
    _city.text = detail.city ?? fallback?.city ?? '';
    _state.text = detail.state ?? fallback?.state ?? '';
    _country.text = detail.country ?? fallback?.country ?? '';
    _bio.text = detail.bio ?? fallback?.bio ?? '';
    _dob = parseProfileDob(detail.dob) ?? parseProfileDob(fallback?.dob);
    _ignoreFormChanges = false;
  }

  _FormBaseline _currentFormValues() => _FormBaseline(
    firstName: _firstName.text.trim(),
    middleName: _middleName.text.trim(),
    lastName: _lastName.text.trim(),
    city: _city.text.trim(),
    state: _state.text.trim(),
    country: _country.text.trim(),
    bio: _bio.text.trim(),
    dob: _dob,
  );

  void _captureBaseline() {
    _baseline = _currentFormValues();
    _hasChanges = false;
  }

  void _onFormChanged() {
    if (_ignoreFormChanges || _baseline == null) return;
    final changed = _currentFormValues() != _baseline;
    if (changed == _hasChanges) return;
    setState(() => _hasChanges = changed);
  }

  Future<void> _load() async {
    // Show the form immediately from the local snapshot — don't block on GET.
    final hasLocal = _snapshot != null || _email != null;
    setState(() {
      _loading = !hasLocal;
      _error = null;
      _showForm = hasLocal;
    });
    if (hasLocal) _enterCtrl.forward(from: 0);

    try {
      final tokenStorage = context.read<TokenStorage>();
      final userRepository = context.read<UserRepository>();
      final userId = await tokenStorage.getUserId();
      if (userId == null || userId.isEmpty) {
        throw Exception('User ID not found.');
      }
      final detail = await userRepository.getUserProfile(userId);
      if (!mounted) return;
      final current = context.read<CurrentUserCubit>().state;
      final base =
          current ?? ProfileSnapshot(email: detail.email ?? _email ?? '');
      final updated = ProfileSnapshot.fromDetail(detail, current: base);
      context.read<CurrentUserCubit>().updateProfile(updated);
      _snapshot = updated;
      setState(() {
        _applyDetail(detail, fallback: _snapshot);
        _loading = false;
        _error = null;
        _showForm = true;
      });
      _captureBaseline();
      if (!hasLocal) _enterCtrl.forward(from: 0);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _showForm = _snapshot != null || _email != null;
        // Soft warning — user can still edit and save.
        _error = hasLocal
            ? 'Could not refresh from server. Showing saved info — you can still edit and save.'
            : e.toString().replaceFirst('Exception: ', '');
      });
      if (_showForm && !hasLocal) _enterCtrl.forward(from: 0);
    }
  }

  Future<void> _pickDob() async {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _dob ?? DateTime(now.year - 25, now.month, now.day),
      firstDate: DateTime(1900),
      lastDate: now,
      helpText: 'Date of birth',
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: ColorScheme.fromSeed(
            seedColor: AppColors.primary,
            brightness: isDark ? Brightness.dark : Brightness.light,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() => _dob = picked);
      _onFormChanged();
    }
  }

  Future<void> _save() async {
    if (!_hasChanges || _saving) return;

    final validationError = _validateRequiredFields();
    if (validationError != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(validationError),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
      return;
    }

    setState(() => _saving = true);
    try {
      final request = UpdateUserProfileRequest(
        firstName: _firstName.text.trim(),
        middleName: _middleName.text.trim(),
        lastName: _lastName.text.trim(),
        city: _city.text.trim(),
        state: _state.text.trim(),
        country: _country.text.trim(),
        bio: _bio.text.trim(),
        profilePictureUrl: _snapshot?.profilePictureUrl,
        dob: formatProfileDob(_dob!),
      );
      final detail = await context.read<UserRepository>().updateUserProfile(
        request,
      );
      if (!mounted) return;
      context.read<CurrentUserCubit>().applySavedDetails(
        request: request,
        detail: detail,
        emailFallback: _email,
      );
      _snapshot = context.read<CurrentUserCubit>().state;
      if (_snapshot != null) {
        _seedFromSnapshot(_snapshot);
      } else {
        _applyDetail(detail);
      }
      setState(() {
        _captureBaseline();
        _saving = false;
        _showSuccess = true;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceFirst('Exception: ', '')),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted && !_showSuccess) setState(() => _saving = false);
    }
  }

  String? _validateRequiredFields() {
    if (_firstName.text.trim().isEmpty) {
      return 'First name is required.';
    }
    if (_lastName.text.trim().isEmpty) {
      return 'Last name is required.';
    }
    if (_city.text.trim().isEmpty) {
      return 'City is required.';
    }
    if (_country.text.trim().isEmpty) {
      return 'Country is required.';
    }
    if (_dob == null) {
      return 'Date of birth is required.';
    }
    return null;
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
          ? AppErrorState(
              title: 'Could not load profile',
              message: _error!,
              onRetry: _load,
            )
          : AnimatedSwitcher(
              duration: const Duration(milliseconds: 400),
              switchInCurve: Curves.easeOutCubic,
              switchOutCurve: Curves.easeInCubic,
              transitionBuilder: (child, anim) => FadeTransition(
                opacity: anim,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, 0.06),
                    end: Offset.zero,
                  ).animate(anim),
                  child: child,
                ),
              ),
              child: _showSuccess
                  ? BubbleSuccessScreen(
                      key: const ValueKey('success'),
                      isDark: isDark,
                      onDismiss: () => Navigator.pop(context),
                      title: 'Profile Updated!',
                      subtitle: 'Your details have been saved.',
                    )
                  : Column(
                      key: const ValueKey('form'),
                      children: [
                        Expanded(
                          child: AnimatedOpacity(
                            opacity: _showForm ? 1 : 0,
                            duration: const Duration(milliseconds: 350),
                            curve: Curves.easeOut,
                            child: ListView(
                              padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                              children: [
                                if (_error != null) ...[
                                  const SizedBox(height: 12),
                                  _AnimatedBlock(
                                    animation: _enterCtrl,
                                    interval: const Interval(0.1, 0.3),
                                    child: Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: AppColors.warning.withValues(
                                          alpha: 0.1,
                                        ),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: AppColors.warning.withValues(
                                            alpha: 0.25,
                                          ),
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          const Icon(
                                            Icons.info_outline_rounded,
                                            size: 18,
                                            color: AppColors.warning,
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Text(
                                              _error!,
                                              style: const TextStyle(
                                                fontFamily: 'Manrope',
                                                fontSize: 12,
                                                color: AppColors.warning,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                                const SizedBox(height: 24),
                                _AnimatedBlock(
                                  animation: _enterCtrl,
                                  interval: const Interval(0.15, 0.45),
                                  child: _SectionHeader(
                                    title: 'Personal',
                                    icon: Icons.person_outline_rounded,
                                    isDark: isDark,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                _field(
                                  0.2,
                                  isDark,
                                  'First name *',
                                  _firstName,
                                  hint: 'First name',
                                ),
                                _field(
                                  0.25,
                                  isDark,
                                  'Middle name',
                                  _middleName,
                                  hint: 'Optional',
                                ),
                                _field(
                                  0.3,
                                  isDark,
                                  'Last name *',
                                  _lastName,
                                  hint: 'Last name',
                                ),
                                _AnimatedBlock(
                                  animation: _enterCtrl,
                                  interval: const Interval(0.32, 0.52),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const SizedBox(height: 16),
                                      FormLabel(
                                        'Date of birth *',
                                        isDark: isDark,
                                      ),
                                      const SizedBox(height: 6),
                                      DateTimeTile(
                                        isDark: isDark,
                                        label: 'Date of birth',
                                        value: _dob,
                                        onTap: _pickDob,
                                      ),
                                      if (_dob != null) ...[
                                        const SizedBox(height: 6),
                                        Text(
                                          DateFormat(
                                            'EEEE, MMMM d, yyyy',
                                          ).format(_dob!),
                                          style: TextStyle(
                                            fontFamily: 'Manrope',
                                            fontSize: 11,
                                            color: isDark
                                                ? AppColors.darkTextTertiary
                                                : AppColors.textTertiary,
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 28),
                                _AnimatedBlock(
                                  animation: _enterCtrl,
                                  interval: const Interval(0.38, 0.62),
                                  child: _SectionHeader(
                                    title: 'Location',
                                    icon: Icons.location_on_outlined,
                                    isDark: isDark,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                _field(
                                  0.42,
                                  isDark,
                                  'City *',
                                  _city,
                                  hint: 'City',
                                ),
                                _field(
                                  0.47,
                                  isDark,
                                  'State / Region',
                                  _state,
                                  hint: 'Optional',
                                ),
                                _field(
                                  0.52,
                                  isDark,
                                  'Country *',
                                  _country,
                                  hint: 'Country',
                                ),
                                const SizedBox(height: 28),
                                _AnimatedBlock(
                                  animation: _enterCtrl,
                                  interval: const Interval(0.55, 0.78),
                                  child: _SectionHeader(
                                    title: 'About',
                                    icon: Icons.notes_rounded,
                                    isDark: isDark,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                _AnimatedBlock(
                                  animation: _enterCtrl,
                                  interval: const Interval(0.6, 0.85),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      FormLabel('Bio', isDark: isDark),
                                      const SizedBox(height: 6),
                                      FormTextField(
                                        isDark: isDark,
                                        hint:
                                            'Tell others a little about yourself',
                                        controller: _bio,
                                        maxLines: 4,
                                        onChanged: (_) {},
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        _SaveBar(
                          saving: _saving,
                          hasChanges: _hasChanges,
                          onSave: _save,
                          isDark: isDark,
                        ),
                      ],
                    ),
            ),
    );
  }

  Widget _field(
    double start,
    bool isDark,
    String label,
    TextEditingController controller, {
    required String hint,
  }) {
    return _AnimatedBlock(
      animation: _enterCtrl,
      interval: Interval(start, start + 0.2, curve: Curves.easeOutCubic),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FormLabel(label, isDark: isDark),
            const SizedBox(height: 6),
            FormTextField(
              isDark: isDark,
              hint: hint,
              controller: controller,
              onChanged: (_) {},
            ),
          ],
        ),
      ),
    );
  }
}

// ── Animated entrance ─────────────────────────────────────────────────────────

class _AnimatedBlock extends StatelessWidget {
  final Animation<double> animation;
  final Interval interval;
  final Widget child;

  const _AnimatedBlock({
    required this.animation,
    required this.interval,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, _) {
        final t = interval.transform(animation.value);
        return Opacity(
          opacity: t,
          child: Transform.translate(
            offset: Offset(0, (1 - t) * 14),
            child: child,
          ),
        );
      },
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final IconData icon;
  final bool isDark;

  const _SectionHeader({
    required this.title,
    required this.icon,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final textPrimary = isDark
        ? AppColors.darkTextPrimary
        : AppColors.textPrimary;

    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(9),
          ),
          child: Icon(icon, size: 17, color: AppColors.primary),
        ),
        const SizedBox(width: 10),
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
      ],
    );
  }
}

class _SaveBar extends StatelessWidget {
  final bool saving;
  final bool hasChanges;
  final VoidCallback onSave;
  final bool isDark;

  const _SaveBar({
    required this.saving,
    required this.hasChanges,
    required this.onSave,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final bg = isDark ? AppColors.darkBackground : AppColors.background;
    final border = isDark ? AppColors.darkBorder : AppColors.border;
    final enabled = hasChanges && !saving;

    return Container(
      padding: EdgeInsets.fromLTRB(
        20,
        12,
        20,
        12 + MediaQuery.of(context).padding.bottom,
      ),
      decoration: BoxDecoration(
        color: bg,
        border: Border(top: BorderSide(color: border.withValues(alpha: 0.7))),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.06),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SizedBox(
        width: double.infinity,
        height: 50,
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: enabled ? AppColors.primaryGradient : null,
            color: saving
                ? AppColors.primary.withValues(alpha: 0.5)
                : enabled
                ? null
                : (isDark
                      ? AppColors.darkSurface
                      : AppColors.border.withValues(alpha: 0.45)),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: enabled ? onSave : null,
              borderRadius: BorderRadius.circular(14),
              child: Center(
                child: saving
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(
                        'Save changes',
                        style: TextStyle(
                          fontFamily: 'Manrope',
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: enabled
                              ? Colors.white
                              : (isDark
                                    ? AppColors.darkTextTertiary
                                    : AppColors.textTertiary),
                          letterSpacing: -0.2,
                        ),
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _FormBaseline {
  final String firstName;
  final String middleName;
  final String lastName;
  final String city;
  final String state;
  final String country;
  final String bio;
  final DateTime? dob;

  const _FormBaseline({
    required this.firstName,
    required this.middleName,
    required this.lastName,
    required this.city,
    required this.state,
    required this.country,
    required this.bio,
    required this.dob,
  });

  @override
  bool operator ==(Object other) {
    return other is _FormBaseline &&
        firstName == other.firstName &&
        middleName == other.middleName &&
        lastName == other.lastName &&
        city == other.city &&
        state == other.state &&
        country == other.country &&
        bio == other.bio &&
        dob == other.dob;
  }

  @override
  int get hashCode => Object.hash(
    firstName,
    middleName,
    lastName,
    city,
    state,
    country,
    bio,
    dob,
  );
}
