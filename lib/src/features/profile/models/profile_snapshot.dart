import 'dart:convert';
import '../../auth/models/user_model.dart';

// Lightweight, persistable snapshot of the signed-in user for the profile UI.
class ProfileSnapshot {
  final String email;
  final String? firstName;
  final String? lastName;
  final String? profilePictureUrl;
  final bool isVerified;

  const ProfileSnapshot({
    required this.email,
    this.firstName,
    this.lastName,
    this.profilePictureUrl,
    this.isVerified = false,
  });

  factory ProfileSnapshot.fromUser(UserModel user) => ProfileSnapshot(
        email: user.email,
        firstName: user.profile.firstName,
        lastName: user.profile.lastName,
        profilePictureUrl: user.profile.profilePictureUrl,
        isVerified: user.profile.isVerified,
      );

  factory ProfileSnapshot.fromJson(Map<String, dynamic> json) =>
      ProfileSnapshot(
        email: json['email'] as String? ?? '',
        firstName: json['firstName'] as String?,
        lastName: json['lastName'] as String?,
        profilePictureUrl: json['profilePictureUrl'] as String?,
        isVerified: json['isVerified'] as bool? ?? false,
      );

  Map<String, dynamic> toJson() => {
        'email': email,
        'firstName': firstName,
        'lastName': lastName,
        'profilePictureUrl': profilePictureUrl,
        'isVerified': isVerified,
      };

  String encode() => jsonEncode(toJson());
  static ProfileSnapshot decode(String s) =>
      ProfileSnapshot.fromJson(jsonDecode(s) as Map<String, dynamic>);

  String get fullName {
    final n = '${firstName ?? ''} ${lastName ?? ''}'.trim();
    return n.isEmpty ? email.split('@').first : n;
  }

  String get initial {
    final f = firstName;
    if (f != null && f.isNotEmpty) return f[0].toUpperCase();
    return email.isNotEmpty ? email[0].toUpperCase() : '?';
  }
}
