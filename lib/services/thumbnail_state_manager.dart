import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class ThumbnailGenerationState {
  final String id;
  final String prompt;
  final DateTime startedAt;
  final String status; // 'generating', 'completed', 'failed'
  final String? base64Image;
  final String? error;

  ThumbnailGenerationState({
    required this.id,
    required this.prompt,
    required this.startedAt,
    required this.status,
    this.base64Image,
    this.error,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'prompt': prompt,
        'startedAt': startedAt.toIso8601String(),
        'status': status,
        'base64Image': base64Image,
        'error': error,
      };

  factory ThumbnailGenerationState.fromJson(Map<String, dynamic> json) {
    return ThumbnailGenerationState(
      id: json['id'],
      prompt: json['prompt'],
      startedAt: DateTime.parse(json['startedAt']),
      status: json['status'],
      base64Image: json['base64Image'],
      error: json['error'],
    );
  }
}

class ThumbnailStateManager {
  static final ThumbnailStateManager _instance = ThumbnailStateManager._internal();
  factory ThumbnailStateManager() => _instance;
  ThumbnailStateManager._internal();

  static const String _stateKey = 'thumbnail_generation_states';
  final Map<String, ThumbnailGenerationState> _activeStates = {};

  /// Save state to persistent storage
  Future<void> _saveStates() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final statesJson = _activeStates.values.map((s) => s.toJson()).toList();
      await prefs.setString(_stateKey, json.encode(statesJson));
      print('💾 Saved ${_activeStates.length} thumbnail generation states');
    } catch (e) {
      print('❌ Error saving thumbnail states: $e');
    }
  }

  /// Load states from persistent storage
  Future<void> loadStates() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final statesJson = prefs.getString(_stateKey);
      
      if (statesJson != null && statesJson.isNotEmpty) {
        final List<dynamic> statesList = json.decode(statesJson);
        _activeStates.clear();
        
        for (var stateJson in statesList) {
          final state = ThumbnailGenerationState.fromJson(stateJson);
          _activeStates[state.id] = state;
        }
        
        print('✅ Loaded ${_activeStates.length} thumbnail generation states');
      }
    } catch (e) {
      print('❌ Error loading thumbnail states: $e');
    }
  }

  /// Start a new generation task
  Future<String> startGeneration(String prompt) async {
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    final state = ThumbnailGenerationState(
      id: id,
      prompt: prompt,
      startedAt: DateTime.now(),
      status: 'generating',
    );
    
    _activeStates[id] = state;
    await _saveStates();
    
    print('🎨 Started generation task: $id');
    return id;
  }

  /// Update generation state
  Future<void> updateState(String id, {
    String? status,
    String? base64Image,
    String? error,
  }) async {
    if (_activeStates.containsKey(id)) {
      final oldState = _activeStates[id]!;
      _activeStates[id] = ThumbnailGenerationState(
        id: oldState.id,
        prompt: oldState.prompt,
        startedAt: oldState.startedAt,
        status: status ?? oldState.status,
        base64Image: base64Image ?? oldState.base64Image,
        error: error ?? oldState.error,
      );
      
      await _saveStates();
      print('📝 Updated state for task: $id - Status: ${status ?? oldState.status}');
    }
  }

  /// Get state by ID
  ThumbnailGenerationState? getState(String id) {
    return _activeStates[id];
  }

  /// Get all active (generating) states
  List<ThumbnailGenerationState> getActiveStates() {
    return _activeStates.values
        .where((s) => s.status == 'generating')
        .toList();
  }

  /// Get all completed states
  List<ThumbnailGenerationState> getCompletedStates() {
    return _activeStates.values
        .where((s) => s.status == 'completed')
        .toList();
  }

  /// Remove a state
  Future<void> removeState(String id) async {
    _activeStates.remove(id);
    await _saveStates();
    print('🗑️ Removed state: $id');
  }

  /// Clear all states
  Future<void> clearAll() async {
    _activeStates.clear();
    await _saveStates();
    print('🗑️ Cleared all thumbnail generation states');
  }

  /// Clear completed or failed states (keep only generating)
  Future<void> clearCompletedStates() async {
    _activeStates.removeWhere((key, value) => 
      value.status == 'completed' || value.status == 'failed'
    );
    await _saveStates();
    print('🗑️ Cleared completed/failed states');
  }
}

final thumbnailStateManager = ThumbnailStateManager();
