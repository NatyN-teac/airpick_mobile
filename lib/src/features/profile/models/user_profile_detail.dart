class UserProfileDetail {
  final String? firstName;
  final String? middleName;
  final String? lastName;
  final String? city;
  final String? state;
  final String? country;
  final String? bio;
  final String? email;
  final String? profilePictureUrl;

  const UserProfileDetail({
    this.firstName,
    this.middleName,
    this.lastName,
    this.city,
    this.state,
    this.country,
    this.bio,
    this.email,
    this.profilePictureUrl,
  });

  factory UserProfileDetail.fromJson(Map<String, dynamic> json) =>
      UserProfileDetail(
        firstName: json['firstName'] as String?,
        middleName: json['middleName'] as String?,
        lastName: json['lastName'] as String?,
        city: json['city'] as String?,
        state: json['state'] as String?,
        country: json['country'] as String?,
        bio: json['bio'] as String?,
        email: json['email'] as String?,
        profilePictureUrl: json['profilePictureUrl'] as String? ??
            json['profilePicUrl'] as String?,
      );

  Map<String, dynamic> toUpdateJson() {
    final map = <String, dynamic>{
      if (firstName != null && firstName!.isNotEmpty) 'firstName': firstName,
      if (middleName != null && middleName!.isNotEmpty) 'middleName': middleName,
      if (lastName != null && lastName!.isNotEmpty) 'lastName': lastName,
      if (city != null && city!.isNotEmpty) 'city': city,
      if (state != null && state!.isNotEmpty) 'state': state,
      if (country != null && country!.isNotEmpty) 'country': country,
      if (bio != null && bio!.isNotEmpty) 'bio': bio,
    };
    return map;
  }
}

class UpdateUserProfileRequest {
  final String? firstName;
  final String? middleName;
  final String? lastName;
  final String? city;
  final String? state;
  final String? country;
  final String? bio;

  const UpdateUserProfileRequest({
    this.firstName,
    this.middleName,
    this.lastName,
    this.city,
    this.state,
    this.country,
    this.bio,
  });

  Map<String, dynamic> toJson() => {
        if (firstName != null) 'firstName': firstName!.trim(),
        if (middleName != null) 'middleName': middleName!.trim(),
        if (lastName != null) 'lastName': lastName!.trim(),
        if (city != null) 'city': city!.trim(),
        if (state != null) 'state': state!.trim(),
        if (country != null) 'country': country!.trim(),
        if (bio != null) 'bio': bio!.trim(),
      };
}
