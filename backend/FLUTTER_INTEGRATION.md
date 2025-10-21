# Flutter Integration Guide

## 🔗 Connecting Flutter App to Backend

### Base URL
```dart
const String BASE_URL = 'http://localhost:5000/api';
```

### 1. Sign Up with Email/Password

```dart
Future<Map<String, dynamic>> signUp({
  required String name,
  required String email,
  required String password,
}) async {
  final response = await http.post(
    Uri.parse('$BASE_URL/auth/signup'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({
      'name': name,
      'email': email,
      'password': password,
    }),
  );

  return jsonDecode(response.body);
}
```

### 2. Login with Email/Password

```dart
Future<Map<String, dynamic>> login({
  required String email,
  required String password,
}) async {
  final response = await http.post(
    Uri.parse('$BASE_URL/auth/login'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({
      'email': email,
      'password': password,
    }),
  );

  return jsonDecode(response.body);
}
```

### 3. Google Sign In

```dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

Future<Map<String, dynamic>> signInWithGoogle() async {
  // 1. Trigger Google Sign In
  final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
  
  if (googleUser == null) {
    throw Exception('Google sign in cancelled');
  }

  // 2. Get Google Auth credentials
  final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

  // 3. Create Firebase credential
  final credential = GoogleAuthProvider.credential(
    accessToken: googleAuth.accessToken,
    idToken: googleAuth.idToken,
  );

  // 4. Sign in to Firebase
  final UserCredential userCredential = 
      await FirebaseAuth.instance.signInWithCredential(credential);
  
  final User? user = userCredential.user;
  
  if (user == null) {
    throw Exception('Firebase sign in failed');
  }

  // 5. Get Firebase ID token
  final String? idToken = await user.getIdToken();

  // 6. Send to backend
  final response = await http.post(
    Uri.parse('$BASE_URL/auth/google'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({
      'idToken': idToken,
      'name': user.displayName ?? '',
      'email': user.email ?? '',
      'photoURL': user.photoURL ?? '',
      'uid': user.uid,
    }),
  );

  return jsonDecode(response.body);
}
```

### 4. Get Current User (Protected Route)

```dart
Future<Map<String, dynamic>> getCurrentUser(String token) async {
  final response = await http.get(
    Uri.parse('$BASE_URL/auth/me'),
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    },
  );

  return jsonDecode(response.body);
}
```

### 5. Logout

```dart
Future<Map<String, dynamic>> logout(String token) async {
  final response = await http.post(
    Uri.parse('$BASE_URL/auth/logout'),
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    },
  );

  return jsonDecode(response.body);
}
```

---

## 📦 Required Flutter Dependencies

Add these to your `pubspec.yaml`:

```yaml
dependencies:
  flutter:
    sdk: flutter
  
  # HTTP requests
  http: ^1.1.0
  
  # Firebase
  firebase_core: ^2.24.0
  firebase_auth: ^4.15.0
  
  # Google Sign In
  google_sign_in: ^6.1.5
  
  # Local storage for token
  shared_preferences: ^2.2.2
  
  # State management (optional)
  provider: ^6.1.1
```

---

## 🔐 Token Storage

Store JWT token locally:

```dart
import 'package:shared_preferences/shared_preferences.dart';

// Save token
Future<void> saveToken(String token) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString('auth_token', token);
}

// Get token
Future<String?> getToken() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString('auth_token');
}

// Clear token (logout)
Future<void> clearToken() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.remove('auth_token');
}
```

---

## 🎯 Complete Auth Service Example

```dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  static const String BASE_URL = 'http://localhost:5000/api';
  
  // Sign Up
  Future<Map<String, dynamic>> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$BASE_URL/auth/signup'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': name,
          'email': email,
          'password': password,
        }),
      );

      final data = jsonDecode(response.body);
      
      if (data['success']) {
        await _saveToken(data['data']['token']);
      }
      
      return data;
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  // Login
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$BASE_URL/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      final data = jsonDecode(response.body);
      
      if (data['success']) {
        await _saveToken(data['data']['token']);
      }
      
      return data;
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  // Google Sign In
  Future<Map<String, dynamic>> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      
      if (googleUser == null) {
        return {'success': false, 'message': 'Google sign in cancelled'};
      }

      final GoogleSignInAuthentication googleAuth = 
          await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential = 
          await FirebaseAuth.instance.signInWithCredential(credential);
      
      final User? user = userCredential.user;
      
      if (user == null) {
        return {'success': false, 'message': 'Firebase sign in failed'};
      }

      final String? idToken = await user.getIdToken();

      final response = await http.post(
        Uri.parse('$BASE_URL/auth/google'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'idToken': idToken,
          'name': user.displayName ?? '',
          'email': user.email ?? '',
          'photoURL': user.photoURL ?? '',
          'uid': user.uid,
        }),
      );

      final data = jsonDecode(response.body);
      
      if (data['success']) {
        await _saveToken(data['data']['token']);
      }
      
      return data;
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  // Get Current User
  Future<Map<String, dynamic>> getCurrentUser() async {
    try {
      final token = await _getToken();
      
      if (token == null) {
        return {'success': false, 'message': 'No token found'};
      }

      final response = await http.get(
        Uri.parse('$BASE_URL/auth/me'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  // Logout
  Future<void> logout() async {
    await _clearToken();
    await GoogleSignIn().signOut();
    await FirebaseAuth.instance.signOut();
  }

  // Token management
  Future<void> _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
  }

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  Future<void> _clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
  }

  // Check if logged in
  Future<bool> isLoggedIn() async {
    final token = await _getToken();
    return token != null;
  }
}
```

---

## 🚀 Usage in Flutter

```dart
// Initialize
final authService = AuthService();

// Sign Up
final result = await authService.signUp(
  name: 'John Doe',
  email: 'john@example.com',
  password: 'password123',
);

if (result['success']) {
  print('Signed up successfully!');
  print('Token: ${result['data']['token']}');
} else {
  print('Error: ${result['message']}');
}

// Login
final loginResult = await authService.login(
  email: 'john@example.com',
  password: 'password123',
);

// Google Sign In
final googleResult = await authService.signInWithGoogle();

// Get Current User
final user = await authService.getCurrentUser();

// Logout
await authService.logout();
```

---

## ⚠️ Important Notes

1. **Change BASE_URL for Android Emulator:**
   ```dart
   // For Android Emulator
   const String BASE_URL = 'http://10.0.2.2:5000/api';
   
   // For Real Device (replace with your computer's IP)
   const String BASE_URL = 'http://192.168.1.X:5000/api';
   ```

2. **Add Internet Permission (Android):**
   In `android/app/src/main/AndroidManifest.xml`:
   ```xml
   <uses-permission android:name="android.permission.INTERNET" />
   ```

3. **Initialize Firebase in main.dart:**
   ```dart
   void main() async {
     WidgetsFlutterBinding.ensureInitialized();
     await Firebase.initializeApp(
       options: FirebaseOptions(
         apiKey: "AIzaSyCmzuNczFYHBlNxD7XjZT1aemxuPAwoob8",
         authDomain: "oodser-e235a.firebaseapp.com",
         projectId: "oodser-e235a",
         storageBucket: "oodser-e235a.firebasestorage.app",
         messagingSenderId: "962749598434",
         appId: "1:962749598434:web:dc2d6148c7d181ad58ecbb",
       ),
     );
     runApp(MyApp());
   }
   ```

---

## ✅ Testing Checklist

- [ ] Sign up with email/password
- [ ] Login with email/password
- [ ] Try duplicate email (should fail)
- [ ] Try wrong password (should fail)
- [ ] Sign in with Google
- [ ] Get current user with token
- [ ] Access protected route
- [ ] Logout
- [ ] Token persists after app restart
