import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../config/app_config.dart';
import '../l10n/l10n.dart';

/// Opens the mail app addressed to [AppConfig.supportEmail]. If no mail app is
/// available, shows the address so the user can copy it.
Future<void> openSupportEmail(BuildContext context) async {
  final l = l10n(context);
  final uri = Uri(
    scheme: 'mailto',
    path: AppConfig.supportEmail,
    query: 'subject=${Uri.encodeComponent(l.avSupportEmailSubject)}',
  );
  final messenger = ScaffoldMessenger.maybeOf(context);
  try {
    if (await launchUrl(uri)) return;
  } catch (_) {}
  messenger?.showSnackBar(
    const SnackBar(
      content: SelectableText(AppConfig.supportEmail),
      behavior: SnackBarBehavior.floating,
    ),
  );
}
