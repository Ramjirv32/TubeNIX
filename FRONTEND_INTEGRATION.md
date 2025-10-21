# Flutter Frontend - Backend Integration

## ✅ Integration Complete!

The Flutter app is now connected to the Node.js backend for authentication.

### 🔌 Features Implemented:

1. **Sign Up** - Register new users with email/password
2. **Login** - Authenticate existing users
3. **Auto-Login** - Checks if user is already logged in on app start
4. **Logout** - Sign out and clear tokens
5. **Token Storage** - JWT tokens stored in SharedPreferences
6. **State Management** - Provider pattern for auth state
7. **Error Handling** - User-friendly error messages

---

### 📁 Files Created/Modified:

#### **New Files:**
- `lib/config/api_config.dart` - API endpoints configuration
- `lib/models/user_model.dart` - User data model
- `lib/models/auth_response.dart` - API response model
- `lib/services/auth_service.dart` - HTTP calls to backend
- `lib/providers/auth_provider.dart` - State management

#### **Modified Files:**
- `lib/main.dart` - Added AuthProvider
- `lib/screens/login_screen.dart` - Connected to backend API
- `lib/screens/splash_screen.dart` - Auto-login check
- `lib/screens/settings_screen.dart` - Logout functionality

---

### 🚀 How to Test:

1. **Make sure backend is running:**
   ```bash
   cd backend
   npm run dev
   ```
   Backend should be at: `http://localhost:5000`

2. **Run Flutter app:**
   ```bash
   flutter run -d linux
   ```

3. **Test Sign Up:**
   - Click on "Sign Up" tab
   - Enter name, email, password
   - Click "Create Account"
   - Should navigate to dashboard on success

4. **Test Login:**
   - Click on "Login" tab
   - Enter email and password
   - Click "Login"
   - Should navigate to dashboard on success

5. **Test Logout:**
   - Go to Settings (bottom nav)
   - Scroll to bottom
   - Click "Logout" button
   - Confirm logout
   - Should navigate back to login screen

6. **Test Auto-Login:**
   - Login to the app
   - Close the app completely
   - Reopen the app
   - Should automatically go to dashboard (skip login)

---

### 🔧 API Configuration:

**File:** `lib/config/api_config.dart`

Current setting:
```dart
static const String baseUrl = 'http://localhost:5000/api';
```

**For Android Emulator:**
```dart
static const String baseUrl = 'http://10.0.2.2:5000/api';
```

**For Real Device:**
```dart
static const String baseUrl = 'http://YOUR_COMPUTER_IP:5000/api';
```

---

### 📱 User Flow:

```
Splash Screen
    ↓
Check Auth State
    ↓
    ├─→ [Logged In] → Dashboard
    └─→ [Not Logged In] → Login/Signup Screen
            ↓
        Enter Credentials
            ↓
        API Call to Backend
            ↓
        ├─→ [Success] → Save Token → Dashboard
        └─→ [Error] → Show Error Message
```

---

### 🔐 Authentication Flow:

#### **Sign Up:**
1. User enters: name, email, password
2. Frontend validates input
3. POST request to `/api/auth/signup`
4. Backend creates user with bcrypt hashed password
5. Backend returns JWT token + user data
6. Frontend saves token to SharedPreferences
7. Navigate to dashboard

#### **Login:**
1. User enters: email, password
2. Frontend validates input
3. POST request to `/api/auth/login`
4. Backend verifies email exists
5. Backend compares password with bcrypt
6. Backend returns JWT token + user data
7. Frontend saves token to SharedPreferences
8. Navigate to dashboard

#### **Auto-Login:**
1. App starts
2. Check if token exists in SharedPreferences
3. If token exists → Navigate to dashboard
4. If no token → Navigate to login screen

#### **Logout:**
1. User clicks logout
2. POST request to `/api/auth/logout`
3. Clear token from SharedPreferences
4. Clear user data
5. Navigate to login screen

---

### ✅ Testing Checklist:

- [ ] Sign up with new email
- [ ] Try to sign up with same email (should fail)
- [ ] Login with correct credentials
- [ ] Try login with wrong password (should fail)
- [ ] Try login with unregistered email (should fail)
- [ ] Logout from settings
- [ ] Close and reopen app (should auto-login)
- [ ] Check error messages display correctly
- [ ] Check loading states work

---

### 🐛 Troubleshooting:

**Error: "Connection error"**
- Make sure backend is running on port 5000
- Check `api_config.dart` has correct base URL
- For Android emulator, use `10.0.2.2` instead of `localhost`

**Error: "Email already registered"**
- This email is already in MongoDB
- Try logging in instead
- Or use a different email

**Error: "Email is not registered"**
- Sign up first before trying to login

**Token not persisting:**
- Check SharedPreferences is working
- Check AuthProvider.init() is called in main.dart

**Backend not responding:**
```bash
# Check backend status
cd backend
npm run dev

# Check MongoDB status
sudo systemctl status mongod
```

---

### 📊 State Management:

**AuthProvider** manages:
- `user` - Current user data
- `isLoading` - Loading state for API calls
- `errorMessage` - Error messages
- `isAuthenticated` - Login status

**Usage in widgets:**
```dart
// Get auth state
final authProvider = Provider.of<AuthProvider>(context);

// Check if logged in
if (authProvider.isAuthenticated) {
  // Show logged in UI
}

// Get user data
final user = authProvider.user;
print(user?.name);
print(user?.email);
```

---

### 🎉 Next Steps:

1. ✅ Test all authentication flows
2. Add Google Sign-In integration (Firebase)
3. Add password reset functionality
4. Add email verification
5. Add profile picture upload
6. Add user profile editing

---

## 🔗 Backend API Endpoints:

All endpoints are documented in `backend/README.md`

- POST `/api/auth/signup` - Register
- POST `/api/auth/login` - Login
- POST `/api/auth/google` - Google Sign In
- GET `/api/auth/me` - Get current user (Protected)
- POST `/api/auth/logout` - Logout (Protected)
