# TubeNix Backend API

Complete authentication system with MongoDB, JWT, bcrypt, and Firebase Google Auth.

## 🚀 Quick Start

### 1. Install Dependencies
```bash
npm install
```

### 2. Setup MongoDB
Make sure MongoDB is running on your local machine:
```bash
# Start MongoDB
sudo systemctl start mongod

# Check status
sudo systemctl status mongod
```

### 3. Configure Environment
The `.env` file is already configured with:
- MongoDB: `mongodb://localhost:27017/tubenix`
- Firebase credentials
- JWT secret

### 4. Start Server
```bash
# Development mode with auto-reload
npm run dev

# Production mode
npm start
```

Server will start on: `http://localhost:5000`

---

## 📋 API Endpoints

### Authentication Routes

#### 1. **Sign Up** (Email/Password)
```http
POST /api/auth/signup
Content-Type: application/json

{
  "name": "John Doe",
  "email": "john@example.com",
  "password": "password123"
}
```

**Response:**
```json
{
  "success": true,
  "message": "User registered successfully",
  "data": {
    "user": {
      "id": "...",
      "name": "John Doe",
      "email": "john@example.com",
      "authProvider": "local",
      "role": "user",
      "createdAt": "..."
    },
    "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
  }
}
```

#### 2. **Login** (Email/Password)
```http
POST /api/auth/login
Content-Type: application/json

{
  "email": "john@example.com",
  "password": "password123"
}
```

**Response:**
```json
{
  "success": true,
  "message": "Login successful",
  "data": {
    "user": { ... },
    "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
  }
}
```

#### 3. **Google Sign In**
```http
POST /api/auth/google
Content-Type: application/json

{
  "idToken": "firebase-id-token",
  "name": "John Doe",
  "email": "john@gmail.com",
  "photoURL": "https://...",
  "uid": "google-user-id"
}
```

**Response:**
```json
{
  "success": true,
  "message": "Login successful",
  "data": {
    "user": { ... },
    "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
  }
}
```

#### 4. **Get Current User** (Protected)
```http
GET /api/auth/me
Authorization: Bearer <your-jwt-token>
```

**Response:**
```json
{
  "success": true,
  "data": {
    "user": { ... }
  }
}
```

#### 5. **Logout** (Protected)
```http
POST /api/auth/logout
Authorization: Bearer <your-jwt-token>
```

---

## 🔐 Authentication Features

### ✅ Email/Password Authentication
- ✅ User signup with email & password
- ✅ Password hashing with bcrypt (10 rounds)
- ✅ Email validation (regex)
- ✅ Password minimum length (6 characters)
- ✅ Duplicate email check
- ✅ Login verification
- ✅ JWT token generation
- ✅ Protected routes with JWT middleware

### ✅ Google Authentication
- ✅ Firebase Google Sign-In integration
- ✅ Auto-create user on first Google login
- ✅ Prevent mixing auth providers (email vs Google)
- ✅ Profile picture from Google
- ✅ Auto-verified email for Google users

### ✅ Security Features
- ✅ Password never returned in responses
- ✅ JWT tokens with 7-day expiration
- ✅ Protected routes with Bearer token
- ✅ Role-based access control (user/admin)
- ✅ Last login tracking
- ✅ Mongoose schema validation

---

## 📁 Project Structure

```
backend/
├── config/
│   ├── config.js        # Environment configuration
│   ├── database.js      # MongoDB connection
│   └── firebase.js      # Firebase initialization
├── controllers/
│   └── authController.js # Auth logic (signup, login, google)
├── middleware/
│   ├── auth.js          # JWT verification & role check
│   └── errorHandler.js  # Centralized error handling
├── models/
│   └── User.js          # User schema with bcrypt
├── routes/
│   └── authRoutes.js    # Auth endpoints
├── utils/
│   └── jwt.js           # JWT token utilities
├── .env                 # Environment variables
├── .gitignore          # Git ignore rules
├── package.json        # Dependencies
└── server.js           # Express app setup
```

---

## 🧪 Testing with cURL

### Sign Up
```bash
curl -X POST http://localhost:5000/api/auth/signup \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Test User",
    "email": "test@example.com",
    "password": "password123"
  }'
```

### Login
```bash
curl -X POST http://localhost:5000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test@example.com",
    "password": "password123"
  }'
```

### Get Current User
```bash
curl -X GET http://localhost:5000/api/auth/me \
  -H "Authorization: Bearer YOUR_JWT_TOKEN"
```

---

## 🔍 Validation Rules

### Sign Up
- ✅ Name: Required, max 50 characters
- ✅ Email: Required, valid email format, unique
- ✅ Password: Required, minimum 6 characters

### Login
- ✅ Email: Must be registered in database
- ✅ Password: Must match hashed password
- ✅ Auth Provider: Must use correct login method

### Google Sign In
- ✅ Email: Required
- ✅ UID: Required (Google user ID)
- ✅ Prevents mixing with email/password accounts

---

## ⚠️ Error Responses

### Duplicate Email
```json
{
  "success": false,
  "message": "Email already registered. Please login instead."
}
```

### Invalid Credentials
```json
{
  "success": false,
  "message": "Invalid email or password"
}
```

### Email Not Registered
```json
{
  "success": false,
  "message": "Email is not registered. Please sign up first."
}
```

### Wrong Auth Provider
```json
{
  "success": false,
  "message": "This account uses Google Sign-In. Please use Google to login."
}
```

### Unauthorized
```json
{
  "success": false,
  "message": "Not authorized to access this route"
}
```

---

## 🔧 Environment Variables

```env
PORT=5000
NODE_ENV=development
MONGODB_URI=mongodb://localhost:27017/tubenix
JWT_SECRET=your-super-secret-jwt-key-change-this-in-production
JWT_EXPIRE=7d
FIREBASE_API_KEY=AIzaSyCmzuNczFYHBlNxD7XjZT1aemxuPAwoob8
FIREBASE_AUTH_DOMAIN=oodser-e235a.firebaseapp.com
FIREBASE_PROJECT_ID=oodser-e235a
FIREBASE_STORAGE_BUCKET=oodser-e235a.firebasestorage.app
FIREBASE_MESSAGING_SENDER_ID=962749598434
FIREBASE_APP_ID=1:962749598434:web:dc2d6148c7d181ad58ecbb
CLIENT_URL=http://localhost:3000
```

---

## 📦 Database Schema

### User Model
```javascript
{
  name: String (required, max 50 chars),
  email: String (required, unique, validated),
  password: String (hashed with bcrypt, required for local auth),
  googleId: String (unique, for Google auth),
  profilePicture: String,
  authProvider: Enum ['local', 'google'],
  isEmailVerified: Boolean,
  role: Enum ['user', 'admin'],
  lastLogin: Date,
  createdAt: Date,
  updatedAt: Date
}
```

---

## 🚦 Next Steps

1. ✅ Install dependencies: `npm install`
2. ✅ Start MongoDB: `sudo systemctl start mongod`
3. ✅ Start server: `npm run dev`
4. ✅ Test signup endpoint
5. ✅ Test login endpoint
6. ✅ Test Google auth endpoint
7. 📱 Integrate with Flutter app

---

## 🛠️ Development Tips

- Server auto-reloads on file changes (nodemon)
- MongoDB database: `tubenix`
- Default collection: `users`
- JWT tokens expire after 7 days
- Passwords are salted with 10 rounds

---

## 🎯 Firebase Client Setup (Flutter)

Use this configuration in your Flutter app:

```dart
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
```

Then send the ID token to `/api/auth/google` endpoint!
