import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/theme/app_colors.dart';

/// Bottom sheet where the carrier adds a proof photo (pickup or delivery):
/// tap the box to pick from camera or library, see a preview, then confirm.
/// Pops with the picked file path, or null if dismissed.
class ProofPhotoSheet extends StatefulWidget {
  final String title;
  final String description;
  final String actionLabel;

  const ProofPhotoSheet({
    super.key,
    required this.title,
    required this.description,
    required this.actionLabel,
  });

  /// Shows the sheet and returns the chosen photo's path (null if dismissed).
  static Future<String?> show(
    BuildContext context, {
    required String title,
    required String description,
    required String actionLabel,
  }) {
    return showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ProofPhotoSheet(
        title: title,
        description: description,
        actionLabel: actionLabel,
      ),
    );
  }

  @override
  State<ProofPhotoSheet> createState() => _ProofPhotoSheetState();
}

class _ProofPhotoSheetState extends State<ProofPhotoSheet> {
  final _picker = ImagePicker();
  String? _photoPath;

  Future<void> _pick(ImageSource source) async {
    final file = await _picker.pickImage(source: source, imageQuality: 85);
    if (file != null && mounted) setState(() => _photoPath = file.path);
  }

  Future<void> _chooseSource() async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final isDark = Theme.of(ctx).brightness == Brightness.dark;
        final bg = isDark ? AppColors.darkSurface : Colors.white;
        return Container(
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 24),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(16),
          ),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.photo_library_outlined),
                  title: const Text(
                    'Photo library',
                    style: TextStyle(fontFamily: 'Manrope'),
                  ),
                  onTap: () => Navigator.pop(ctx, ImageSource.gallery),
                ),
                ListTile(
                  leading: const Icon(Icons.camera_alt_outlined),
                  title: const Text(
                    'Camera',
                    style: TextStyle(fontFamily: 'Manrope'),
                  ),
                  onTap: () => Navigator.pop(ctx, ImageSource.camera),
                ),
              ],
            ),
          ),
        );
      },
    );
    if (source != null) await _pick(source);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.darkSurface : Colors.white;
    final textPrimary = isDark
        ? AppColors.darkTextPrimary
        : AppColors.textPrimary;

    return Container(
      decoration: BoxDecoration(
        color: bg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(
        20,
        12,
        20,
        MediaQuery.of(context).padding.bottom + 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.textDisabled.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            widget.title,
            style: TextStyle(
              fontFamily: 'Manrope',
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            widget.description,
            style: TextStyle(
              fontFamily: 'Manrope',
              fontSize: 13,
              color: isDark
                  ? AppColors.darkTextSecondary
                  : AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: _chooseSource,
            child: Container(
              height: 160,
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkBackground : AppColors.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: _photoPath != null
                      ? AppColors.primary
                      : (isDark ? AppColors.darkBorder : AppColors.border),
                ),
              ),
              clipBehavior: Clip.antiAlias,
              child: _photoPath == null
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.add_a_photo_outlined,
                          size: 32,
                          color: isDark
                              ? AppColors.darkTextTertiary
                              : AppColors.textTertiary,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Tap to add photo',
                          style: TextStyle(
                            fontFamily: 'Manrope',
                            fontSize: 13,
                            color: isDark
                                ? AppColors.darkTextSecondary
                                : AppColors.textSecondary,
                          ),
                        ),
                      ],
                    )
                  : Image.file(
                      File(_photoPath!),
                      fit: BoxFit.cover,
                      width: double.infinity,
                    ),
            ),
          ),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: _photoPath == null
                ? null
                : () => Navigator.pop(context, _photoPath),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                gradient: _photoPath != null ? AppColors.primaryGradient : null,
                color: _photoPath == null ? AppColors.textDisabled : null,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Text(
                widget.actionLabel,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: 'Manrope',
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
