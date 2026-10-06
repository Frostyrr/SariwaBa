class UserModel {
  final String id;
  final String email;
  final String? firstName;
  final String? lastName;
  final String? username;
  final bool isGuest;
  final bool isRegistered;

  const UserModel({
    required this.id,
    required this.email,
    this.firstName,
    this.lastName,
    this.username,
    this.isGuest = false,
    this.isRegistered = true,
  });

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
    return email.split('@').first;
  }

  UserModel copyWith({
    String? id,
    String? email,
    String? firstName,
    String? lastName,
    String? username,
    bool? isGuest,
    bool? isRegistered,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      username: username ?? this.username,
      isGuest: isGuest ?? this.isGuest,
      isRegistered: isRegistered ?? this.isRegistered,
    );
  }
}
