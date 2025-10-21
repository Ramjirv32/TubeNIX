class UserModel {
  final String id;
  final String name;
  final String email;
  final String? profilePicture;
  final String authProvider;
  final bool isEmailVerified;
  final String role;
  final DateTime createdAt;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.profilePicture,
    required this.authProvider,
    required this.isEmailVerified,
    required this.role,
    required this.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      profilePicture: json['profilePicture'],
      authProvider: json['authProvider'] ?? 'local',
      isEmailVerified: json['isEmailVerified'] ?? false,
      role: json['role'] ?? 'user',
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'profilePicture': profilePicture,
      'authProvider': authProvider,
      'isEmailVerified': isEmailVerified,
      'role': role,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  @override
  String toString() {
    return 'UserModel(id: $id, name: $name, email: $email, authProvider: $authProvider)';
  }
}
