import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:guzomy/l10n/app_localizations.dart';
import '../../../core/l10n/l10n.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/app_logger.dart';
import '../../countries/models/country.dart';
import '../../countries/models/iso3_country_codes.dart';
import '../../countries/repository/country_repository.dart';
import '../../countries/widgets/country_picker_field.dart';
import '../cubit/account_verification_cubit.dart';
import '../models/account_verification.dart';
import '../repository/demo_verification_repository.dart';
import '../widgets/profile_sub_screen_app_bar.dart';
import '../widgets/verification_widgets.dart';

/// Capture flow: choose a document, take each photo the server asks for with
/// the camera, accept the consent and submit. Pops with `true` once submitted.
/// Expects the [AccountVerificationCubit] from the overview screen.
class VerificationCaptureScreen extends StatelessWidget {
  const VerificationCaptureScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l = l10n(context);

    return BlocListener<AccountVerificationCubit, AccountVerificationState>(
      listenWhen: (prev, curr) =>
          curr.issue != null && prev.issueSeq != curr.issueSeq,
      listener: (context, state) => _showIssue(context, state),
      child: Scaffold(
        backgroundColor: isDark
            ? AppColors.darkBackground
            : AppColors.background,
        appBar: ProfileSubScreenAppBar(title: l.avCaptureTitle),
        body: BlocBuilder<AccountVerificationCubit, AccountVerificationState>(
          buildWhen: (prev, curr) =>
              (prev.session == null) != (curr.session == null),
          builder: (context, state) => AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: state.session == null
                ? const _DocumentStep(key: ValueKey('document'))
                : const _PhotosStep(key: ValueKey('photos')),
          ),
        ),
      ),
    );
  }
}

void _showIssue(BuildContext context, AccountVerificationState state) {
  final l = l10n(context);
  final text = switch (state.issue!) {
    VerificationIssue.appUpdateRequired => l.avIssueAppUpdate,
    VerificationIssue.alreadyInProgress => l.avIssueInProgress,
    VerificationIssue.locked => l.avIssueLocked,
    VerificationIssue.cooldown => l.avIssueCooldown,
    VerificationIssue.sessionExpired => l.avIssueSessionExpired,
    VerificationIssue.invalidFile => l.avIssueInvalidFile,
    VerificationIssue.filesMissing => l.avIssueFilesMissing,
    VerificationIssue.generic => state.issueMessage ?? l.avLoadFailed,
  };
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(content: Text(text), behavior: SnackBarBehavior.floating),
    );

  // These can't be fixed from the capture flow — go back to the overview,
  // which shows the locked / in-review / cooldown state.
  if (state.issue == VerificationIssue.locked ||
      state.issue == VerificationIssue.alreadyInProgress ||
      state.issue == VerificationIssue.cooldown) {
    Navigator.of(context).maybePop();
  }
}

// ── Step 1: document type + issuing country ──────────────────────────────────

class _DocumentStep extends StatefulWidget {
  const _DocumentStep({super.key});

  @override
  State<_DocumentStep> createState() => _DocumentStepState();
}

class _DocumentStepState extends State<_DocumentStep> {
  VerificationDocumentType _type = VerificationDocumentType.passport;
  List<Country> _countries = const [];
  Country? _country;
  bool _loadingCountries = true;

  @override
  void initState() {
    super.initState();
    _loadCountries();
  }

  Future<void> _loadCountries() async {
    try {
      final countries = await context
          .read<CountryRepository>()
          .fetchCountries();
      if (!mounted) return;
      setState(() {
        // Only countries we can send as an alpha-3 issuingCountry.
        _countries = countries
            .where((c) => iso3CountryCode(c.countryCode) != null)
            .toList();
        _country ??= _countries
            .where((c) => c.countryCode.toUpperCase() == 'ET')
            .firstOrNull;
        _loadingCountries = false;
      });
    } catch (e, st) {
      appLogger.e('[VerificationCapture] countries failed', e, st);
      if (mounted) setState(() => _loadingCountries = false);
    }
  }

  void _continue() {
    final country = _country;
    if (country == null) return;
    context.read<AccountVerificationCubit>().startSession(
      documentType: _type,
      issuingCountry: iso3CountryCode(country.countryCode)!,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l = l10n(context);
    final starting = context.select(
      (AccountVerificationCubit c) =>
          c.state.action == VerificationAction.starting,
    );

    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
            children: [
              _SectionTitle(
                title: l.avChooseDocument,
                subtitle: l.avChooseDocumentSub,
                isDark: isDark,
              ),
              const SizedBox(height: 16),
              for (final type in VerificationDocumentType.values)
                _DocumentOption(
                  label: documentTypeLabel(l, type),
                  icon: _documentIcon(type),
                  selected: type == _type,
                  isDark: isDark,
                  onTap: starting ? null : () => setState(() => _type = type),
                ),
              const SizedBox(height: 20),
              Text(l.avIssuingCountry, style: _labelStyle(isDark)),
              const SizedBox(height: 8),
              CountryPickerField(
                isDark: isDark,
                countries: _countries,
                selected: _country,
                hint: l.avIssuingCountryHint,
                loading: _loadingCountries,
                locked: starting,
                onSelected: (c) => setState(() => _country = c),
              ),
            ],
          ),
        ),
        _BottomAction(
          label: l.avContinue,
          loading: starting,
          onPressed: _country == null || starting ? null : _continue,
          isDark: isDark,
        ),
      ],
    );
  }

  static IconData _documentIcon(VerificationDocumentType type) =>
      switch (type) {
        VerificationDocumentType.passport => Icons.menu_book_outlined,
        VerificationDocumentType.nationalId => Icons.badge_outlined,
        VerificationDocumentType.driverLicense => Icons.directions_car_outlined,
        VerificationDocumentType.residencePermit => Icons.home_work_outlined,
      };
}

class _DocumentOption extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final bool isDark;
  final VoidCallback? onTap;

  const _DocumentOption({
    required this.label,
    required this.icon,
    required this.selected,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final border = selected
        ? AppColors.primary
        : (isDark ? AppColors.darkBorder : AppColors.border);
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: border, width: selected ? 1.5 : 1),
            ),
            child: Row(
              children: [
                Icon(icon, color: AppColors.primary, size: 22),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(
                      fontFamily: 'Manrope',
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: isDark
                          ? AppColors.darkTextPrimary
                          : AppColors.textPrimary,
                    ),
                  ),
                ),
                Icon(
                  selected
                      ? Icons.radio_button_checked_rounded
                      : Icons.radio_button_off_rounded,
                  color: selected
                      ? AppColors.primary
                      : (isDark
                            ? AppColors.darkTextTertiary
                            : AppColors.textTertiary),
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Step 2: photos + consent + submit ────────────────────────────────────────

class _PhotosStep extends StatefulWidget {
  const _PhotosStep({super.key});

  @override
  State<_PhotosStep> createState() => _PhotosStepState();
}

class _PhotosStepState extends State<_PhotosStep> {
  final _picker = ImagePicker();

  /// Photos taken on this device, for thumbnails only. Whether a photo is
  /// uploaded always comes from the server's `uploadedFiles`.
  final Map<VerificationFileKind, File> _previews = {};
  bool _consent = false;

  Future<void> _capture(VerificationFileKind kind) async {
    final l = l10n(context);
    final cubit = context.read<AccountVerificationCubit>();
    XFile? shot;
    try {
      shot = await _picker.pickImage(
        // The debug demo runs on Simulators, which have no camera.
        source: verificationDemoEnabled
            ? ImageSource.gallery
            : ImageSource.camera,
        preferredCameraDevice: kind == VerificationFileKind.selfieWithDoc
            ? CameraDevice.front
            : CameraDevice.rear,
        imageQuality: 85,
        maxWidth: 2400,
        maxHeight: 2400,
      );
    } on PlatformException catch (e, st) {
      appLogger.e('[VerificationCapture] camera failed', e, st);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l.avIssueCamera),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    if (shot == null || !mounted) return;

    final file = File(shot.path);
    final uploaded = await cubit.uploadPhoto(kind, file);
    if (uploaded && mounted) setState(() => _previews[kind] = file);
  }

  Future<void> _submit() async {
    final submitted = await context.read<AccountVerificationCubit>().submit();
    if (submitted && mounted) Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l = l10n(context);

    return BlocBuilder<AccountVerificationCubit, AccountVerificationState>(
      builder: (context, state) {
        final session = state.session;
        if (session == null) return const SizedBox.shrink();
        final isPassport =
            session.documentType == VerificationDocumentType.passport;
        final submitting = state.action == VerificationAction.submitting;
        final resumed = state.resumedDocumentType;

        return Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                children: [
                  if (resumed != null) ...[
                    _InfoBanner(
                      text: l.avResumedDocument(documentTypeLabel(l, resumed)),
                      isDark: isDark,
                    ),
                    const SizedBox(height: 16),
                  ],
                  _SectionTitle(
                    title: l.avPhotosTitle,
                    subtitle: l.avPhotosSub,
                    isDark: isDark,
                  ),
                  const SizedBox(height: 16),
                  for (final kind in session.requiredFiles)
                    _PhotoTile(
                      title: _kindTitle(l, kind, isPassport),
                      hint: _kindHint(l, kind),
                      preview: _previews[kind],
                      uploaded: session.uploadedFiles.contains(kind),
                      uploading: state.uploadingKind == kind,
                      enabled: !state.isBusy,
                      isDark: isDark,
                      onCapture: () => _capture(kind),
                    ),
                  const SizedBox(height: 8),
                  _ConsentRow(
                    value: _consent,
                    text: l.avConsent,
                    isDark: isDark,
                    onChanged: state.isBusy
                        ? null
                        : (v) => setState(() => _consent = v),
                  ),
                ],
              ),
            ),
            _BottomAction(
              label: l.avSubmitForReview,
              loading: submitting,
              onPressed: session.isComplete && _consent && !state.isBusy
                  ? _submit
                  : null,
              isDark: isDark,
            ),
          ],
        );
      },
    );
  }

  static String _kindTitle(
    AppLocalizations l,
    VerificationFileKind kind,
    bool isPassport,
  ) => switch (kind) {
    VerificationFileKind.docFront =>
      isPassport ? l.avPhotoPassportPage : l.avPhotoDocFront,
    VerificationFileKind.docBack => l.avPhotoDocBack,
    VerificationFileKind.selfieWithDoc => l.avPhotoSelfie,
  };

  static String _kindHint(AppLocalizations l, VerificationFileKind kind) =>
      switch (kind) {
        VerificationFileKind.docFront => l.avPhotoDocFrontHint,
        VerificationFileKind.docBack => l.avPhotoDocBackHint,
        VerificationFileKind.selfieWithDoc => l.avPhotoSelfieHint,
      };
}

class _PhotoTile extends StatelessWidget {
  final String title;
  final String hint;
  final File? preview;
  final bool uploaded;
  final bool uploading;
  final bool enabled;
  final bool isDark;
  final VoidCallback onCapture;

  const _PhotoTile({
    required this.title,
    required this.hint,
    required this.preview,
    required this.uploaded,
    required this.uploading,
    required this.enabled,
    required this.isDark,
    required this.onCapture,
  });

  @override
  Widget build(BuildContext context) {
    final l = l10n(context);
    final border = uploaded
        ? AppColors.success.withValues(alpha: 0.5)
        : (isDark ? AppColors.darkBorder : AppColors.border);
    final textSecondary = isDark
        ? AppColors.darkTextSecondary
        : AppColors.textSecondary;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: border),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Container(
              width: 72,
              height: 72,
              color: AppColors.primary.withValues(alpha: 0.08),
              child: preview != null
                  ? Image.file(preview!, fit: BoxFit.cover)
                  : Icon(
                      uploaded
                          ? Icons.check_circle_rounded
                          : Icons.photo_camera_outlined,
                      color: uploaded ? AppColors.success : AppColors.primary,
                    ),
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
                    color: isDark
                        ? AppColors.darkTextPrimary
                        : AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  uploading ? l.avUploading : (uploaded ? l.avUploaded : hint),
                  style: TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 12,
                    height: 1.4,
                    fontWeight: uploaded ? FontWeight.w700 : FontWeight.w400,
                    color: uploaded && !uploading
                        ? AppColors.success
                        : textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          uploading
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: AppColors.primary,
                  ),
                )
              : TextButton(
                  onPressed: enabled ? onCapture : null,
                  child: Text(
                    uploaded ? l.avRetake : l.avTakePhoto,
                    style: const TextStyle(
                      fontFamily: 'Manrope',
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
        ],
      ),
    );
  }
}

class _ConsentRow extends StatelessWidget {
  final bool value;
  final String text;
  final bool isDark;
  final ValueChanged<bool>? onChanged;

  const _ConsentRow({
    required this.value,
    required this.text,
    required this.isDark,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onChanged == null ? null : () => onChanged!(!value),
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Checkbox(
              value: value,
              activeColor: AppColors.primary,
              onChanged: onChanged == null
                  ? null
                  : (v) => onChanged!(v ?? false),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Text(
                  text,
                  style: TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 12,
                    height: 1.45,
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.textSecondary,
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

// ── Shared bits ──────────────────────────────────────────────────────────────

TextStyle _labelStyle(bool isDark) => TextStyle(
  fontFamily: 'Manrope',
  fontSize: 13,
  fontWeight: FontWeight.w700,
  color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
);

class _SectionTitle extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool isDark;

  const _SectionTitle({
    required this.title,
    required this.subtitle,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontFamily: 'Manrope',
            fontSize: 20,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.4,
            color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          subtitle,
          style: TextStyle(
            fontFamily: 'Manrope',
            fontSize: 13,
            height: 1.45,
            color: isDark
                ? AppColors.darkTextSecondary
                : AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

class _InfoBanner extends StatelessWidget {
  final String text;
  final bool isDark;

  const _InfoBanner({required this.text, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.info.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.info.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.info_outline_rounded,
            color: AppColors.info,
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontFamily: 'Manrope',
                fontSize: 13,
                height: 1.4,
                color: isDark
                    ? AppColors.darkTextPrimary
                    : AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BottomAction extends StatelessWidget {
  final String label;
  final bool loading;
  final VoidCallback? onPressed;
  final bool isDark;

  const _BottomAction({
    required this.label,
    required this.loading,
    required this.onPressed,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null;
    return Container(
      padding: EdgeInsets.fromLTRB(
        20,
        12,
        20,
        12 + MediaQuery.of(context).padding.bottom,
      ),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkBackground : AppColors.background,
        border: Border(
          top: BorderSide(
            color: (isDark ? AppColors.darkBorder : AppColors.border)
                .withValues(alpha: 0.7),
          ),
        ),
      ),
      child: SizedBox(
        width: double.infinity,
        height: 52,
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: enabled ? AppColors.primaryGradient : null,
            color: enabled ? null : AppColors.primary.withValues(alpha: 0.45),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onPressed,
              borderRadius: BorderRadius.circular(14),
              child: Center(
                child: loading
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: Colors.white,
                        ),
                      )
                    : Text(
                        label,
                        style: const TextStyle(
                          fontFamily: 'Manrope',
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
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
