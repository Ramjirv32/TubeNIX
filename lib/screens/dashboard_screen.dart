import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../widgets/stat_card.dart';
import '../widgets/thumbnail_card.dart';
import '../providers/thumbnail_provider.dart';
import '../models/thumbnail_model.dart';

/// Dashboard Screen - Main home screen showing statistics and thumbnails
class DashboardScreen extends StatefulWidget {
  final String userName;

  const DashboardScreen({super.key, required this.userName});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentIndex = 0;
  final TextEditingController _searchController = TextEditingController();
  bool _isLoading = false;
  @override
  void initState() {
    super.initState();
  }

  Future<void> _handleRefresh() async {
    // Simulate refresh delay and reinitialize provider
    final provider = context.read<ThumbnailProvider>();
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(seconds: 1));
    await provider.init();
    if (!mounted) return;
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
  final provider = context.watch<ThumbnailProvider>();
  final thumbnails = provider.thumbnails;

  // Calculate statistics
  int totalThumbnails = thumbnails.length;
  int totalVideos = (totalThumbnails * 1.5).round();
  int trendingKeywords = (totalThumbnails * 8.3).round();
  double avgCTR = thumbnails.isEmpty
    ? 0
    : thumbnails.map((t) => t.ctrPercentage).reduce((a, b) => a + b) /
      thumbnails.length;

    return Scaffold(
      appBar: _buildAppBar(),
      body: RefreshIndicator(
        onRefresh: _handleRefresh,
        color: const Color(0xFFFF0000),
    child: _currentIndex == 0
      ? _buildHomeContent(
        totalThumbnails,
        totalVideos,
        trendingKeywords,
        avgCTR,
        thumbnails,
        provider,
        )
            : _buildOtherContent(),
      ),
      floatingActionButton: _currentIndex == 0
          ? FloatingActionButton(
              onPressed: () {
                _showAddThumbnailDialog();
              },
              backgroundColor: const Color(0xFFFF0000),
              child: const Icon(Icons.add, color: Colors.white),
            )
          : null,
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: const Color(0xFF1E1E1E),
      elevation: 0,
      title: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFFF0000), Color(0xFFFF6B00)],
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.play_circle_filled,
                color: Colors.white, size: 24),
          ),
          const SizedBox(width: 10),
          const Text(
            'TubeNix',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.notifications_outlined),
          onPressed: () {},
        ),
        Padding(
          padding: const EdgeInsets.only(right: 8.0),
          child: CircleAvatar(
            backgroundColor: const Color(0xFFFF6B00),
            child: Text(
              widget.userName[0].toUpperCase(),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHomeContent(
    int totalThumbnails,
    int totalVideos,
    int trendingKeywords,
    double avgCTR,
    List<ThumbnailModel> thumbnails,
    ThumbnailProvider provider,
  ) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Message
            Text(
              'Welcome back, ${widget.userName}!',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 20),

            // Statistics Cards
            Row(
              children: [
                Expanded(
                  child: StatCard(
                    title: 'Thumbnails',
                    value: totalThumbnails.toString(),
                    icon: Icons.image,
                    color: const Color(0xFFFF0000),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: StatCard(
                    title: 'Videos',
                    value: totalVideos.toString(),
                    icon: Icons.play_circle_filled,
                    color: const Color(0xFFFF6B00),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: StatCard(
                    title: 'Keywords',
                    value: trendingKeywords.toString(),
                    icon: Icons.trending_up,
                    color: const Color(0xFF9C27B0),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: StatCard(
                    title: 'Avg CTR',
                    value: '${avgCTR.toStringAsFixed(1)}%',
                    icon: Icons.analytics,
                    color: const Color(0xFF00BCD4),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),

            // Search Bar
            TextField(
              controller: _searchController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Search thumbnails...',
                hintStyle: const TextStyle(color: Colors.grey),
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.filter_list, color: Colors.grey),
                  onPressed: () {},
                ),
                filled: true,
                fillColor: const Color(0xFF1E1E1E),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Section Title
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Your Generated Thumbnails',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  'View All',
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFFFF6B00),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Thumbnails Grid
            _isLoading
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32.0),
                      child: CircularProgressIndicator(
                        color: Color(0xFFFF0000),
                      ),
                    ),
                  )
                : thumbnails.isEmpty
                    ? _buildEmptyState()
                    : GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 0.75,
                        ),
                        itemCount: thumbnails.length,
                        itemBuilder: (context, index) {
                          return ThumbnailCard(
                            thumbnail: thumbnails[index],
                            onDelete: () => provider.removeThumbnailById(
                                thumbnails[index].id),
                          );
                        },
                      ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.image_not_supported_outlined,
              size: 80,
              color: Colors.grey[700],
            ),
            const SizedBox(height: 16),
            Text(
              'No Thumbnails Yet',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tap the + button to create your first thumbnail',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[700],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOtherContent() {
    String title = '';
    IconData icon = Icons.home;

    switch (_currentIndex) {
      case 1:
        title = 'Thumbnails';
        icon = Icons.image;
        break;
      case 2:
        title = 'Analytics';
        icon = Icons.analytics;
        break;
      case 3:
        title = 'Profile';
        icon = Icons.person;
        break;
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 80, color: Colors.grey[700]),
          const SizedBox(height: 16),
          Text(
            '$title Screen',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Coming Soon',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF1E1E1E),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 10,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        backgroundColor: Colors.transparent,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFFFF0000),
        unselectedItemColor: Colors.grey,
        elevation: 0,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.image_outlined),
            activeIcon: Icon(Icons.image),
            label: 'Thumbnails',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.analytics_outlined),
            activeIcon: Icon(Icons.analytics),
            label: 'Analytics',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  void _showAddThumbnailDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        title: const Text(
          'Generate Thumbnail',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'This feature will allow you to generate new thumbnails using AI.',
          style: TextStyle(color: Colors.grey),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Colors.grey),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Coming Soon!')),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF0000),
            ),
            child: const Text(
              'Generate',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
