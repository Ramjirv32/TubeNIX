import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';

class CollectionService {
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  Future<Map<String, String>> _getHeaders() async {
    final token = await _getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // Get collections
  Future<List<dynamic>> getCollections({String? type}) async {
    try {
      final headers = await _getHeaders();
      final url = type != null 
          ? '${ApiConfig.collections}?type=$type'
          : ApiConfig.collections;
      
      final response = await http.get(
        Uri.parse(url),
        headers: headers,
      );

      print('Get Collections Response: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        return json.decode(response.body) as List<dynamic>;
      } else {
        throw Exception('Failed to fetch collections');
      }
    } catch (e) {
      print('Error fetching collections: $e');
      throw Exception('Failed to fetch collections: $e');
    }
  }

  // Save to collection
  Future<Map<String, dynamic>> saveToCollection({
    required String title,
    String? description,
    required String imageUrl,
    String? source,
    String? type,
    Map<String, dynamic>? metadata,
    List<String>? tags,
  }) async {
    try {
      final headers = await _getHeaders();
      final body = {
        'title': title,
        'imageUrl': imageUrl,
        if (description != null) 'description': description,
        if (source != null) 'source': source,
        if (type != null) 'type': type,
        if (metadata != null) 'metadata': metadata,
        if (tags != null) 'tags': tags,
      };

      final response = await http.post(
        Uri.parse(ApiConfig.collections),
        headers: headers,
        body: json.encode(body),
      );

      print('Save to Collection Response: ${response.statusCode}');
      print('Response body: ${response.body}');
      
      if (response.statusCode == 201) {
        return json.decode(response.body);
      } else {
        final errorBody = json.decode(response.body);
        throw Exception(errorBody['message'] ?? 'Failed to save to collection');
      }
    } catch (e) {
      print('Error saving to collection: $e');
      throw Exception('Failed to save to collection: $e');
    }
  }

  // Toggle like
  Future<Map<String, dynamic>> toggleLike(String id) async {
    try {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse(ApiConfig.toggleLike(id)),
        headers: headers,
      );

      print('Toggle Like Response: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to toggle like');
      }
    } catch (e) {
      print('Error toggling like: $e');
      throw Exception('Failed to toggle like: $e');
    }
  }

  // Delete from collection
  Future<void> deleteFromCollection(String id) async {
    try {
      final headers = await _getHeaders();
      final response = await http.delete(
        Uri.parse(ApiConfig.collectionById(id)),
        headers: headers,
      );

      print('Delete from Collection Response: ${response.statusCode}');
      
      if (response.statusCode != 200) {
        throw Exception('Failed to delete from collection');
      }
    } catch (e) {
      print('Error deleting from collection: $e');
      throw Exception('Failed to delete from collection: $e');
    }
  }

  // Get collection by ID
  Future<Map<String, dynamic>> getCollectionById(String id) async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse(ApiConfig.collectionById(id)),
        headers: headers,
      );

      print('Get Collection by ID Response: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to fetch collection item');
      }
    } catch (e) {
      print('Error fetching collection item: $e');
      throw Exception('Failed to fetch collection item: $e');
    }
  }
}
