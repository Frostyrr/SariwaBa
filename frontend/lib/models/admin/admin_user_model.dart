class AdminUserModel {
  final int id;
  final String email;
  final String? firstName;
  final String? lastName;
  final String? username;
  final String? profilePicture;
  final String role;
  final bool isAdmin;
  final bool isSuspended;
  final DateTime? suspendedAt;
  final int scanCount;
  final DateTime? createdAt;

  const AdminUserModel({
    required this.id,
    required this.email,
    this.firstName,
    this.lastName,
    this.username,
    this.profilePicture,
    this.role = 'user',
    this.isAdmin = false,
    this.isSuspended = false,
    this.suspendedAt,
    this.scanCount = 0,
    this.createdAt,
  });

  factory AdminUserModel.fromJson(Map<String, dynamic> json) {
    return AdminUserModel(
      id: json['id'] as int? ?? 0,
      email: json['email'] as String? ?? '',
      firstName: json['first_name'] as String?,
      lastName: json['last_name'] as String?,
      username: json['username'] as String?,
      profilePicture: json['profile_picture'] as String?,
      role: json['role'] as String? ?? 'user',
      isAdmin: json['is_admin'] as bool? ?? false,
      isSuspended: json['is_suspended'] as bool? ?? false,
      suspendedAt: json['suspended_at'] != null
          ? DateTime.tryParse(json['suspended_at'].toString())
          : null,
      scanCount: json['scan_count'] as int? ?? 0,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
    );
  }

  String get displayName {
    if (firstName != null && firstName!.isNotEmpty) {
      if (lastName != null && lastName!.isNotEmpty) {
        return '$firstName $lastName';
      }
      return firstName!;
    }
    if (username != null && username!.isNotEmpty) {
      return '@$username';
    }
    return email.isNotEmpty ? email.split('@').first : 'User #$id';
  }

  String get initials {
    if (firstName != null && firstName!.isNotEmpty) {
      final first = firstName![0].toUpperCase();
      final last = (lastName != null && lastName!.isNotEmpty)
          ? lastName![0].toUpperCase()
          : '';
      return '$first$last';
    }
    return email.isNotEmpty ? email[0].toUpperCase() : 'U';
  }

  AdminUserModel copyWith({
    int? id,
    String? email,
    String? firstName,
    String? lastName,
    String? username,
    String? profilePicture,
    String? role,
    bool? isAdmin,
    bool? isSuspended,
    DateTime? suspendedAt,
    int? scanCount,
    DateTime? createdAt,
  }) {
    return AdminUserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      username: username ?? this.username,
      profilePicture: profilePicture ?? this.profilePicture,
      role: role ?? this.role,
      isAdmin: isAdmin ?? this.isAdmin,
      isSuspended: isSuspended ?? this.isSuspended,
      suspendedAt: suspendedAt ?? this.suspendedAt,
      scanCount: scanCount ?? this.scanCount,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
