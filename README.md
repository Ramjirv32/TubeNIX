# TubeNix - YouTube Content Creator Tool

A beautiful, modern Flutter mobile application for YouTube content creators to manage thumbnails, track analytics, and optimize their content strategy.

## Features

### 🎨 Beautiful UI/UX
- **Dark Theme** with gradient accents (Red to Orange to Purple)
- **Smooth Animations** including fade-in, scale, and transitions
- **Material Design 3** with custom components
- **Poppins Font** for modern typography
- **Responsive Design** for all screen sizes

### 📱 App Screens

#### 1. Splash Screen
- TubeNix logo with gradient background
- Smooth loading animation with circular progress indicator
- Auto-navigation to Login screen after 3 seconds
- Fade-in and scale animations

#### 2. Login/Signup Screen
- Modern tabbed interface (Login & Sign Up)
- Email/Password authentication with validation
- Password visibility toggle
- "Forgot Password?" link
- Google Sign-In button
- Dummy authentication (accepts any credentials)
- Form validation for all fields

#### 3. Dashboard Screen
- **Top App Bar**: Logo, notifications, and user profile
- **Welcome Message**: Personalized greeting
- **Statistics Cards**:
  - Total Thumbnails Generated
  - Total Videos Analyzed
  - Trending Keywords Found
  - Average CTR (Click-Through Rate)
- **Search Bar**: Filter thumbnails
- **Thumbnails Grid**: 2-column grid view with:
  - Thumbnail preview (colorful placeholders)
  - Title
  - Date created
  - CTR percentage badge
  - Action buttons: View, Download, Delete
- **Floating Action Button**: Generate new thumbnail
- **Bottom Navigation Bar**: Home, Thumbnails, Analytics, Profile
- **Pull-to-Refresh**: Refresh thumbnail data

### 🎯 Key Features

- **8 Dummy Thumbnails** with varied data
- **Real-time Statistics** calculated from thumbnails
- **Delete Functionality** with confirmation dialog
- **Preview Modal** to view thumbnail details
- **Empty State** when no thumbnails exist
- **Loading States** with circular progress indicators
- **Responsive Grid** adapts to screen size

## Color Scheme

```dart
Primary Red: #FF0000
Primary Orange: #FF6B00
Primary Purple: #9C27B0
Background Dark: #0F0F0F
Card Background: #1E1E1E
Text White: #FFFFFF
Text Gray: #B3B3B3
Accent Teal: #00BCD4
```

## Project Structure

```
lib/
├── main.dart                    # App entry point
├── models/
│   └── thumbnail_model.dart     # Data model & dummy data
├── screens/
│   ├── splash_screen.dart       # Splash screen with animations
│   ├── login_screen.dart        # Login/Signup with tabs
│   └── dashboard_screen.dart    # Main dashboard
└── widgets/
    ├── stat_card.dart          # Statistics card component
    └── thumbnail_card.dart     # Thumbnail grid item
```

## Dependencies

```yaml
dependencies:
  flutter:
    sdk: flutter
  cupertino_icons: ^1.0.8
  google_fonts: ^6.1.0      # Poppins font family
  intl: ^0.19.0             # Date formatting
  provider: ^6.1.1          # State management (ready for future use)
```

## Getting Started

### Prerequisites
- Flutter SDK 3.0 or higher
- Dart 3.5.3 or higher
- Android Studio / VS Code with Flutter plugin
- Android/iOS emulator or physical device

### Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd my_app
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the app**
   ```bash
   flutter run
   ```

### Build for Production

**Android:**
```bash
flutter build apk --release
```

**iOS:**
```bash
flutter build ios --release
```

## How to Use

1. **Launch App** - See the splash screen with TubeNix logo
2. **Login/Sign Up** - Use any email/password or Google Sign-In
3. **View Dashboard** - See your statistics and thumbnails
4. **Search Thumbnails** - Use the search bar to filter
5. **View Details** - Tap the eye icon to preview
6. **Delete Thumbnails** - Tap the delete icon (with confirmation)
7. **Add New** - Tap the + button to generate (Coming Soon)
8. **Navigate** - Use bottom nav bar to switch sections

## Future Enhancements

- [ ] Backend integration with API
- [ ] Real thumbnail generation using AI
- [ ] Analytics graphs and charts
- [ ] Profile editing functionality
- [ ] Push notifications
- [ ] Social media integration
- [ ] Export reports
- [ ] Dark/Light theme toggle
- [ ] Multi-language support

## Technical Highlights

- ✅ **Clean Code** with comments
- ✅ **State Management** using setState
- ✅ **Custom Animations** with AnimationController
- ✅ **Form Validation** with validators
- ✅ **Responsive Layouts** with MediaQuery-ready structure
- ✅ **Reusable Widgets** for maintainability
- ✅ **Material Design 3** principles
- ✅ **Null Safety** enabled

## Screenshots

*Note: Add screenshots here after running the app*

## Performance

- Smooth 60fps animations
- Optimized widget rebuilds
- Lazy loading with GridView.builder
- Efficient state management

## Testing

Run tests:
```bash
flutter test
```

## License

This project is for educational and demonstration purposes.

## Support

For issues or questions, please open an issue in the repository.

---

**Made with ❤️ using Flutter**
# TubeNIX
