import 'dart:convert';
import '../../auth/models/user_model.dart';
import 'user_profile_detail.dart';

// Lightweight, persistable snapshot of the signed-in user for the profile UI.
class ProfileSnapshot {
  final String email;
  final String? firstName;
  final String? middleName;
  final String? lastName;
  final String? city;
  final String? state;
  final String? country;
  final String? bio;
  final String? dob;
  final String? profilePictureUrl;
  final bool isVerified;
  final String? verificationStatus;

  const ProfileSnapshot({
    required this.email,
    this.firstName,
    this.middleName,
    this.lastName,
    this.city,
    this.state,
    this.country,
    this.bio,
    this.dob,
    this.profilePictureUrl,
    this.isVerified = false,
    this.verificationStatus,
  });

  factory ProfileSnapshot.fromUser(UserModel user) => ProfileSnapshot(
    email: user.email,
    firstName: user.profile.firstName,
    middleName: user.profile.middleName,
    lastName: user.profile.lastName,
    city: user.profile.city,
    state: user.profile.state,
    country: user.profile.country,
    bio: user.profile.bio,
    dob: user.profile.dob,
    profilePictureUrl: user.profile.profilePictureUrl,
    isVerified: user.profile.isVerified,
  );

  factory ProfileSnapshot.fromDetail(
    UserProfileDetail detail, {
    required ProfileSnapshot current,
  }) => ProfileSnapshot(
    email: detail.email ?? current.email,
    firstName: detail.firstName ?? current.firstName,
    middleName: detail.middleName ?? current.middleName,
    lastName: detail.lastName ?? current.lastName,
    city: detail.city ?? current.city,
    state: detail.state ?? current.state,
    country: detail.country ?? current.country,
    bio: detail.bio ?? current.bio,
    dob: detail.dob ?? current.dob,
    profilePictureUrl: detail.profilePictureUrl ?? current.profilePictureUrl,
    isVerified: detail.isVerified,
    verificationStatus: current.verificationStatus,
  );

  /// Applies saved form values on top of any API response so the profile
  /// header updates immediately even when PUT returns partial/null fields.
  factory ProfileSnapshot.mergeAfterSave({
    required UpdateUserProfileRequest request,
    UserProfileDetail? detail,
    required ProfileSnapshot current,
  }) {
    final merged = detail != null
        ? ProfileSnapshot.fromDetail(detail, current: current)
        : current;
    return merged.copyWith(
      firstName: request.firstName.trim(),
      middleName: _trimOrNull(request.middleName),
      lastName: request.lastName.trim(),
      city: request.city.trim(),
      state: _trimOrNull(request.state),
      country: request.country.trim(),
      bio: _trimOrNull(request.bio),
      dob: request.dob.trim(),
      profilePictureUrl:
          _trimOrNull(request.profilePictureUrl) ?? merged.profilePictureUrl,
    );
  }

  static String? _trimOrNull(String? value) {
    if (value == null) return null;
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }

  factory ProfileSnapshot.fromJson(Map<String, dynamic> json) =>
      ProfileSnapshot(
        email: json['email'] as String? ?? '',
        firstName: json['firstName'] as String?,
        middleName: json['middleName'] as String?,
        lastName: json['lastName'] as String?,
        city: json['city'] as String?,
        state: json['state'] as String?,
        country: json['country'] as String?,
        bio: json['bio'] as String?,
        dob: json['dob'] as String?,
        profilePictureUrl: json['profilePictureUrl'] as String?,
        isVerified: json['isVerified'] as bool? ?? false,
        verificationStatus: json['verificationStatus'] as String?,
      );

  Map<String, dynamic> toJson() => {
    'email': email,
    'firstName': firstName,
    'middleName': middleName,
    'lastName': lastName,
    'city': city,
    'state': state,
    'country': country,
    'bio': bio,
    'dob': dob,
    'profilePictureUrl': profilePictureUrl,
    'isVerified': isVerified,
    'verificationStatus': verificationStatus,
  };

  ProfileSnapshot copyWith({
    String? email,
    String? firstName,
    String? middleName,
    String? lastName,
    String? city,
    String? state,
    String? country,
    String? bio,
    String? dob,
    String? profilePictureUrl,
    bool? isVerified,
    String? verificationStatus,
  }) => ProfileSnapshot(
    email: email ?? this.email,
    firstName: firstName ?? this.firstName,
    middleName: middleName ?? this.middleName,
    lastName: lastName ?? this.lastName,
    city: city ?? this.city,
    state: state ?? this.state,
    country: country ?? this.country,
    bio: bio ?? this.bio,
    dob: dob ?? this.dob,
    profilePictureUrl: profilePictureUrl ?? this.profilePictureUrl,
    isVerified: isVerified ?? this.isVerified,
    verificationStatus: verificationStatus ?? this.verificationStatus,
  );

  String encode() => jsonEncode(toJson());
  static ProfileSnapshot decode(String s) =>
      ProfileSnapshot.fromJson(jsonDecode(s) as Map<String, dynamic>);

  String get fullName {
    final n = '${firstName ?? ''} ${lastName ?? ''}'.trim();
    return n.isEmpty ? email.split('@').first : n;
  }

  /// Header label: "Jane D." when first + last name exist.
  String get displayName {
    final first = firstName?.trim();
    if (first != null && first.isNotEmpty) {
      final last = lastName?.trim();
      if (last != null && last.isNotEmpty) {
        return '$first ${last[0].toUpperCase()}.';
      }
      return first;
    }
    if (email.isNotEmpty) return email.split('@').first;
    return 'Guest';
  }

  String get initial {
    final f = firstName;
    if (f != null && f.isNotEmpty) return f[0].toUpperCase();
    return email.isNotEmpty ? email[0].toUpperCase() : '?';
  }

  /// Avatar fallback when no profile picture (e.g. "JD").
  String get initials {
    final f = firstName?.trim();
    final l = lastName?.trim();
    if (f != null && f.isNotEmpty && l != null && l.isNotEmpty) {
      return '${f[0]}${l[0]}'.toUpperCase();
    }
    return initial;
  }

  bool get hasIdentity =>
      (firstName?.trim().isNotEmpty ?? false) ||
      (lastName?.trim().isNotEmpty ?? false) ||
      (profilePictureUrl?.trim().isNotEmpty ?? false) ||
      email.isNotEmpty;
}
