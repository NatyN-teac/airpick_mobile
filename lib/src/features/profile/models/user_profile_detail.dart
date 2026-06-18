class UserProfileDetail {
  final String? userId;
  final String? profileId;
  final String? firstName;
  final String? middleName;
  final String? lastName;
  final bool isVerified;
  final String? city;
  final String? state;
  final String? country;
  final String? bio;
  final String? dob;
  final String? email;
  final String? profilePictureUrl;
  final String? createdAt;
  final String? updatedAt;

  const UserProfileDetail({
    this.userId,
    this.profileId,
    this.firstName,
    this.middleName,
    this.lastName,
    this.isVerified = false,
    this.city,
    this.state,
    this.country,
    this.bio,
    this.dob,
    this.email,
    this.profilePictureUrl,
    this.createdAt,
    this.updatedAt,
  });

  factory UserProfileDetail.fromJson(Map<String, dynamic> json) {
    final nestedProfile = json['profile'] is Map<String, dynamic>
        ? json['profile'] as Map<String, dynamic>
        : json['userProfile'] is Map<String, dynamic>
        ? json['userProfile'] as Map<String, dynamic>
        : null;
    final profile = nestedProfile ?? json;

    return UserProfileDetail(
      userId: (profile['userId'] ?? json['userId'] ?? json['id']) as String?,
      profileId: profile['id'] as String?,
      firstName: profile['firstName'] as String?,
      middleName: profile['middleName'] as String?,
      lastName: profile['lastName'] as String?,
      isVerified: profile['isVerified'] as bool? ?? false,
      city: profile['city'] as String?,
      state: profile['state'] as String?,
      country: profile['country'] as String?,
      bio: profile['bio'] as String?,
      dob: profile['dob'] as String? ?? profile['dateOfBirth'] as String?,
      email: (profile['email'] ?? json['email']) as String?,
      profilePictureUrl:
          profile['profilePictureUrl'] as String? ??
          profile['profilePicUrl'] as String?,
      createdAt: profile['createdAt'] as String?,
      updatedAt: profile['updatedAt'] as String?,
    );
  }
}

class UpdateUserProfileRequest {
  final String firstName;
  final String lastName;
  final String city;
  final String country;
  final String dob;
  final String? middleName;
  final String? state;
  final String? bio;
  final String? profilePictureUrl;

  const UpdateUserProfileRequest({
    required this.firstName,
    required this.lastName,
    required this.city,
    required this.country,
    required this.dob,
    this.middleName,
    this.state,
    this.bio,
    this.profilePictureUrl,
  });

  Map<String, dynamic> toJson() => {
    'firstName': firstName.trim(),
    'middleName': _nullableTrim(middleName),
    'lastName': lastName.trim(),
    'city': city.trim(),
    'state': _nullableTrim(state),
    'country': country.trim(),
    'bio': _nullableTrim(bio),
    'profilePictureUrl': _nullableTrim(profilePictureUrl),
    'dob': dob.trim(),
  };

  static String? _nullableTrim(String? value) {
    if (value == null) return null;
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }
}

DateTime? parseProfileDob(String? raw) {
  if (raw == null || raw.isEmpty) return null;
  final iso = DateTime.tryParse(raw);
  if (iso != null) return iso;

  final parts = raw.split('/');
  if (parts.length == 3) {
    final m = int.tryParse(parts[0]);
    final d = int.tryParse(parts[1]);
    final y = int.tryParse(parts[2]);
    if (m != null && d != null && y != null) {
      return DateTime(y, m, d);
    }
  }
  return null;
}

String formatProfileDob(DateTime date) {
  final y = date.year.toString().padLeft(4, '0');
  final m = date.month.toString().padLeft(2, '0');
  final d = date.day.toString().padLeft(2, '0');
  return '$y-$m-$d';
}
