import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../models/profile_snapshot.dart';

class ProfileAvatar extends StatelessWidget {
  final ProfileSnapshot profile;
  final double size;

  const ProfileAvatar({super.key, required this.profile, this.size = 72});

  Color _color() {
    const palette = [
      Color(0xFF4299E1),
      Color(0xFF48BB78),
      Color(0xFF9F7AEA),
      Color(0xFFED8936),
      Color(0xFFEC4899),
      Color(0xFF38B2AC),
    ];
    return palette[profile.displayName.hashCode.abs() % palette.length];
  }

  @override
  Widget build(BuildContext context) {
    final url = profile.profilePictureUrl;
    final color = _color();

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: (url == null || url.isEmpty)
            ? LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [color, color.withValues(alpha: 0.65)],
              )
            : null,
        image: (url != null && url.isNotEmpty)
            ? DecorationImage(
                image: NetworkImage(url),
                fit: BoxFit.cover,
              )
            : null,
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.35),
          width: 1.5,
        ),
      ),
      child: (url == null || url.isEmpty)
          ? Center(
              child: Text(
                profile.initials,
                style: TextStyle(
                  fontFamily: 'Manrope',
                  fontSize: size * 0.38,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
            )
          : null,
    );
  }
}
