class ApiConfig {
  // Change this based on your environment
  
  // For Android Emulator
  // static const String baseUrl = 'http://10.0.2.2:5000/api';
  
  // For iOS Simulator / Real Device (replace with your computer's IP)
  // static const String baseUrl = 'http://192.168.1.X:5000/api';
  
  // For Linux Desktop / Chrome
  static const String baseUrl = 'http://localhost:5000/api';
  
  // Endpoints
  static const String signup = '$baseUrl/auth/signup';
  static const String login = '$baseUrl/auth/login';
  static const String googleAuth = '$baseUrl/auth/google';
  static const String getMe = '$baseUrl/auth/me';
  static const String logout = '$baseUrl/auth/logout';
  static const String changePassword = '$baseUrl/auth/change-password';
  static const String updateProfile = '$baseUrl/auth/profile';
  static const String updateEmail = '$baseUrl/auth/email';
  static const String updateSettings = '$baseUrl/auth/settings';
  static const String getSettings = '$baseUrl/auth/settings';
  
  // SERP API endpoints
  static const String trendingVideos = '$baseUrl/serp/trending/videos';
  static const String searchVideos = '$baseUrl/serp/search/videos';
  static const String trendingImages = '$baseUrl/serp/trending/images';
  static const String searchImages = '$baseUrl/serp/search/images';
  static const String chatSuggestions = '$baseUrl/serp/chat/suggestions';
  
  // Collection endpoints
  static const String collections = '$baseUrl/collections';
  static String collectionById(String id) => '$baseUrl/collections/$id';
  static String toggleLike(String id) => '$baseUrl/collections/$id/like';
  
  // Timeouts
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
}
