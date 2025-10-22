import 'package:flutter/material.dart';
import '../models/auth_response.dart';
import '../services/auth_service.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();

  UserModel? _user;
  bool _isLoading = false;
  String? _errorMessage;
  bool _isAuthenticated = false;

  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _isAuthenticated;

  /// Initialize auth state (check if user is already logged in)
  Future<void> init() async {
    _isLoading = true;
    notifyListeners();

    try {
      final isLoggedIn = await _authService.isLoggedIn();

      if (isLoggedIn) {
        _user = await _authService.getUser();
        _isAuthenticated = true;
      }
    } catch (e) {
      print('Init error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Sign Up
  Future<AuthResponse> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _authService.signUp(
        name: name,
        email: email,
        password: password,
      );

      if (response.success && response.data != null) {
        _user = response.data!.user;
        _isAuthenticated = true;
        _errorMessage = null;
      } else {
        _errorMessage = response.message;
      }

      return response;
    } catch (e) {
      _errorMessage = e.toString();
      return AuthResponse(
        success: false,
        message: e.toString(),
      );
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Login
  Future<AuthResponse> login({
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _authService.login(
        email: email,
        password: password,
      );

      if (response.success && response.data != null) {
        _user = response.data!.user;
        _isAuthenticated = true;
        _errorMessage = null;
      } else {
        _errorMessage = response.message;
      }

      return response;
    } catch (e) {
      _errorMessage = e.toString();
      return AuthResponse(
        success: false,
        message: e.toString(),
      );
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Google Sign In
  Future<AuthResponse> signInWithGoogle() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _authService.signInWithGoogle();

      if (response.success && response.data != null) {
        _user = response.data!.user;
        _isAuthenticated = true;
        _errorMessage = null;
      } else {
        _errorMessage = response.message;
      }

      return response;
    } catch (e) {
      _errorMessage = e.toString();
      return AuthResponse(
        success: false,
        message: e.toString(),
      );
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Logout
  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _authService.logout();
      _user = null;
      _isAuthenticated = false;
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Change Password
  Future<AuthResponse> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _authService.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );

      if (!response.success) {
        _errorMessage = response.message;
      }

      return response;
    } catch (e) {
      _errorMessage = e.toString();
      return AuthResponse(
        success: false,
        message: e.toString(),
      );
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Update Profile
  Future<AuthResponse> updateProfile({
    String? name,
    String? profilePicture,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _authService.updateProfile(
        name: name,
        profilePicture: profilePicture,
      );

      if (response.success && response.data != null) {
        _user = response.data!.user;
        _errorMessage = null;
      } else {
        _errorMessage = response.message;
      }

      return response;
    } catch (e) {
      _errorMessage = e.toString();
      return AuthResponse(
        success: false,
        message: e.toString(),
      );
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Update Email
  Future<AuthResponse> updateEmail({
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _authService.updateEmail(
        email: email,
        password: password,
      );

      if (response.success && response.data != null) {
        _user = response.data!.user;
        _errorMessage = null;
      } else {
        _errorMessage = response.message;
      }

      return response;
    } catch (e) {
      _errorMessage = e.toString();
      return AuthResponse(
        success: false,
        message: e.toString(),
      );
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Update Settings
  Future<Map<String, dynamic>> updateSettings({
    required String settingsType,
    required Map<String, dynamic> settings,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _authService.updateSettings(
        settingsType: settingsType,
        settings: settings,
      );

      if (response['success'] != true) {
        _errorMessage = response['message'];
      }

      return response;
    } catch (e) {
      _errorMessage = e.toString();
      return {
        'success': false,
        'message': e.toString(),
      };
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Get Settings
  Future<Map<String, dynamic>> getSettings() async {
    try {
      return await _authService.getSettings();
    } catch (e) {
      return {
        'success': false,
        'message': e.toString(),
      };
    }
  }

  /// Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
