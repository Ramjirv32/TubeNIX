// App Configuration and Constants
// Central place for app-wide constants and configuration

import 'package:flutter/material.dart';

class AppConfig {
  // App Information
  static const String appName = 'TubeNix';
  static const String appTagline = 'The Creator\'s Challenge';
  static const String appVersion = '1.0.0';
  
  // Color Palette
  static const Color primaryRed = Color(0xFFFF0000);
  static const Color primaryOrange = Color(0xFFFF6B00);
  static const Color primaryPurple = Color(0xFF9C27B0);
  static const Color backgroundDark = Color(0xFF0F0F0F);
  static const Color cardBackground = Color(0xFF1E1E1E);
  static const Color textWhite = Color(0xFFFFFFFF);
  static const Color textGray = Color(0xFFB3B3B3);
  static const Color accentTeal = Color(0xFF00BCD4);
  
  // Gradient Colors
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primaryRed, primaryOrange],
  );
  
  static const LinearGradient splashGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primaryRed, primaryOrange, primaryPurple],
  );
  
  // Timing Constants
  static const Duration splashDuration = Duration(seconds: 3);
  static const Duration animationDuration = Duration(milliseconds: 1500);
  static const Duration loadingDelay = Duration(milliseconds: 500);
  static const Duration refreshDuration = Duration(seconds: 1);
  
  // UI Constants
  static const double cardBorderRadius = 12.0;
  static const double iconSize = 24.0;
  static const double fabIconSize = 28.0;
  static const double appBarHeight = 56.0;
  
  // Padding & Spacing
  static const double paddingSmall = 8.0;
  static const double paddingMedium = 16.0;
  static const double paddingLarge = 24.0;
  static const double paddingXLarge = 32.0;
  
  // Font Sizes
  static const double fontSizeSmall = 12.0;
  static const double fontSizeMedium = 14.0;
  static const double fontSizeNormal = 16.0;
  static const double fontSizeLarge = 18.0;
  static const double fontSizeXLarge = 24.0;
  static const double fontSizeTitle = 32.0;
  static const double fontSizeHero = 48.0;
  
  // Grid Layout
  static const int thumbnailGridColumns = 2;
  static const double thumbnailAspectRatio = 0.75;
  static const double gridSpacing = 12.0;
  
  // API Endpoints (for future implementation)
  static const String baseUrl = 'https://api.tubenix.com';
  static const String loginEndpoint = '/auth/login';
  static const String signupEndpoint = '/auth/signup';
  static const String thumbnailsEndpoint = '/thumbnails';
  static const String analyticsEndpoint = '/analytics';
  
  // Feature Flags (for gradual rollout)
  static const bool enableGoogleSignIn = true;
  static const bool enableNotifications = true;
  static const bool enableAnalytics = true;
  static const bool enableDarkModeToggle = false; // Coming soon
  
  // Storage Keys (for SharedPreferences)
  static const String keyUserName = 'user_name';
  static const String keyUserEmail = 'user_email';
  static const String keyIsLoggedIn = 'is_logged_in';
  static const String keyThemeMode = 'theme_mode';
  
  // Messages
  static const String msgLoginSuccess = 'Login successful!';
  static const String msgSignupSuccess = 'Account created successfully!';
  static const String msgDeleteSuccess = 'Thumbnail deleted';
  static const String msgComingSoon = 'Coming Soon!';
  static const String msgNoInternet = 'No internet connection';
  static const String msgErrorOccurred = 'An error occurred. Please try again.';
  
  // Validation
  static const int minPasswordLength = 6;
  static const int maxTitleLength = 100;
  static const int maxDescriptionLength = 500;
  
  // Thumbnail Colors (for placeholder generation)
  static const List<Color> thumbnailColors = [
    Colors.red,
    Colors.blue,
    Colors.green,
    Colors.orange,
    Colors.purple,
    Colors.teal,
    Colors.pink,
    Colors.amber,
    Colors.cyan,
    Colors.lime,
  ];
  
  // Sample Video Titles
  static const List<String> sampleTitles = [
    'How to Grow YouTube Channel Fast',
    'Best SEO Tips for 2024',
    'Content Strategy That Works',
    'Viral Video Ideas 2024',
    'YouTube Algorithm Explained',
    'Thumbnail Design Secrets',
    'Monetization Strategies',
    'Audience Retention Tips',
    'Video Editing Tutorial',
    'YouTube Studio Guide',
  ];
  
  // Box Shadows
  static BoxShadow primaryShadow = BoxShadow(
    color: primaryRed.withOpacity(0.3),
    blurRadius: 10,
    spreadRadius: 1,
  );
  
  static BoxShadow cardShadow = BoxShadow(
    color: Colors.black.withOpacity(0.2),
    blurRadius: 8,
    offset: const Offset(0, 4),
  );
  
  // Border Radius
  static BorderRadius smallRadius = BorderRadius.circular(8);
  static BorderRadius mediumRadius = BorderRadius.circular(12);
  static BorderRadius largeRadius = BorderRadius.circular(20);
  static BorderRadius circularRadius = BorderRadius.circular(100);
  
  // Text Styles (can be used throughout the app)
  static const TextStyle headingStyle = TextStyle(
    fontSize: fontSizeTitle,
    fontWeight: FontWeight.bold,
    color: textWhite,
  );
  
  static const TextStyle subheadingStyle = TextStyle(
    fontSize: fontSizeLarge,
    fontWeight: FontWeight.w600,
    color: textWhite,
  );
  
  static const TextStyle bodyStyle = TextStyle(
    fontSize: fontSizeMedium,
    color: textGray,
  );
  
  static const TextStyle captionStyle = TextStyle(
    fontSize: fontSizeSmall,
    color: textGray,
  );
}
