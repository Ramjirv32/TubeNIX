import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/thumbnail_service.dart';
import 'dart:typed_data';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class ThumbnailGeneratorScreen extends StatefulWidget {
  final String? initialPrompt;
  final String? initialImage;

  const ThumbnailGeneratorScreen({
    super.key,
    this.initialPrompt,
    this.initialImage,
  });

  @override
  State<ThumbnailGeneratorScreen> createState() => _ThumbnailGeneratorScreenState();
}

class _ThumbnailGeneratorScreenState extends State<ThumbnailGeneratorScreen>
    with TickerProviderStateMixin {
  final TextEditingController _promptController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  late AnimationController _animationController;
  late TabController _tabController;

  bool _isGenerating = false;
  bool _isLoggedIn = false;
  List<ThumbnailResult> _generatedThumbnails = [];
  List<UserThumbnail> _userThumbnails = [];
  int _selectedTabIndex = 0; // 0: Generate, 1: My Thumbnails, 2: Public Gallery

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _tabController = TabController(length: 3, vsync: this, initialIndex: _selectedTabIndex);
    _checkAuthStatus();
    if (widget.initialPrompt != null) {
      _promptController.text = widget.initialPrompt!;
    }
  }

  @override
  void dispose() {
    _promptController.dispose();
    _scrollController.dispose();
    _animationController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _checkAuthStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    setState(() {
      _isLoggedIn = token != null && token.isNotEmpty;
    });

    if (_isLoggedIn) {
      _loadUserThumbnails();
    }
  }

  Future<void> _loadUserThumbnails() async {
    if (!_isLoggedIn) return;

    try {
      final thumbnails = await thumbnailService.getUserThumbnails();
      setState(() {
        _userThumbnails = thumbnails;
      });
    } catch (e) {
      _showError('Failed to load thumbnails: $e');
    }
  }

  Future<void> _generateThumbnail() async {
    if (_promptController.text.trim().isEmpty) {
      _showError('Please enter a prompt for your thumbnail');
      return;
    }


    setState(() {
      _isGenerating = true;
    });

    try {

      final result = await thumbnailService.generateThumbnail(
        prompt: _promptController.text.trim(),
        // Only auto-save to the user's collection if they're logged in.
        saveToCollection: _isLoggedIn,
        makePublic: false,
      );

      setState(() {
        _generatedThumbnails.insert(0, result);
        _isGenerating = false;
      });

      _animationController.forward();
      _showSuccess('Thumbnail generated successfully!');
      
      // Reload user thumbnails only when logged in
      if (_isLoggedIn) {
        _loadUserThumbnails();
      }

    } catch (e) {
      setState(() {
        _isGenerating = false;
      });
      _showError('Failed to generate thumbnail: $e');
    }
  }

  Future<void> _generateMultipleThumbnails() async {
    if (_promptController.text.trim().isEmpty) {
      _showError('Please enter a prompt for your thumbnails');
      return;
    }


    setState(() {
      _isGenerating = true;
    });

    try {
      final results = await thumbnailService.generateMultipleThumbnails(
        prompt: _promptController.text.trim(),
        count: 3,
        // Only auto-save when logged in
        saveToCollection: _isLoggedIn,
        makePublic: false,
      );

      setState(() {
        _generatedThumbnails.insertAll(0, results);
        _isGenerating = false;
      });

      _animationController.forward();
      _showSuccess('Generated ${results.length} thumbnail variations!');
      
      // Reload user thumbnails only when logged in
      if (_isLoggedIn) {
        _loadUserThumbnails();
      }

    } catch (e) {
      setState(() {
        _isGenerating = false;
      });
      _showError('Failed to generate thumbnails: $e');
    }
  }

  Future<void> _downloadThumbnail(ThumbnailResult thumbnail) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final fileName = 'tubenix_thumbnail_${DateTime.now().millisecondsSinceEpoch}.png';
      final file = File('${directory.path}/$fileName');
      
      await file.writeAsBytes(thumbnail.imageBytes);
      
      _showSuccess('Thumbnail saved to ${file.path}');
    } catch (e) {
      _showError('Failed to download thumbnail: $e');
    }
  }

  Future<void> _copyToClipboard(ThumbnailResult thumbnail) async {
    await Clipboard.setData(ClipboardData(text: thumbnail.dataUrl));
    _showSuccess('Base64 data copied to clipboard');
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1A1A),
        elevation: 0,
        title: Text(
          'AI Thumbnail Generator',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: const Color(0xFFFF6B35),
          labelColor: Colors.white,
          unselectedLabelColor: Colors.grey,
          onTap: (index) => setState(() => _selectedTabIndex = index),
          tabs: const [
            Tab(text: 'Generate'),
            Tab(text: 'My Thumbnails'),
            Tab(text: 'Gallery'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildGenerateTab(),
          _buildMyThumbnailsTab(),
          _buildGalleryTab(),
        ],
      ),
    );
  }

  Widget _buildGenerateTab() {
    return SingleChildScrollView(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!_isLoggedIn) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white12,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF333333)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, color: Colors.lightBlueAccent),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'You can generate thumbnails as a guest. Log in to save to your account and access "My Thumbnails".',
                      style: TextStyle(color: Colors.white70),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                      // Navigate to login screen
                    },
                    child: const Text('Log In'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Prompt Input
          Text(
            'Describe Your Thumbnail',
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A1A),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFF333333)),
            ),
            child: TextField(
              controller: _promptController,
              style: const TextStyle(color: Colors.white),
              maxLines: 4,
              decoration: const InputDecoration(
                hintText: 'e.g., YouTube thumbnail for gaming video about Minecraft survival, colorful and exciting, bold text',
                hintStyle: TextStyle(color: Colors.grey),
                border: InputBorder.none,
                contentPadding: EdgeInsets.all(16),
              ),
            ),
          ),
          
          const SizedBox(height: 20),

          // Action Buttons
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: !_isGenerating ? _generateThumbnail : null,
                  icon: _isGenerating
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.auto_awesome),
                  label: Text(_isGenerating ? 'Generating...' : 'Generate'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF6B35),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: !_isGenerating ? _generateMultipleThumbnails : null,
                  icon: const Icon(Icons.burst_mode),
                  label: const Text('3 Variations'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF333333),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 30),

          // Generated Thumbnails
          if (_generatedThumbnails.isNotEmpty) ...[
            Text(
              'Generated Thumbnails',
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _generatedThumbnails.length,
              itemBuilder: (context, index) {
                final thumbnail = _generatedThumbnails[index];
                return _buildThumbnailCard(thumbnail, showActions: true);
              },
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMyThumbnailsTab() {
    if (!_isLoggedIn) {
      return const Center(
        child: Text(
          'Please log in to view your thumbnails',
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadUserThumbnails,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _userThumbnails.length,
        itemBuilder: (context, index) {
          final thumbnail = _userThumbnails[index];
          return _buildUserThumbnailCard(thumbnail);
        },
      ),
    );
  }

  Widget _buildGalleryTab() {
    return const Center(
      child: Text(
        'Public Gallery Coming Soon',
        style: TextStyle(color: Colors.grey),
      ),
    );
  }

  Widget _buildThumbnailCard(ThumbnailResult thumbnail, {bool showActions = false}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF333333)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            child: Image.memory(
              thumbnail.imageBytes,
              width: double.infinity,
              height: 200,
              fit: BoxFit.cover,
            ),
          ),
          
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  thumbnail.prompt,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                
                Text(
                  'Size: ${thumbnail.size} • ${thumbnail.createdAt.toString().substring(0, 16)}',
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
                
                if (showActions) ...[
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _downloadThumbnail(thumbnail),
                          icon: const Icon(Icons.download, size: 16),
                          label: const Text('Download'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF333333),
                            padding: const EdgeInsets.symmetric(vertical: 8),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _copyToClipboard(thumbnail),
                          icon: const Icon(Icons.copy, size: 16),
                          label: const Text('Copy'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFF6B35),
                            padding: const EdgeInsets.symmetric(vertical: 8),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserThumbnailCard(UserThumbnail thumbnail) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF333333)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              thumbnail.originalPrompt,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            
            Row(
              children: [
                Icon(
                  thumbnail.isPublic ? Icons.public : Icons.lock,
                  color: thumbnail.isPublic ? Colors.green : Colors.grey,
                  size: 16,
                ),
                const SizedBox(width: 4),
                Text(
                  thumbnail.isPublic ? 'Public' : 'Private',
                  style: TextStyle(
                    color: thumbnail.isPublic ? Colors.green : Colors.grey,
                    fontSize: 12,
                  ),
                ),
                const Spacer(),
                Text(
                  '${thumbnail.downloadCount} downloads',
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
            
            const SizedBox(height: 8),
            Text(
              'Size: ${thumbnail.imageSize} • ${thumbnail.createdAt.toString().substring(0, 16)}',
              style: const TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}