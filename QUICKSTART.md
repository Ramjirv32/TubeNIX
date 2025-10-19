# TubeNix - Quick Start Guide

## 🚀 Running the Application

### Option 1: Using an Android Emulator
```bash
# Start the emulator (if not already running)
flutter emulators --launch <emulator_id>

# Run the app
flutter run
```

### Option 2: Using a Physical Device
1. Enable USB Debugging on your Android/iOS device
2. Connect device via USB
3. Run: `flutter devices` to verify device is detected
4. Run: `flutter run`

### Option 3: Using Chrome (Web)
```bash
flutter run -d chrome
```

## 📱 App Flow

### 1. Splash Screen (Auto 3 seconds)
- Beautiful gradient background
- TubeNix logo with animations
- Loading indicator
- Automatically navigates to Login

### 2. Login Screen
**Login Tab:**
- Email: `user@example.com` (or any email)
- Password: `password` (or any password)
- Click "Login" button

**Sign Up Tab:**
- Fill in all fields (any values work)
- Passwords must match
- Click "Sign Up" button

**Alternative:**
- Click "Continue with Google" for instant access

### 3. Dashboard
- View your personalized dashboard
- See 8 pre-loaded thumbnail examples
- Explore statistics cards
- Try all features below

## ✨ Features to Try

### Statistics Cards
View 4 key metrics at the top:
- Total Thumbnails
- Total Videos Analyzed
- Trending Keywords
- Average CTR

### Thumbnail Grid
Each thumbnail card shows:
- Colorful preview image
- Video title
- Creation date
- CTR percentage badge

### Actions on Thumbnails
1. **View** 👁️ - Preview thumbnail details in modal
2. **Download** 💾 - Shows "Coming Soon" message
3. **Delete** 🗑️ - Removes thumbnail with confirmation

### Other Features
- **Search Bar** - Type to filter thumbnails (UI ready)
- **Pull to Refresh** - Swipe down to reload data
- **Add Button** (+) - Floating button to generate new thumbnail
- **Bottom Navigation** - Switch between sections

## 🎨 UI Highlights

### Color Palette
- **Gradient Buttons**: Red (#FF0000) → Orange (#FF6B00)
- **Dark Background**: #0F0F0F
- **Cards**: Dark Gray (#1E1E1E)
- **Accent Colors**: Purple, Teal, Pink

### Animations
- Splash screen fade-in and scale
- Smooth page transitions
- Button press effects
- Tab switching animations

## 🧪 Testing Features

### Test Login
```
Email: test@tubenix.com
Password: test123
```
(Any credentials work - it's dummy auth)

### Test Thumbnails
- 8 pre-loaded thumbnails with different:
  - Colors (Red, Blue, Green, Orange, Purple, Teal, Pink, Amber)
  - Titles (SEO, Growth, Viral ideas, etc.)
  - CTR values (8% - 15%)
  - Creation dates (Last 7 days)

## 🔧 Customization

### Change App Name
Edit `android/app/src/main/AndroidManifest.xml`:
```xml
<application android:label="TubeNix">
```

### Change App Icon
Replace icons in:
- `android/app/src/main/res/mipmap-*/ic_launcher.png`
- `ios/Runner/Assets.xcassets/AppIcon.appiconset/`

### Modify Theme Colors
Edit `lib/main.dart`:
```dart
primaryColor: const Color(0xFFFF0000), // Change red
scaffoldBackgroundColor: const Color(0xFF0F0F0F), // Change bg
```

### Add Real Data
Replace dummy data in `lib/models/thumbnail_model.dart`:
```dart
static List<ThumbnailModel> getThumbnails() {
  // Fetch from API or database
}
```

## 📋 Code Structure

```
lib/
├── main.dart                    # Entry point & theme
├── models/
│   └── thumbnail_model.dart     # Data models
├── screens/
│   ├── splash_screen.dart       # Splash with animations
│   ├── login_screen.dart        # Auth screens
│   └── dashboard_screen.dart    # Main app screen
└── widgets/
    ├── stat_card.dart          # Reusable stat card
    └── thumbnail_card.dart     # Reusable thumbnail item
```

## 🐛 Troubleshooting

### Issue: White screen after splash
**Solution**: Check if you have internet connection (google_fonts needs it initially)

### Issue: App crashes on startup
**Solution**: Run `flutter clean && flutter pub get`

### Issue: Slow performance
**Solution**: Run in release mode: `flutter run --release`

### Issue: Fonts not loading
**Solution**: Google Fonts downloads on first run. Fallback to system font if offline.

## 🔄 Development Workflow

### Hot Reload (Quick changes)
Press `r` in terminal or click ⚡ in IDE

### Hot Restart (State reset)
Press `R` in terminal or click 🔄 in IDE

### Check for errors
```bash
flutter analyze
```

### Run tests
```bash
flutter test
```

## 📦 Build for Production

### Android APK
```bash
flutter build apk --release
# Output: build/app/outputs/flutter-apk/app-release.apk
```

### Android App Bundle (Google Play)
```bash
flutter build appbundle --release
# Output: build/app/outputs/bundle/release/app-release.aab
```

### iOS
```bash
flutter build ios --release
# Then open in Xcode for signing
```

## 🎯 Next Steps

1. **Backend Integration**: Connect to real API
2. **AI Thumbnail Generator**: Implement actual generation
3. **Analytics**: Add charts and graphs
4. **Profile Settings**: User preferences
5. **Cloud Storage**: Save thumbnails to cloud
6. **Push Notifications**: Engagement reminders
7. **Social Sharing**: Export to social media

## 📝 Tips

- Use **Chrome DevTools** for debugging: `flutter run -d chrome --web-renderer html`
- Check **Flutter Inspector** in IDE for widget tree
- Use **Performance Overlay**: Enable in app or press `P` in terminal
- **Widget Rebuild Tracking**: Press `w` in terminal
- **Accessibility**: Test with screen readers

## 🆘 Support

- Flutter Docs: https://docs.flutter.dev
- Stack Overflow: Tag [flutter]
- GitHub Issues: Report bugs in repository

## 📸 Screenshots Location

Take screenshots while running:
```bash
# Take screenshot
flutter screenshot
# Saved to: flutter_*.png
```

---

**Happy Coding! 🎉**

For questions or contributions, please refer to the main README.md file.
