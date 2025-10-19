/// Thumbnail Model
/// Represents a generated thumbnail with its metadata
class ThumbnailModel {
  final String id;
  final String title;
  final String imageUrl;
  final DateTime dateCreated;
  final double ctrPercentage;

  ThumbnailModel({
    required this.id,
    required this.title,
    required this.imageUrl,
    required this.dateCreated,
    required this.ctrPercentage,
  });

  // Format date for display
  String get formattedDate {
    final now = DateTime.now();
    final difference = now.difference(dateCreated);

    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${dateCreated.day}/${dateCreated.month}/${dateCreated.year}';
    }
  }

  /// Convert to JSON for persistence
  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'imageUrl': imageUrl,
        'dateCreated': dateCreated.toIso8601String(),
        'ctrPercentage': ctrPercentage,
      };

  /// Create model from JSON
  factory ThumbnailModel.fromJson(Map<String, dynamic> json) {
    return ThumbnailModel(
      id: json['id'] as String,
      title: json['title'] as String,
      imageUrl: json['imageUrl'] as String,
      dateCreated: DateTime.parse(json['dateCreated'] as String),
      ctrPercentage: (json['ctrPercentage'] as num).toDouble(),
    );
  }
}

/// Dummy data generator for thumbnails
class DummyData {
  static List<ThumbnailModel> getThumbnails() {
    return [
      ThumbnailModel(
        id: '1',
        title: 'How to Grow YouTube Channel Fast',
        imageUrl: 'color_red',
        dateCreated: DateTime.now().subtract(const Duration(days: 1)),
        ctrPercentage: 12.5,
      ),
      ThumbnailModel(
        id: '2',
        title: 'Best SEO Tips for 2024',
        imageUrl: 'color_blue',
        dateCreated: DateTime.now().subtract(const Duration(days: 2)),
        ctrPercentage: 9.8,
      ),
      ThumbnailModel(
        id: '3',
        title: 'Content Strategy That Works',
        imageUrl: 'color_green',
        dateCreated: DateTime.now().subtract(const Duration(days: 3)),
        ctrPercentage: 14.2,
      ),
      ThumbnailModel(
        id: '4',
        title: 'Viral Video Ideas 2024',
        imageUrl: 'color_orange',
        dateCreated: DateTime.now().subtract(const Duration(days: 4)),
        ctrPercentage: 11.7,
      ),
      ThumbnailModel(
        id: '5',
        title: 'YouTube Algorithm Explained',
        imageUrl: 'color_purple',
        dateCreated: DateTime.now().subtract(const Duration(days: 5)),
        ctrPercentage: 8.3,
      ),
      ThumbnailModel(
        id: '6',
        title: 'Thumbnail Design Secrets',
        imageUrl: 'color_teal',
        dateCreated: DateTime.now().subtract(const Duration(days: 6)),
        ctrPercentage: 13.9,
      ),
      ThumbnailModel(
        id: '7',
        title: 'Monetization Strategies',
        imageUrl: 'color_pink',
        dateCreated: DateTime.now().subtract(const Duration(days: 7)),
        ctrPercentage: 10.5,
      ),
      ThumbnailModel(
        id: '8',
        title: 'Audience Retention Tips',
        imageUrl: 'color_amber',
        dateCreated: DateTime.now(),
        ctrPercentage: 15.1,
      ),
    ];
  }
}
