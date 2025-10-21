class AuthResponse {
  final bool success;
  final String message;
  final UserData? data;

  AuthResponse({
    required this.success,
    required this.message,
    this.data,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: json['data'] != null ? UserData.fromJson(json['data']) : null,
    );
  }
}

class UserData {
  final UserModel user;
  final String token;

  UserData({
    required this.user,
    required this.token,
  });

  factory UserData.fromJson(Map<String, dynamic> json) {
    return UserData(
      user: UserModel.fromJson(json['user']),
      token: json['token'] ?? '',
    );
  }
}

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
}
