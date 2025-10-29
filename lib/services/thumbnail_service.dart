import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';
import 'thumbnail_state_manager.dart';

class ThumbnailService {
  static final ThumbnailService _instance = ThumbnailService._internal();
  factory ThumbnailService() => _instance;
  ThumbnailService._internal();

  final http.Client _client = http.Client();
  
  // API key should be configured in backend, not exposed in frontend
  static const String huggingFaceModel = 'https://api-inference.huggingface.co/models/black-forest-labs/FLUX.1-dev';

  Future<Map<String, String>> _getHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    return {
      'Content-Type': 'application/json',
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    };
  }

  Future<ThumbnailResult> generateThumbnail({
    required String prompt,
    bool saveToCollection = false,
    bool makePublic = false,
  }) async {
    final stateId = await thumbnailStateManager.startGeneration(prompt);
    
    try {
      print('🎨 Generating thumbnail: $prompt');
      
      final headers = await _getHeaders();
      final uri = Uri.parse('${ApiConfig.baseUrl}/thumbnails/generate');
      
      final body = json.encode({
        'prompt': prompt,
        'saveToCollection': saveToCollection,
        'makePublic': makePublic,
      });

      final response = await _client.post(uri, headers: headers, body: body);

      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        final result = ThumbnailResult.fromJson(data['data']);
        
        await thumbnailStateManager.updateState(
          stateId,
          status: 'completed',
          base64Image: result.base64,
        );
        
        print('✅ Thumbnail generated successfully');
        return result;
      } else if (response.statusCode == 401) {
        print('⚠️ Not authenticated, using direct Hugging Face API');
        return await _generateWithHuggingFace(prompt, stateId);
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to generate thumbnail');
      }
    } catch (e) {
      print('❌ Error generating thumbnail: $e');
      
      await thumbnailStateManager.updateState(
        stateId,
        status: 'failed',
        error: e.toString(),
      );
      
      try {
        return await _generateWithHuggingFace(prompt, stateId);
      } catch (fallbackError) {
        throw Exception('Failed to generate thumbnail: $e');
      }
    }
  }

  Future<ThumbnailResult> _generateWithHuggingFace(String prompt, String stateId) async {
    // Fallback: try to use the backend demo endpoint that doesn't require auth
    try {
      print('🤗 Using backend demo endpoint as fallback');
      
      final uri = Uri.parse('${ApiConfig.baseUrl}/thumbnails/generate-demo');
      final response = await _client.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'prompt': prompt}),
      );

      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        final result = ThumbnailResult.fromJson(data['data']);
        
        await thumbnailStateManager.updateState(
          stateId,
          status: 'completed',
          base64Image: result.base64,
        );
        
        print('✅ Generated with backend demo endpoint');
        return result;
      } else {
        throw Exception('HTTP error! status: ${response.statusCode}');
      }
    } catch (e) {
      await thumbnailStateManager.updateState(
        stateId,
        status: 'failed',
        error: e.toString(),
      );
      rethrow;
    }
  }

  Future<ThumbnailResult> generateThumbnailDemo({
    required String prompt,
  }) async {
    try {
      final uri = Uri.parse('${ApiConfig.baseUrl}/thumbnails/generate-demo');
      
      final body = json.encode({'prompt': prompt});

      final response = await _client.post(
        uri, 
        headers: {'Content-Type': 'application/json'}, 
        body: body
      );

      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        return ThumbnailResult.fromJson(data['data']);
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to generate demo thumbnail');
      }
    } catch (e) {
      print('Error generating demo thumbnail: $e');
      throw Exception('Failed to generate demo thumbnail: $e');
    }
  }

  Future<List<ThumbnailResult>> generateMultipleThumbnails({
    required String prompt,
    int count = 3,
    bool saveToCollection = false,
    bool makePublic = false,
  }) async {
    try {
      final headers = await _getHeaders();
      final uri = Uri.parse('${ApiConfig.baseUrl}/thumbnails/generate-multiple');
      
      final body = json.encode({
        'prompt': prompt,
        'count': count,
        'saveToCollection': saveToCollection,
        'makePublic': makePublic,
      });

      final response = await _client.post(uri, headers: headers, body: body);

      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        final thumbnailsData = data['data']['thumbnails'] as List;
        return thumbnailsData.map((t) => ThumbnailResult.fromJson(t)).toList();
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to generate thumbnails');
      }
    } catch (e) {
      print('Error generating multiple thumbnails: $e');
      throw Exception('Failed to generate multiple thumbnails: $e');
    }
  }

  Future<List<UserThumbnail>> getUserThumbnails() async {
    try {
      final headers = await _getHeaders();
      final uri = Uri.parse('${ApiConfig.baseUrl}/thumbnails/my-thumbnails');

      final response = await _client.get(uri, headers: headers);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final thumbnailsData = data['data']['thumbnails'] as List;
        return thumbnailsData.map((t) => UserThumbnail.fromJson(t)).toList();
      } else if (response.statusCode == 401) {
        throw Exception('Authentication required. Please log in.');
      } else {
        throw Exception('Failed to get user thumbnails');
      }
    } catch (e) {
      print('Error getting user thumbnails: $e');
      throw Exception('Failed to get user thumbnails: $e');
    }
  }

  Future<List<UserThumbnail>> getPublicThumbnails({int limit = 20, int skip = 0}) async {
    try {
      final uri = Uri.parse('${ApiConfig.baseUrl}/thumbnails/public?limit=$limit&skip=$skip');

      final response = await _client.get(uri);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final thumbnailsData = data['data'] as List;
        return thumbnailsData.map((t) => UserThumbnail.fromJson(t)).toList();
      } else {
        throw Exception('Failed to get public thumbnails');
      }
    } catch (e) {
      print('Error getting public thumbnails: $e');
      throw Exception('Failed to get public thumbnails: $e');
    }
  }

  Future<Uint8List> downloadThumbnail(String thumbnailId) async {
    try {
      final headers = await _getHeaders();
      final uri = Uri.parse('${ApiConfig.baseUrl}/thumbnails/$thumbnailId/download');

      final response = await _client.get(uri, headers: headers);

      if (response.statusCode == 200) {
        return response.bodyBytes;
      } else if (response.statusCode == 401) {
        throw Exception('Authentication required. Please log in.');
      } else if (response.statusCode == 404) {
        throw Exception('Thumbnail not found.');
      } else {
        throw Exception('Failed to download thumbnail');
      }
    } catch (e) {
      print('Error downloading thumbnail: $e');
      throw Exception('Failed to download thumbnail: $e');
    }
  }

  Future<bool> toggleThumbnailPublic(String thumbnailId) async {
    try {
      final headers = await _getHeaders();
      final uri = Uri.parse('${ApiConfig.baseUrl}/thumbnails/$thumbnailId/toggle-public');

      final response = await _client.patch(uri, headers: headers);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['data']['isPublic'] ?? false;
      } else if (response.statusCode == 401) {
        throw Exception('Authentication required. Please log in.');
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to toggle public status');
      }
    } catch (e) {
      print('Error toggling public status: $e');
      throw Exception('Failed to toggle public status: $e');
    }
  }

  void dispose() {
    _client.close();
  }
}

class ThumbnailResult {
  final String id;
  final String base64;
  final String prompt;
  final String? enhancedPrompt;
  final String size;
  final bool isPublic;
  final bool savedToCollection;
  final DateTime createdAt;
  final int? variation;

  ThumbnailResult({
    required this.id,
    required this.base64,
    required this.prompt,
    this.enhancedPrompt,
    required this.size,
    this.isPublic = false,
    this.savedToCollection = false,
    required this.createdAt,
    this.variation,
  });

  factory ThumbnailResult.fromJson(Map<String, dynamic> json) {
    return ThumbnailResult(
      id: json['id']?.toString() ?? '',
      base64: json['base64']?.toString() ?? '',
      prompt: json['prompt']?.toString() ?? '',
      enhancedPrompt: json['enhancedPrompt']?.toString(),
      size: json['size']?.toString() ?? '',
      isPublic: json['isPublic'] == true,
      savedToCollection: json['savedToCollection'] == true,
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? '') ?? DateTime.now(),
      variation: json['variation'] as int?,
    );
  }

  Uint8List get imageBytes => base64Decode(base64);
  String get dataUrl => 'data:image/png;base64,$base64';
}

class UserThumbnail {
  final String id;
  final String userEmail;
  final String prompt;
  final String originalPrompt;
  final String imageSize;
  final String? textResponse;
  final bool isPublic;
  final bool isDownloaded;
  final int downloadCount;
  final int likes;
  final List<String> tags;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int? variation;

  UserThumbnail({
    required this.id,
    required this.userEmail,
    required this.prompt,
    required this.originalPrompt,
    required this.imageSize,
    this.textResponse,
    required this.isPublic,
    required this.isDownloaded,
    required this.downloadCount,
    required this.likes,
    required this.tags,
    required this.createdAt,
    required this.updatedAt,
    this.variation,
  });

  factory UserThumbnail.fromJson(Map<String, dynamic> json) {
    return UserThumbnail(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      userEmail: json['userEmail']?.toString() ?? '',
      prompt: json['prompt']?.toString() ?? '',
      originalPrompt: json['originalPrompt']?.toString() ?? '',
      imageSize: json['imageSize']?.toString() ?? '',
      textResponse: json['textResponse']?.toString(),
      isPublic: json['isPublic'] == true,
      isDownloaded: json['isDownloaded'] == true,
      downloadCount: (json['downloadCount'] as num?)?.toInt() ?? 0,
      likes: (json['likes'] as num?)?.toInt() ?? 0,
      tags: (json['tags'] as List?)?.map((e) => e.toString()).toList() ?? [],
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updatedAt']?.toString() ?? '') ?? DateTime.now(),
      variation: json['metadata']?['variation'] as int?,
    );
  }
}

final thumbnailService = ThumbnailService();
