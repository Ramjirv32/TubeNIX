import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:my_app/config/api_config.dart';

/// Normalized SERP result used by the UI
class SerpItem {
  final String id;
  final String title;
  final String description;
  final String imageUrl;     // thumbnail or image
  final String sourceUrl;    // link to video/page
  final String channelName;
  final String duration;
  final int views;
  final String type;         // 'video' | 'image'

  SerpItem({
    required this.id,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.sourceUrl,
    required this.channelName,
    required this.duration,
    required this.views,
    required this.type,
  });

  factory SerpItem.fromMap(Map<String, dynamic> m) {
    // These keys are already normalized by your backend controllers.
    return SerpItem(
      id: (m['id'] ?? m['_id'] ?? '').toString(),
      title: (m['title'] ?? '').toString(),
      description: (m['description'] ?? '').toString(),
      imageUrl: (m['thumbnail'] ?? m['imageUrl'] ?? m['image'] ?? '').toString(),
      sourceUrl: (m['link'] ?? m['sourceUrl'] ?? '').toString(),
      channelName: (m['channel'] ?? m['channelName'] ?? '').toString(),
      duration: (m['duration'] ?? '').toString(),
      views: int.tryParse('${m['views'] ?? 0}'.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0,
      type: (m['type'] ?? 'video').toString(),
    );
  }
}

class SerpService {
  SerpService._();
  static final SerpService instance = SerpService._();

  // Allow SerpService() usage in UI code
  factory SerpService() => instance;

  final http.Client _client = http.Client();
  final String _base = ApiConfig.baseUrl; // e.g. http://localhost:5000/api

  Future<Map<String, String>> _getHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    return {
      'Content-Type': 'application/json',
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    };
  }

  List<dynamic> _extractList(String body) {
    final decoded = jsonDecode(body);
    if (decoded is List) return decoded;
    if (decoded is Map && decoded['data'] is List) return decoded['data'] as List;
    if (decoded is Map && decoded['results'] is List) return decoded['results'] as List;
    return const [];
    }

  // Trending videos
  Future<List<SerpItem>> getTrendingVideos({String query = 'trending'}) async {
    final headers = await _getHeaders();
    final uri = Uri.parse('$_base/serp/trending/videos').replace(queryParameters: {'q': query});
    try {
      final res = await _client.get(uri, headers: headers);
      if (res.statusCode == 200) {
        final list = _extractList(res.body);
        return list.map((e) => SerpItem.fromMap(e as Map<String, dynamic>)).toList();
      }
      if (res.statusCode == 401) {
        throw Exception('Not authenticated. Please log in first.');
      }
      throw Exception('Server returned ${res.statusCode}: ${res.body}');
    } catch (e) {
      // Keep console logs minimal in release
      // ignore: avoid_print
      print('Error fetching trending videos: $e');
      throw Exception('Failed to fetch trending videos: $e');
    }
  }

  // Search videos
  Future<List<SerpItem>> searchVideos(String query) async {
    final headers = await _getHeaders();
    final uri = Uri.parse('$_base/serp/search/videos').replace(queryParameters: {'q': query});
    try {
      final res = await _client.get(uri, headers: headers);
      if (res.statusCode == 200) {
        final list = _extractList(res.body);
        return list.map((e) => SerpItem.fromMap(e as Map<String, dynamic>)).toList();
      }
      if (res.statusCode == 401) {
        throw Exception('Not authenticated. Please log in first.');
      }
      throw Exception('Server returned ${res.statusCode}: ${res.body}');
    } catch (e) {
      // ignore: avoid_print
      print('Error searching videos: $e');
      throw Exception('Failed to search videos: $e');
    }
  }

  // Trending images (thumbnails/ideas)
  Future<List<SerpItem>> getTrendingImages({String query = 'youtube thumbnail ideas'}) async {
    final headers = await _getHeaders();
    final uri = Uri.parse('$_base/serp/trending/images').replace(queryParameters: {'q': query});
    try {
      final res = await _client.get(uri, headers: headers);
      if (res.statusCode == 200) {
        final list = _extractList(res.body);
        return list
            .map((e) {
              final map = (e as Map<String, dynamic>);
              map['type'] = 'image';
              return SerpItem.fromMap(map);
            })
            .toList();
      }
      if (res.statusCode == 401) {
        throw Exception('Not authenticated. Please log in first.');
      }
      throw Exception('Server returned ${res.statusCode}: ${res.body}');
    } catch (e) {
      // ignore: avoid_print
      print('Error fetching trending images: $e');
      throw Exception('Failed to fetch trending images: $e');
    }
  }

  // Search images
  Future<List<SerpItem>> searchImages(String query) async {
    final headers = await _getHeaders();
    final uri = Uri.parse('$_base/serp/search/images').replace(queryParameters: {'q': query});
    try {
      final res = await _client.get(uri, headers: headers);
      if (res.statusCode == 200) {
        final list = _extractList(res.body);
        return list
            .map((e) {
              final map = (e as Map<String, dynamic>);
              map['type'] = 'image';
              return SerpItem.fromMap(map);
            })
            .toList();
      }
      if (res.statusCode == 401) {
        throw Exception('Not authenticated. Please log in first.');
      }
      throw Exception('Server returned ${res.statusCode}: ${res.body}');
    } catch (e) {
      // ignore: avoid_print
      print('Error searching images: $e');
      throw Exception('Failed to search images: $e');
    }
  }
}

final serpService = SerpService.instance;
