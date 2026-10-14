class UserModel {
  final String id;
  final String email;
  final String? firstName;
  final String? lastName;
  final String? username;
  final String? profilePicture;
  final bool isGuest;
  final bool isRegistered;

  const UserModel({
    required this.id,
    required this.email,
    this.firstName,
    this.lastName,
    this.username,
    this.profilePicture,
    this.isGuest = false,
    this.isRegistered = true,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id']?.toString() ?? '',
      email: json['email'] as String? ?? '',
      firstName: json['first_name'] as String?,
      lastName: json['last_name'] as String?,
      username: json['username'] as String?,
      profilePicture: json['profile_picture'] as String?,
      isGuest: json['is_guest'] as bool? ?? false,
      isRegistered: json['is_registered'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'first_name': firstName,
      'last_name': lastName,
      'username': username,
      'profile_picture': profilePicture,
      'is_guest': isGuest,
      'is_registered': isRegistered,
    };
  }

  String get displayName {
    if (isGuest) return 'Guest Evaluator';
    if (firstName != null && firstName!.isNotEmpty) {
      if (lastName != null && lastName!.isNotEmpty) {
        return '$firstName $lastName';
      }
      return firstName!;
    }
    if (username != null && username!.isNotEmpty) {
      return '@$username';
    }
    return email.isNotEmpty ? email.split('@').first : 'User';
  }

  UserModel copyWith({
    String? id,
    String? email,
    String? firstName,
    String? lastName,
    String? username,
    String? profilePicture,
    bool? isGuest,
    bool? isRegistered,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      username: username ?? this.username,
      profilePicture: profilePicture ?? this.profilePicture,
      isGuest: isGuest ?? this.isGuest,
      isRegistered: isRegistered ?? this.isRegistered,
    );
  }
}
