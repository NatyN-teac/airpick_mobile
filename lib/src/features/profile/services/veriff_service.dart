import 'package:flutter/services.dart';
import 'package:veriff_flutter/veriff_flutter.dart';
import '../../../core/theme/app_colors.dart';

/// Thin wrapper around the official Veriff Flutter SDK with Airpick branding.
class VeriffService {
  const VeriffService();

  Future<Result> startVerification({
    required String sessionUrl,
    String? languageLocale,
    bool isDark = false,
  }) async {
    final config = Configuration(
      sessionUrl,
      branding: _airpickBranding(isDark: isDark),
      languageLocale: languageLocale,
    );

    try {
      return await Veriff().start(config);
    } on PlatformException catch (e) {
      throw Exception(e.message ?? 'Veriff could not start.');
    }
  }

  Branding _airpickBranding({required bool isDark}) => Branding(
        background: _hex(isDark ? AppColors.darkBackground : AppColors.background),
        onBackground: _hex(isDark ? AppColors.darkTextPrimary : AppColors.textPrimary),
        onBackgroundSecondary:
            _hex(isDark ? AppColors.darkTextSecondary : AppColors.textSecondary),
        onBackgroundTertiary:
            _hex(isDark ? AppColors.darkTextTertiary : AppColors.textTertiary),
        primary: _hex(AppColors.primary),
        onPrimary: _hex(AppColors.white),
        secondary: _hex(AppColors.secondary),
        onSecondary: _hex(AppColors.white),
        cameraOverlay: '#CC000000',
        onCameraOverlay: _hex(AppColors.white),
        outline: _hex(isDark ? AppColors.darkBorder : AppColors.border),
        error: _hex(AppColors.error),
        success: _hex(AppColors.success),
        feedbackSuccess: _hex(AppColors.success.withValues(alpha: 0.12)),
        onFeedbackSuccess: _hex(AppColors.success),
        feedbackError: _hex(AppColors.error.withValues(alpha: 0.12)),
        onFeedbackError: _hex(AppColors.error),
        buttonRadius: 14,
      );

  static String _hex(Color color) {
    final value = color.toARGB32() & 0xFFFFFF;
    return '#${value.toRadixString(16).padLeft(6, '0').toUpperCase()}';
  }
}

String? veriffErrorMessage(Error? error) {
  if (error == null) return null;
  return switch (error) {
    Error.cameraUnavailable => 'Camera is not available on this device.',
    Error.microphoneUnavailable => 'Microphone permission is required.',
    Error.networkError => 'Network error. Check your connection and try again.',
    Error.sessionError => 'Verification session expired. Please try again.',
    Error.deprecatedSDKVersion => 'Please update the app to continue.',
    Error.unknown => 'Something went wrong during verification.',
    Error.nfcError => 'NFC read failed. Try again or use another document.',
    Error.setupError => 'Verification could not be set up. Try again later.',
    Error.none => null,
  };
}
