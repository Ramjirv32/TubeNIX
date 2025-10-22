import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import '../config/api_config.dart';
import '../models/auth_response.dart';

class AuthService {
  // Token storage keys
  static const String _tokenKey = 'auth_token';
  static const String _userKey = 'user_data';

  // Google Sign In instance
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
  );

  /// Sign Up with Email and Password
  Future<AuthResponse> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      print('✍️  Sign up attempt for: $email');
      print('📡 API URL: ${ApiConfig.signup}');
      
      final response = await http.post(
        Uri.parse(ApiConfig.signup),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': name,
          'email': email,
          'password': password,
        }),
      ).timeout(ApiConfig.connectionTimeout);

      print('📥 Response status: ${response.statusCode}');
      print('📥 Response body: ${response.body}');

      final data = jsonDecode(response.body);
      final authResponse = AuthResponse.fromJson(data);

      // Save token if signup successful
      if (authResponse.success && authResponse.data != null) {
        await _saveToken(authResponse.data!.token);
        await _saveUser(authResponse.data!.user);
        print('✅ Sign up successful, token saved');
      } else {
        print('❌ Sign up failed: ${authResponse.message}');
      }

      return authResponse;
    } catch (e) {
      print('❌ Sign up error: $e');
      return AuthResponse(
        success: false,
        message: 'Connection error: ${e.toString()}',
      );
    }
  }

  /// Login with Email and Password
  Future<AuthResponse> login({
    required String email,
    required String password,
  }) async {
    try {
      print('🔐 Login attempt for: $email');
      print('📡 API URL: ${ApiConfig.login}');
      
      final response = await http.post(
        Uri.parse(ApiConfig.login),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      ).timeout(ApiConfig.connectionTimeout);

      print('📥 Response status: ${response.statusCode}');
      print('📥 Response body: ${response.body}');

      final data = jsonDecode(response.body);
      final authResponse = AuthResponse.fromJson(data);

      // Save token if login successful
      if (authResponse.success && authResponse.data != null) {
        await _saveToken(authResponse.data!.token);
        await _saveUser(authResponse.data!.user);
        print('✅ Login successful, token saved');
      } else {
        print('❌ Login failed: ${authResponse.message}');
      }

      return authResponse;
    } catch (e) {
      print('❌ Login error: $e');
      return AuthResponse(
        success: false,
        message: 'Connection error: ${e.toString()}',
      );
    }
  }

  /// Google Sign In
  Future<AuthResponse> signInWithGoogle() async {
    try {
      print('🔐 Starting Google Sign-In...');

      // Check if Firebase is initialized
      try {
        await Firebase.initializeApp();
      } catch (e) {
        // Firebase already initialized or not available
        print('📝 Firebase check: $e');
      }

      // Trigger Google Sign-In flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        // User cancelled the sign-in
        return AuthResponse(
          success: false,
          message: 'Google Sign-In cancelled',
        );
      }

      print('✅ Google user: ${googleUser.email}');

      // Obtain auth details
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // Create credential for Firebase
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase
      final UserCredential userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
      final User? firebaseUser = userCredential.user;

      if (firebaseUser == null) {
        return AuthResponse(
          success: false,
          message: 'Failed to sign in with Google',
        );
      }

      print('🔥 Firebase user: ${firebaseUser.uid}');

      // Send ID token to backend for verification
      final idToken = await firebaseUser.getIdToken();
      
      print('📡 Sending to backend: ${ApiConfig.googleAuth}');
      
      final response = await http.post(
        Uri.parse(ApiConfig.googleAuth),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'idToken': idToken,
          'name': firebaseUser.displayName ?? 'User',
          'email': firebaseUser.email ?? '',
          'uid': firebaseUser.uid,
        }),
      ).timeout(ApiConfig.connectionTimeout);

      print('📥 Response status: ${response.statusCode}');
      print('📥 Response body: ${response.body}');

      final data = jsonDecode(response.body);
      final authResponse = AuthResponse.fromJson(data);

      // Save token if login successful
      if (authResponse.success && authResponse.data != null) {
        await _saveToken(authResponse.data!.token);
        await _saveUser(authResponse.data!.user);
        print('✅ Google Sign-In successful, token saved');
      } else {
        print('❌ Google Sign-In failed: ${authResponse.message}');
      }

      return authResponse;
    } catch (e) {
      print('❌ Google Sign-In error: $e');
      return AuthResponse(
        success: false,
        message: 'Google Sign-In error: ${e.toString()}',
      );
    }
  }

  /// Get Current User (Protected Route)
  Future<AuthResponse> getCurrentUser() async {
    try {
      final token = await getToken();

      if (token == null) {
        return AuthResponse(
          success: false,
          message: 'No token found. Please login.',
        );
      }

      final response = await http.get(
        Uri.parse(ApiConfig.getMe),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(ApiConfig.connectionTimeout);

      final data = jsonDecode(response.body);
      return AuthResponse.fromJson(data);
    } catch (e) {
      return AuthResponse(
        success: false,
        message: 'Connection error: ${e.toString()}',
      );
    }
  }

  /// Logout
  Future<void> logout() async {
    try {
      final token = await getToken();

      if (token != null) {
        await http.post(
          Uri.parse(ApiConfig.logout),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
        ).timeout(ApiConfig.connectionTimeout);
      }
    } catch (e) {
      print('Logout error: $e');
    } finally {
      // Clear local data regardless of API call result
      await clearToken();
      await clearUser();
    }
  }

  /// Change Password
  Future<AuthResponse> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      final token = await getToken();

      if (token == null) {
        return AuthResponse(
          success: false,
          message: 'No token found. Please login.',
        );
      }

      print('🔐 Changing password...');
      
      final response = await http.put(
        Uri.parse(ApiConfig.changePassword),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'currentPassword': currentPassword,
          'newPassword': newPassword,
        }),
      ).timeout(ApiConfig.connectionTimeout);

      print('📥 Response status: ${response.statusCode}');
      print('📥 Response body: ${response.body}');

      final data = jsonDecode(response.body);
      return AuthResponse.fromJson(data);
    } catch (e) {
      print('❌ Change password error: $e');
      return AuthResponse(
        success: false,
        message: 'Connection error: ${e.toString()}',
      );
    }
  }

  /// Update Profile
  Future<AuthResponse> updateProfile({
    String? name,
    String? profilePicture,
  }) async {
    try {
      final token = await getToken();

      if (token == null) {
        return AuthResponse(
          success: false,
          message: 'No token found. Please login.',
        );
      }

      print('👤 Updating profile...');

      final body = <String, dynamic>{};
      if (name != null) body['name'] = name;
      if (profilePicture != null) body['profilePicture'] = profilePicture;
      
      final response = await http.put(
        Uri.parse(ApiConfig.updateProfile),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(body),
      ).timeout(ApiConfig.connectionTimeout);

      print('📥 Response status: ${response.statusCode}');
      print('📥 Response body: ${response.body}');

      final data = jsonDecode(response.body);
      final authResponse = AuthResponse.fromJson(data);

      // Update saved user data if successful
      if (authResponse.success && authResponse.data != null) {
        await _saveUser(authResponse.data!.user);
      }

      return authResponse;
    } catch (e) {
      print('❌ Update profile error: $e');
      return AuthResponse(
        success: false,
        message: 'Connection error: ${e.toString()}',
      );
    }
  }

  /// Save token to local storage
  Future<void> _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  /// Get token from local storage
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  /// Clear token from local storage
  Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
  }

  /// Save user data to local storage
  Future<void> _saveUser(UserModel user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userKey, jsonEncode({
      'id': user.id,
      'name': user.name,
      'email': user.email,
      'profilePicture': user.profilePicture,
      'authProvider': user.authProvider,
      'isEmailVerified': user.isEmailVerified,
      'role': user.role,
      'createdAt': user.createdAt.toIso8601String(),
    }));
  }

  /// Get user data from local storage
  Future<UserModel?> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString(_userKey);

    if (userJson == null) return null;

    final data = jsonDecode(userJson);
    return UserModel.fromJson(data);
  }

  /// Clear user data from local storage
  Future<void> clearUser() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userKey);
  }

  /// Check if user is logged in
  Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  /// Update Email
  Future<AuthResponse> updateEmail({
    required String email,
    required String password,
  }) async {
    try {
      final token = await getToken();

      if (token == null) {
        return AuthResponse(
          success: false,
          message: 'No token found. Please login.',
        );
      }

      print('📧 Updating email...');
      
      final response = await http.put(
        Uri.parse(ApiConfig.updateEmail),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      ).timeout(ApiConfig.connectionTimeout);

      print('📥 Response status: ${response.statusCode}');
      print('📥 Response body: ${response.body}');

      final data = jsonDecode(response.body);
      final authResponse = AuthResponse.fromJson(data);

      // Update saved user data if successful
      if (authResponse.success && authResponse.data != null) {
        await _saveUser(authResponse.data!.user);
      }

      return authResponse;
    } catch (e) {
      print('❌ Update email error: $e');
      return AuthResponse(
        success: false,
        message: 'Connection error: ${e.toString()}',
      );
    }
  }

  /// Update Settings
  Future<Map<String, dynamic>> updateSettings({
    required String settingsType,
    required Map<String, dynamic> settings,
  }) async {
    try {
      final token = await getToken();

      if (token == null) {
        return {
          'success': false,
          'message': 'No token found. Please login.',
        };
      }

      print('⚙️ Updating $settingsType settings...');
      
      final response = await http.put(
        Uri.parse(ApiConfig.updateSettings),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'settingsType': settingsType,
          'settings': settings,
        }),
      ).timeout(ApiConfig.connectionTimeout);

      print('📥 Response status: ${response.statusCode}');
      print('📥 Response body: ${response.body}');

      return jsonDecode(response.body);
    } catch (e) {
      print('❌ Update settings error: $e');
      return {
        'success': false,
        'message': 'Connection error: ${e.toString()}',
      };
    }
  }

  /// Get Settings
  Future<Map<String, dynamic>> getSettings() async {
    try {
      final token = await getToken();

      if (token == null) {
        return {
          'success': false,
          'message': 'No token found. Please login.',
        };
      }

      print('⚙️ Getting settings...');
      
      final response = await http.get(
        Uri.parse(ApiConfig.getSettings),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(ApiConfig.connectionTimeout);

      print('📥 Response status: ${response.statusCode}');
      print('📥 Response body: ${response.body}');

      return jsonDecode(response.body);
    } catch (e) {
      print('❌ Get settings error: $e');
      return {
        'success': false,
        'message': 'Connection error: ${e.toString()}',
      };
    }
  }
}
