import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

import '../models/trending_thumbnail_model.dart';
import '../widgets/trending_thumbnail_card.dart';
import 'ai_chat_screen.dart';
import 'my_thumbnails_screen.dart';
import 'analytics_screen.dart';
import 'settings_screen.dart';
import 'trending_chat_screen.dart';

/// New Dashboard - Shows trending thumbnails from all users with charts
class NewDashboardScreen extends StatefulWidget {
  const NewDashboardScreen({super.key});

  @override
  State<NewDashboardScreen> createState() => _NewDashboardScreenState();
}

class _NewDashboardScreenState extends State<NewDashboardScreen> 
    with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  List<TrendingThumbnail> _trendingThumbnails = [];
  String _sortBy = 'views'; // views, likes, saves, downloads
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  late AnimationController _chartAnimationController;
  late Animation<double> _chartAnimation;
  bool _isGenerating = false;

  @override
  void initState() {
    super.initState();
    _chartAnimationController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    _chartAnimation = CurvedAnimation(
      parent: _chartAnimationController,
      curve: Curves.easeOutCubic,
    );
    _loadTrendingThumbnails();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.toLowerCase();
      });
    });
    // Start chart animation
    Future.delayed(const Duration(milliseconds: 300), () {
      _chartAnimationController.forward();
    });
  }

  void _loadTrendingThumbnails() {
    setState(() {
      _trendingThumbnails = TrendingData.getTrending();
      _sortThumbnails();
    });
  }

  void _sortThumbnails() {
    setState(() {
      switch (_sortBy) {
        case 'views':
          _trendingThumbnails.sort((a, b) => b.views.compareTo(a.views));
          break;
        case 'likes':
          _trendingThumbnails.sort((a, b) => b.likes.compareTo(a.likes));
          break;
        case 'saves':
          _trendingThumbnails.sort((a, b) => b.saves.compareTo(a.saves));
          break;
        case 'downloads':
          _trendingThumbnails.sort((a, b) => b.downloads.compareTo(a.downloads));
          break;
      }
    });
  }

  List<TrendingThumbnail> get _filteredThumbnails {
    if (_searchQuery.isEmpty) return _trendingThumbnails;
    return _trendingThumbnails
        .where((t) => t.title.toLowerCase().contains(_searchQuery) ||
            t.creatorName.toLowerCase().contains(_searchQuery))
        .toList();
  }

  void _toggleLike(String id) {
    setState(() {
      final index = _trendingThumbnails.indexWhere((t) => t.id == id);
      if (index != -1) {
        final thumbnail = _trendingThumbnails[index];
        _trendingThumbnails[index] = thumbnail.copyWith(
          isLiked: !thumbnail.isLiked,
          likes: thumbnail.isLiked ? thumbnail.likes - 1 : thumbnail.likes + 1,
        );
      }
    });
  }

  void _toggleSave(String id) {
    setState(() {
      final index = _trendingThumbnails.indexWhere((t) => t.id == id);
      if (index != -1) {
        final thumbnail = _trendingThumbnails[index];
        _trendingThumbnails[index] = thumbnail.copyWith(
          isSaved: !thumbnail.isSaved,
          saves: thumbnail.isSaved ? thumbnail.saves - 1 : thumbnail.saves + 1,
        );
        
        if (!thumbnail.isSaved) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Saved to your collection')),
          );
        }
      }
    });
  }

  void _download(String id) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Downloading thumbnail...')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(),
      body: _currentIndex == 0
          ? _buildHomeContent()
          : _buildOtherScreens(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _isGenerating ? null : () async {
          setState(() {
            _isGenerating = true;
          });
          
          // Simulate generation process
          await Future.delayed(const Duration(seconds: 2));
          
          if (!mounted) return;
          
          setState(() {
            _isGenerating = false;
          });
          
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AIChatScreen()),
          );
        },
        backgroundColor: _isGenerating ? Colors.grey : const Color(0xFFFF0000),
        icon: _isGenerating 
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : const Icon(Icons.add, color: Colors.white),
        label: Text(
          _isGenerating ? 'Generating...' : 'Generate',
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 1,
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
            child: const Icon(Icons.play_circle_filled, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 10),
          const Text(
            'TubeNix',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
              color: Colors.black,
            ),
          ),
        ],
      ),
      actions: [
        // Trending Chat Search Button
        Container(
          margin: const EdgeInsets.only(right: 8),
          child: IconButton(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFFF0000), Color(0xFFFF6B00)],
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.trending_up, color: Colors.white, size: 20),
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const TrendingChatScreen(),
                ),
              );
            },
            tooltip: 'Explore Trending Content',
          ),
        ),
        IconButton(
          icon: const Icon(Icons.notifications_outlined, color: Colors.black),
          onPressed: () {},
        ),
        Padding(
          padding: const EdgeInsets.only(right: 8.0),
          child: GestureDetector(
            onTap: () {
              setState(() => _currentIndex = 3);
            },
            child: const CircleAvatar(
              backgroundColor: Color(0xFFFF6B00),
              child: Icon(Icons.person, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHomeContent() {
    return RefreshIndicator(
      onRefresh: () async {
        await Future.delayed(const Duration(seconds: 1));
        _loadTrendingThumbnails();
      },
      color: const Color(0xFFFF0000),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Section
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFFFF0000).withOpacity(0.1),
                    const Color(0xFFFF6B00).withOpacity(0.05),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Welcome, Creator!',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Discover trending thumbnails from creators',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
            ),

            // Charts Section
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Engagement Overview',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 200,
                    child: _buildBarChart(),
                  ),
                ],
              ),
            ),

            // Search & Sort
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                children: [
                  TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search thumbnails or creators...',
                      hintStyle: const TextStyle(color: Colors.grey),
                      prefixIcon: const Icon(Icons.search, color: Colors.grey),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear, color: Colors.grey),
                              onPressed: () {
                                _searchController.clear();
                              },
                            )
                          : null,
                      filled: true,
                      fillColor: const Color(0xFFF5F5F5),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Text(
                        'Sort by:',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(width: 12),
                      _buildSortChip('views', 'Views'),
                      const SizedBox(width: 8),
                      _buildSortChip('likes', 'Likes'),
                      const SizedBox(width: 8),
                      _buildSortChip('saves', 'Saved'),
                      const SizedBox(width: 8),
                      _buildSortChip('downloads', 'Downloads'),
                    ],
                  ),
                ],
              ),
            ),

            // Trending Thumbnails
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Trending Thumbnails',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      Icon(Icons.local_fire_department, color: Color(0xFFFF6B00)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _filteredThumbnails.isEmpty
                      ? const Center(
                          child: Padding(
                            padding: EdgeInsets.all(32.0),
                            child: Text(
                              'No thumbnails found',
                              style: TextStyle(color: Colors.grey),
                            ),
                          ),
                        )
                      : GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            childAspectRatio: 0.68,
                          ),
                          itemCount: _filteredThumbnails.length,
                          itemBuilder: (context, index) {
                            return TrendingThumbnailCard(
                              thumbnail: _filteredThumbnails[index],
                              onLike: () => _toggleLike(_filteredThumbnails[index].id),
                              onSave: () => _toggleSave(_filteredThumbnails[index].id),
                              onDownload: () => _download(_filteredThumbnails[index].id),
                            );
                          },
                        ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSortChip(String value, String label) {
    final isSelected = _sortBy == value;
    return GestureDetector(
      onTap: () {
        setState(() {
          _sortBy = value;
          _sortThumbnails();
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          gradient: isSelected
              ? const LinearGradient(colors: [Color(0xFFFF0000), Color(0xFFFF6B00)])
              : null,
          color: isSelected ? null : const Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black87,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  Widget _buildBarChart() {
    final topThumbnails = _trendingThumbnails.take(5).toList();
    
    return AnimatedBuilder(
      animation: _chartAnimation,
      builder: (context, child) {
        return BarChart(
          BarChartData(
            alignment: BarChartAlignment.spaceAround,
            maxY: topThumbnails.map((t) => t.views.toDouble()).reduce((a, b) => a > b ? a : b) * 1.2,
            barTouchData: BarTouchData(
              enabled: true,
              touchTooltipData: BarTouchTooltipData(
                tooltipBgColor: Colors.black87,
                tooltipRoundedRadius: 8,
                tooltipPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                getTooltipItem: (group, groupIndex, rod, rodIndex) {
                  return BarTooltipItem(
                    '${topThumbnails[groupIndex].creatorName}\n${(rod.toY / 1000).toStringAsFixed(1)}K views',
                    const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  );
                },
              ),
              handleBuiltInTouches: true,
              touchCallback: (FlTouchEvent event, barTouchResponse) {
                // Add haptic feedback or additional interactions here if needed
              },
            ),
            titlesData: FlTitlesData(
              show: true,
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (value, meta) {
                    if (value.toInt() < topThumbnails.length) {
                      return Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          topThumbnails[value.toInt()].creatorAvatar,
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                      );
                    }
                    return const Text('');
                  },
                ),
              ),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 40,
                  getTitlesWidget: (value, meta) {
                    return Text(
                      '${(value / 1000).toStringAsFixed(0)}k',
                      style: const TextStyle(fontSize: 10),
                    );
                  },
                ),
              ),
              topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            ),
            gridData: FlGridData(
              show: true,
              drawVerticalLine: false,
              horizontalInterval: 5000,
              getDrawingHorizontalLine: (value) => FlLine(
                color: Colors.grey[300]!,
                strokeWidth: 1,
              ),
            ),
            borderData: FlBorderData(show: false),
            barGroups: List.generate(topThumbnails.length, (index) {
              // Stagger the animation for each bar
              final delay = index * 0.1;
              final barProgress = Curves.easeOutBack.transform(
                (((_chartAnimation.value - delay) / (1 - delay)).clamp(0.0, 1.0))
              );
              
              return BarChartGroupData(
                x: index,
                barRods: [
                  BarChartRodData(
                    toY: topThumbnails[index].views.toDouble() * barProgress,
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFFFF0000).withOpacity(0.8),
                        const Color(0xFFFF6B00),
                      ],
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                    ),
                    width: 20,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                  ),
                ],
              );
            }),
          ),
        );
      },
    );
  }

  Widget _buildOtherScreens() {
    switch (_currentIndex) {
      case 1:
        return const MyThumbnailsScreen();
      case 2:
        return const AnalyticsScreen();
      case 3:
        return const SettingsScreen();
      default:
        return _buildHomeContent();
    }
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
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
        backgroundColor: Colors.white,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFFFF0000),
        unselectedItemColor: Colors.grey,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
        elevation: 0,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Trending',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.image_outlined),
            activeIcon: Icon(Icons.image),
            label: 'My Designs',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.analytics_outlined),
            activeIcon: Icon(Icons.analytics),
            label: 'Analytics',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings_outlined),
            activeIcon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _chartAnimationController.dispose();
    super.dispose();
  }
}
