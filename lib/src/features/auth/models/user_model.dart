class UserModel {
  final String id;
  final String email;
  final String providerId;
  final String role;
  final String? activeMode;
  final bool isActiveUser;
  final bool isBlocked;
  final String createdAt;
  final UserProfile profile;
  final String token;

  const UserModel({
    required this.id,
    required this.email,
    required this.providerId,
    required this.role,
    this.activeMode,
    required this.isActiveUser,
    required this.isBlocked,
    required this.createdAt,
    required this.profile,
    required this.token,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      email: json['email'] as String,
      providerId: json['providerId'] as String,
      role: json['role'] as String,
      activeMode: json['activeMode'] as String?,
      isActiveUser: json['isActiveUser'] as bool,
      isBlocked: json['isBlocked'] as bool,
      createdAt: json['createdAt'] as String,
      profile: UserProfile.fromJson(json['profile'] as Map<String, dynamic>),
      token: json['token'] as String,
    );
  }
}

class UserProfile {
  final String id;
  final String? firstName;
  final String? middleName;
  final String? lastName;
  final bool isVerified;
  final String? city;
  final String? state;
  final String? country;
  final String? profilePictureUrl;
  final String? bio;
  final String createdAt;
  final String updatedAt;

  const UserProfile({
    required this.id,
    this.firstName,
    this.middleName,
    this.lastName,
    required this.isVerified,
    this.city,
    this.state,
    this.country,
    this.profilePictureUrl,
    this.bio,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] as String,
      firstName: json['firstName'] as String?,
      middleName: json['middleName'] as String?,
      lastName: json['lastName'] as String?,
      isVerified: json['isVerified'] as bool,
      city: json['city'] as String?,
      state: json['state'] as String?,
      country: json['country'] as String?,
      profilePictureUrl: json['profilePictureUrl'] as String?,
      bio: json['bio'] as String?,
      createdAt: json['createdAt'] as String,
      updatedAt: json['updatedAt'] as String,
    );
  }

  bool get isProfileComplete =>
      firstName != null &&
      firstName!.isNotEmpty &&
      lastName != null &&
      lastName!.isNotEmpty;
}
