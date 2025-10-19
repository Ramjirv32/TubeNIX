import 'thumbnail_model.dart';

/// Trending Thumbnail Model
/// Represents a thumbnail from all users with engagement metrics
class TrendingThumbnail extends ThumbnailModel {
  final String creatorName;
  final String creatorAvatar;
  final int views;
  final int likes;
  final int saves;
  final int downloads;
  final bool isLiked;
  final bool isSaved;

  TrendingThumbnail({
    required super.id,
    required super.title,
    required super.imageUrl,
    required super.dateCreated,
    required super.ctrPercentage,
    required this.creatorName,
    required this.creatorAvatar,
    required this.views,
    required this.likes,
    required this.saves,
    required this.downloads,
    this.isLiked = false,
    this.isSaved = false,
  });

  // Calculate engagement score
  int get engagementScore => (views * 1) + (likes * 5) + (saves * 3) + (downloads * 4);

  TrendingThumbnail copyWith({
    bool? isLiked,
    bool? isSaved,
    int? likes,
    int? saves,
  }) {
    return TrendingThumbnail(
      id: id,
      title: title,
      imageUrl: imageUrl,
      dateCreated: dateCreated,
      ctrPercentage: ctrPercentage,
      creatorName: creatorName,
      creatorAvatar: creatorAvatar,
      views: views,
      likes: likes ?? this.likes,
      saves: saves ?? this.saves,
      downloads: downloads,
      isLiked: isLiked ?? this.isLiked,
      isSaved: isSaved ?? this.isSaved,
    );
  }
}

/// Dummy data for trending thumbnails
class TrendingData {
  static List<TrendingThumbnail> getTrending() {
    final creators = [
      {'name': 'Sarah Johnson', 'avatar': 'S'},
      {'name': 'Mike Chen', 'avatar': 'M'},
      {'name': 'Emma Davis', 'avatar': 'E'},
      {'name': 'Alex Kumar', 'avatar': 'A'},
      {'name': 'Lisa Brown', 'avatar': 'L'},
      {'name': 'David Wilson', 'avatar': 'D'},
      {'name': 'Nina Patel', 'avatar': 'N'},
      {'name': 'James Taylor', 'avatar': 'J'},
    ];

    return [
      TrendingThumbnail(
        id: 't1',
        title: '10 Secrets to Viral YouTube Thumbnails',
        imageUrl: 'color_red',
        dateCreated: DateTime.now().subtract(const Duration(hours: 2)),
        ctrPercentage: 18.5,
        creatorName: creators[0]['name']!,
        creatorAvatar: creators[0]['avatar']!,
        views: 15420,
        likes: 3420,
        saves: 890,
        downloads: 1240,
      ),
      TrendingThumbnail(
        id: 't2',
        title: 'Best Color Combinations for 2024',
        imageUrl: 'color_blue',
        dateCreated: DateTime.now().subtract(const Duration(hours: 5)),
        ctrPercentage: 16.2,
        creatorName: creators[1]['name']!,
        creatorAvatar: creators[1]['avatar']!,
        views: 12340,
        likes: 2890,
        saves: 720,
        downloads: 980,
      ),
      TrendingThumbnail(
        id: 't3',
        title: 'Thumbnail Psychology Explained',
        imageUrl: 'color_green',
        dateCreated: DateTime.now().subtract(const Duration(hours: 8)),
        ctrPercentage: 19.8,
        creatorName: creators[2]['name']!,
        creatorAvatar: creators[2]['avatar']!,
        views: 18900,
        likes: 4120,
        saves: 1200,
        downloads: 1580,
      ),
      TrendingThumbnail(
        id: 't4',
        title: 'AI-Generated Thumbnails Guide',
        imageUrl: 'color_orange',
        dateCreated: DateTime.now().subtract(const Duration(hours: 12)),
        ctrPercentage: 15.7,
        creatorName: creators[3]['name']!,
        creatorAvatar: creators[3]['avatar']!,
        views: 9820,
        likes: 2340,
        saves: 560,
        downloads: 780,
      ),
      TrendingThumbnail(
        id: 't5',
        title: 'Typography Tips for YouTube',
        imageUrl: 'color_purple',
        dateCreated: DateTime.now().subtract(const Duration(hours: 18)),
        ctrPercentage: 14.3,
        creatorName: creators[4]['name']!,
        creatorAvatar: creators[4]['avatar']!,
        views: 11240,
        likes: 2670,
        saves: 640,
        downloads: 890,
      ),
      TrendingThumbnail(
        id: 't6',
        title: 'Face Expressions That Sell',
        imageUrl: 'color_teal',
        dateCreated: DateTime.now().subtract(const Duration(days: 1)),
        ctrPercentage: 17.9,
        creatorName: creators[5]['name']!,
        creatorAvatar: creators[5]['avatar']!,
        views: 14560,
        likes: 3340,
        saves: 920,
        downloads: 1190,
      ),
      TrendingThumbnail(
        id: 't7',
        title: 'Contrast & Clarity Masterclass',
        imageUrl: 'color_pink',
        dateCreated: DateTime.now().subtract(const Duration(days: 1, hours: 6)),
        ctrPercentage: 13.8,
        creatorName: creators[6]['name']!,
        creatorAvatar: creators[6]['avatar']!,
        views: 8940,
        likes: 2120,
        saves: 510,
        downloads: 670,
      ),
      TrendingThumbnail(
        id: 't8',
        title: 'Mobile Optimization Tips',
        imageUrl: 'color_amber',
        dateCreated: DateTime.now().subtract(const Duration(days: 2)),
        ctrPercentage: 16.5,
        creatorName: creators[7]['name']!,
        creatorAvatar: creators[7]['avatar']!,
        views: 13120,
        likes: 3010,
        saves: 810,
        downloads: 1050,
      ),
    ];
  }
}
