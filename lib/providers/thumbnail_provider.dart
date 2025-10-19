import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/thumbnail_model.dart';

class ThumbnailProvider extends ChangeNotifier {
  static const String _storageKey = 'tubenix_thumbnails_v1';

  List<ThumbnailModel> _thumbnails = [];

  List<ThumbnailModel> get thumbnails => List.unmodifiable(_thumbnails);

  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;
    _initialized = true;
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_storageKey);
    if (raw != null) {
      try {
        final list = json.decode(raw) as List<dynamic>;
        _thumbnails = list
            .map((e) => ThumbnailModel.fromJson(e as Map<String, dynamic>))
            .toList();
      } catch (_) {
        _thumbnails = DummyData.getThumbnails();
      }
    } else {
      _thumbnails = DummyData.getThumbnails();
    }
    notifyListeners();
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = json.encode(_thumbnails.map((e) => e.toJson()).toList());
    await prefs.setString(_storageKey, raw);
  }

  void addThumbnail(ThumbnailModel thumbnail) {
    _thumbnails.insert(0, thumbnail);
    _save();
    notifyListeners();
  }

  void removeThumbnail(int index) {
    if (index >= 0 && index < _thumbnails.length) {
      _thumbnails.removeAt(index);
      _save();
      notifyListeners();
    }
  }

  void removeThumbnailById(String id) {
    _thumbnails.removeWhere((t) => t.id == id);
    _save();
    notifyListeners();
  }

  void replaceAll(List<ThumbnailModel> items) {
    _thumbnails = List.from(items);
    _save();
    notifyListeners();
  }

  void clear() {
    _thumbnails.clear();
    _save();
    notifyListeners();
  }
}
