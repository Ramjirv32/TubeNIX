import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../services/collection_service.dart';
import '../widgets/trending_thumbnail_card.dart';
import '../models/trending_thumbnail_model.dart';

class CollectionsScreen extends StatefulWidget {
  const CollectionsScreen({super.key});

  @override
  State<CollectionsScreen> createState() => _CollectionsScreenState();
}

class _CollectionsScreenState extends State<CollectionsScreen>
    with SingleTickerProviderStateMixin {
  final CollectionService _collectionService = CollectionService();
  
  List<Map<String, dynamic>> _collections = [];
  List<TrendingThumbnail> _filteredThumbnails = [];
  bool _isLoading = true;
  String _selectedCategory = 'All';
  String _selectedType = 'All'; // 'All', 'Liked', 'Saved'
  
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadCollections();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadCollections() async {
    setState(() {
      _isLoading = true;
    });

    try {
      print('📥 Loading collections...');
      final collections = await _collectionService.getCollections();
      print('📊 Loaded ${collections.length} collections');
      
      setState(() {
        _collections = collections.cast<Map<String, dynamic>>();
        _filterCollections();
        _isLoading = false;
      });
    } catch (e) {
      print('❌ Error loading collections: $e');
      setState(() {
        _isLoading = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load collections: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _filterCollections() {
    List<Map<String, dynamic>> filtered = _collections;
    
    // Filter by type (liked/saved)
    if (_selectedType == 'Liked') {
      filtered = filtered.where((collection) {
        final tags = collection['tags'] as List<dynamic>? ?? [];
        return tags.contains('liked');
      }).toList();
    } else if (_selectedType == 'Saved') {
      filtered = filtered.where((collection) {
        final tags = collection['tags'] as List<dynamic>? ?? [];
        return tags.contains('saved');
      }).toList();
    }
    
    // Filter by category (could be extended based on metadata)
    if (_selectedCategory != 'All') {
      filtered = filtered.where((collection) {
        final metadata = collection['metadata'] as Map<String, dynamic>? ?? {};
        final channelName = metadata['channelName'] as String? ?? '';
        return channelName.toLowerCase().contains(_selectedCategory.toLowerCase());
      }).toList();
    }

    // Convert to TrendingThumbnail objects for display
    setState(() {
      _filteredThumbnails = filtered.map((collection) {
        final metadata = collection['metadata'] as Map<String, dynamic>? ?? {};
        final tags = collection['tags'] as List<dynamic>? ?? [];
        
        return TrendingThumbnail(
          id: collection['_id'] as String? ?? '',
          title: collection['title'] as String? ?? 'Untitled',
          imageUrl: collection['imageUrl'] as String? ?? '',
          dateCreated: DateTime.tryParse(collection['createdAt'] as String? ?? '') ?? DateTime.now(),
          ctrPercentage: 0.0,
          creatorName: metadata['channelName'] as String? ?? 'Unknown Creator',
          creatorAvatar: (metadata['channelName'] as String? ?? 'U').substring(0, 1).toUpperCase(),
          views: int.tryParse(metadata['views'] as String? ?? '0') ?? 0,
          likes: 0,
          saves: 0,
          downloads: 0,
          isLiked: tags.contains('liked'),
          isSaved: tags.contains('saved'),
        );
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'My Collections',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: const Color(0xFFFF6B00),
          unselectedLabelColor: Colors.grey,
          indicatorColor: const Color(0xFFFF6B00),
          tabs: const [
            Tab(text: 'Liked'),
            Tab(text: 'Saved'),
          ],
          onTap: (index) {
            setState(() {
              _selectedType = index == 0 ? 'Liked' : 'Saved';
              _filterCollections();
            });
          },
        ),
      ),
      body: Column(
        children: [
          // Category Filter
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Category',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildCategoryChip('All'),
                      _buildCategoryChip('Tech'),
                      _buildCategoryChip('Gaming'),
                      _buildCategoryChip('Music'),
                      _buildCategoryChip('Education'),
                      _buildCategoryChip('Entertainment'),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Content
          Expanded(
            child: _isLoading
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFF6B00)),
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Loading your collections...',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  )
                : _filteredThumbnails.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              _selectedType == 'Liked' ? Icons.favorite_outline : Icons.bookmark_outline,
                              size: 64,
                              color: Colors.grey,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No ${_selectedType.toLowerCase()} items found',
                              style: const TextStyle(
                                fontSize: 18,
                                color: Colors.grey,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Start liking and saving content to see them here!',
                              style: TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                      )
                    : Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: GridView.builder(
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
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChip(String category) {
    final isSelected = _selectedCategory == category;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedCategory = category;
            _filterCollections();
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFFFF6B00) : Colors.grey[200],
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            category,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.black54,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _toggleLike(String id) async {
    try {
      // Remove from liked collections
      await _collectionService.deleteFromCollection(id);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Removed from liked!'),
          backgroundColor: Colors.orange,
        ),
      );
      _loadCollections(); // Refresh the list
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _toggleSave(String id) async {
    try {
      // Remove from saved collections
      await _collectionService.deleteFromCollection(id);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Removed from saved!'),
          backgroundColor: Colors.orange,
        ),
      );
      _loadCollections(); // Refresh the list
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _download(String id) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Downloading thumbnail...')),
    );
  }
}