import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';




/// Enhanced My Thumbnails Screen with Grid/List View and Filters

class MyThumbnailsScreen extends StatefulWidget {
  const MyThumbnailsScreen({super.key});

  @override
  State<MyThumbnailsScreen> createState() => _MyThumbnailsScreenState();
}



class _MyThumbnailsScreenState extends State<MyThumbnailsScreen> {
  bool _isGridView = true;
  String _selectedFilter = 'All'; // All, Tech, Gaming, Music
  String _selectedSort = 'Recent'; // Recent, Views, Likes

  final List<Map<String, dynamic>> _thumbnails = [
    {
      'title': 'AI Revolution 2025',
      'description': 'Exploring the latest AI technologies and innovations',
      'category': 'Tech',
      'views': '15.2K',
      'likes': '2.1K',
      'date': '2 days ago',
      'image': 'https://picsum.photos/400/225?random=20',
    },
    {
      'title': 'Gaming Highlights',
      'description': 'Best moments from recent gaming sessions',
      'category': 'Gaming',
      'views': '12.8K',
      'likes': '1.8K',
      'date': '5 days ago',
      'image': 'https://picsum.photos/400/225?random=21',
    },
    {
      'title': 'Music Festival 2025',
      'description': 'Live performances from the biggest music festival',
      'category': 'Music',
      'views': '10.5K',
      'likes': '1.5K',
      'date': '1 week ago',
      'image': 'https://picsum.photos/400/225?random=22',
    },
    {
      'title': 'Coding Tutorial',
      'description': 'Step-by-step guide to modern web development',
      'category': 'Tech',
      'views': '8.3K',
      'likes': '1.2K',
      'date': '2 weeks ago',
      'image': 'https://picsum.photos/400/225?random=23',
    },
    {
      'title': 'Fortnite Gameplay',
      'description': 'Epic wins and strategies for competitive play',
      'category': 'Gaming',
      'views': '9.7K',
      'likes': '1.4K',
      'date': '3 days ago',
      'image': 'https://picsum.photos/400/225?random=24',
    },
    {
      'title': 'Top Songs 2025',
      'description': 'The most popular songs of the year',
      'category': 'Music',
      'views': '11.2K',
      'likes': '1.6K',
      'date': '4 days ago',
      'image': 'https://picsum.photos/400/225?random=25',
    },
  ];

  List<Map<String, dynamic>> get _filteredThumbnails {
    var filtered = _thumbnails;
    
    // Apply category filter
    if (_selectedFilter != 'All') {
      filtered = filtered.where((t) => t['category'] == _selectedFilter).toList();
    }
    
    // Apply sorting
    if (_selectedSort == 'Views') {
      filtered.sort((a, b) => b['views'].compareTo(a['views']));
    } else if (_selectedSort == 'Likes') {
      filtered.sort((a, b) => b['likes'].compareTo(a['likes']));
    }
    
    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 2,
        automaticallyImplyLeading: false,
        title: Text(
          'My Thumbnails',
          style: GoogleFonts.poppins(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              _isGridView ? Icons.list : Icons.grid_view,
              color: const Color(0xFFFF6B00),
            ),
            onPressed: () {
              setState(() => _isGridView = !_isGridView);
            },
          ),
          IconButton(
            icon: const Icon(Icons.add, color: const Color(0xFFFF6B00)),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Create new thumbnail',
                    style: GoogleFonts.poppins(),
                  ),
                  backgroundColor: const Color(0xFFFF6B00),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Filters and Sort
          _buildFilterBar(),
          
          // Thumbnails List/Grid
          Expanded(
            child: _isGridView ? _buildGridView() : _buildListView(),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Category Filters
          Text(
            'Category',
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip('All'),
                const SizedBox(width: 8),
                _buildFilterChip('Tech'),
                const SizedBox(width: 8),
                _buildFilterChip('Gaming'),
                const SizedBox(width: 8),
                _buildFilterChip('Music'),
              ],
            ),
          ),
          const SizedBox(height: 16),
          
          // Sort Options
          Row(
            children: [
              Text(
                'Sort by:',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(width: 12),
              _buildSortChip('Recent'),
              const SizedBox(width: 8),
              _buildSortChip('Views'),
              const SizedBox(width: 8),
              _buildSortChip('Likes'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label) {
    final isSelected = _selectedFilter == label;
    return GestureDetector(
      onTap: () {
        setState(() => _selectedFilter = label);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          gradient: isSelected
              ? const LinearGradient(
                  colors: [Color(0xFFFF0000), Color(0xFFFF6B00)],
                )
              : null,
          color: isSelected ? null : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            color: isSelected ? Colors.white : Colors.grey.shade700,
          ),
        ),
      ),
    );
  }

  Widget _buildSortChip(String label) {
    final isSelected = _selectedSort == label;
    return GestureDetector(
      onTap: () {
        setState(() => _selectedSort = label);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFFF6B00) : Colors.transparent,
          border: Border.all(
            color: isSelected ? const Color(0xFFFF6B00) : Colors.grey.shade300,
          ),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            color: isSelected ? Colors.white : Colors.grey.shade600,
          ),
        ),
      ),
    );
  }

  Widget _buildGridView() {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.75,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: _filteredThumbnails.length,
      itemBuilder: (context, index) {
        return _buildGridItem(_filteredThumbnails[index]);
      },
    );
  }

  Widget _buildGridItem(Map<String, dynamic> thumbnail) {
    return GestureDetector(
      onTap: () {
        _showThumbnailOptions(thumbnail);
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thumbnail Image
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
              child: CachedNetworkImage(
                imageUrl: thumbnail['image'],
                height: 120,
                width: double.infinity,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  height: 120,
                  color: Colors.grey.shade200,
                  child: const Center(
                    child: CircularProgressIndicator(
                      color: Color(0xFFFF6B00),
                      strokeWidth: 2,
                    ),
                  ),
                ),
                errorWidget: (context, url, error) => Container(
                  height: 120,
                  color: Colors.grey.shade300,
                  child: const Icon(Icons.image, size: 40, color: Colors.grey),
                ),
              ),
            ),
            
            // Info
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      thumbnail['title'],
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      thumbnail['description'],
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        color: Colors.grey.shade600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Spacer(),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFF6B00).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            thumbnail['category'],
                            style: GoogleFonts.poppins(
                              fontSize: 9,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFFFF6B00),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.visibility, size: 12, color: Colors.grey.shade600),
                        const SizedBox(width: 4),
                        Text(
                          thumbnail['views'],
                          style: GoogleFonts.poppins(
                            fontSize: 10,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Icon(Icons.favorite, size: 12, color: Colors.grey.shade600),
                        const SizedBox(width: 4),
                        Text(
                          thumbnail['likes'],
                          style: GoogleFonts.poppins(
                            fontSize: 10,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListView() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _filteredThumbnails.length,
      itemBuilder: (context, index) {
        return _buildListItem(_filteredThumbnails[index]);
      },
    );
  }

  Widget _buildListItem(Map<String, dynamic> thumbnail) {
    return GestureDetector(
      onTap: () {
        _showThumbnailOptions(thumbnail);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Thumbnail
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: CachedNetworkImage(
                imageUrl: thumbnail['image'],
                width: 100,
                height: 70,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  width: 100,
                  height: 70,
                  color: Colors.grey.shade200,
                  child: const Center(
                    child: CircularProgressIndicator(
                      color: Color(0xFFFF6B00),
                      strokeWidth: 2,
                    ),
                  ),
                ),
                errorWidget: (context, url, error) => Container(
                  width: 100,
                  height: 70,
                  color: Colors.grey.shade300,
                  child: const Icon(Icons.image, size: 30, color: Colors.grey),
                ),
              ),
            ),
            const SizedBox(width: 12),
            
            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    thumbnail['title'],
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    thumbnail['description'],
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFFF0000), Color(0xFFFF6B00)],
                          ),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Text(
                          thumbnail['category'],
                          style: GoogleFonts.poppins(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(Icons.visibility, size: 14, color: Colors.grey.shade600),
                      const SizedBox(width: 4),
                      Text(
                        thumbnail['views'],
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Icon(Icons.favorite, size: 14, color: Colors.grey.shade600),
                      const SizedBox(width: 4),
                      Text(
                        thumbnail['likes'],
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        thumbnail['date'],
                        style: GoogleFonts.poppins(
                          fontSize: 10,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            // More Options
            IconButton(
              icon: const Icon(Icons.more_vert, color: Colors.grey),
              onPressed: () {
                _showThumbnailOptions(thumbnail);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showThumbnailOptions(Map<String, dynamic> thumbnail) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            _buildOption(Icons.share, 'Share', Colors.blue),
            _buildOption(Icons.edit, 'Edit', const Color(0xFFFF6B00)),
            _buildOption(Icons.download, 'Download', Colors.green),
            _buildOption(Icons.delete, 'Delete', Colors.red),
          ],
        ),
      ),
    );
  }

  Widget _buildOption(IconData icon, String label, Color color) {
    return InkWell(
      onTap: () {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '$label action',
              style: GoogleFonts.poppins(),
            ),
            backgroundColor: color,
            behavior: SnackBarBehavior.floating,
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Row(
          children: [
            Icon(icon, color: color),
            const SizedBox(width: 16),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 16,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
