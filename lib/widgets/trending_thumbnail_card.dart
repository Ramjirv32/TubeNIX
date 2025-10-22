import 'package:flutter/material.dart';
import '../models/trending_thumbnail_model.dart';

/// Trending Thumbnail Card
/// Displays a trending thumbnail with engagement buttons
class TrendingThumbnailCard extends StatelessWidget {
  final TrendingThumbnail thumbnail;
  final VoidCallback onLike;
  final VoidCallback onSave;
  final VoidCallback onDownload;

  const TrendingThumbnailCard({
    super.key,
    required this.thumbnail,
    required this.onLike,
    required this.onSave,
    required this.onDownload,
  });

  Color _getColorFromString(String colorString) {
    switch (colorString) {
      case 'color_red':
        return Colors.red;
      case 'color_blue':
        return Colors.blue;
      case 'color_green':
        return Colors.green;
      case 'color_orange':
        return Colors.orange;
      case 'color_purple':
        return Colors.purple;
      case 'color_teal':
        return Colors.teal;
      case 'color_pink':
        return Colors.pink;
      case 'color_amber':
        return Colors.amber;
      default:
        return Colors.grey;
    }
  }

  String _formatNumber(int number) {
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    }
    return number.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Thumbnail Image
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            child: Stack(
              children: [
                Container(
                  height: 120,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        _getColorFromString(thumbnail.imageUrl),
                        _getColorFromString(thumbnail.imageUrl).withOpacity(0.7),
                      ],
                    ),
                  ),
                  child: Center(
                    child: Icon(
                      Icons.play_circle_outline,
                      size: 50,
                      color: Colors.white.withOpacity(0.8),
                    ),
                  ),
                ),
                // CTR Badge
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${thumbnail.ctrPercentage.toStringAsFixed(1)}% CTR',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                // Views Badge
                Positioned(
                  top: 8,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.visibility, color: Colors.white, size: 12),
                        const SizedBox(width: 4),
                        Text(
                          _formatNumber(thumbnail.views),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Content
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Title
                Text(
                  thumbnail.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),

                // Creator
                Row(
                  children: [
                    CircleAvatar(
                      radius: 10,
                      backgroundColor: const Color(0xFFFF6B00),
                      child: Text(
                        thumbnail.creatorAvatar,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        thumbnail.creatorName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.black54,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),

                // Engagement Stats
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildStatItem(Icons.thumb_up_outlined, _formatNumber(thumbnail.likes)),
                    _buildStatItem(Icons.bookmark_outline, _formatNumber(thumbnail.saves)),
                    _buildStatItem(Icons.download_outlined, _formatNumber(thumbnail.downloads)),
                  ],
                ),
                const SizedBox(height: 6),

                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: _buildActionButton(
                        icon: thumbnail.isLiked ? Icons.thumb_up : Icons.thumb_up_outlined,
                        color: thumbnail.isLiked ? const Color(0xFFFF0000) : Colors.grey,
                        onTap: onLike,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildActionButton(
                        icon: thumbnail.isSaved ? Icons.bookmark : Icons.bookmark_outline,
                        color: thumbnail.isSaved ? const Color(0xFFFF6B00) : Colors.grey,
                        onTap: onSave,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildActionButton(
                        icon: Icons.download_outlined,
                        color: Colors.grey,
                        onTap: onDownload,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String value) {
    return Row(
      children: [
        Icon(icon, size: 12, color: Colors.grey),
        const SizedBox(width: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 11,
            color: Colors.grey,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 6),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          size: 18,
          color: color,
        ),
      ),
    );
  }
}
