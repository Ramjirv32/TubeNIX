import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/thumbnail_service.dart';
import '../services/thumbnail_state_manager.dart';
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
    _restoreGenerationState(); // Load persisted state
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

  Future<void> _restoreGenerationState() async {
    // Load persisted generation states
    await thumbnailStateManager.loadStates();
    
    // Check for any active (generating) states
    final activeStates = thumbnailStateManager.getActiveStates();
    
    if (activeStates.isNotEmpty) {
      print('📦 Found ${activeStates.length} active generation tasks');
      
      // Show snackbar to user
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Found ${activeStates.length} pending thumbnail generation(s)'),
            action: SnackBarAction(
              label: 'Clear',
              onPressed: () => thumbnailStateManager.clearCompletedStates(),
            ),
          ),
        );
      }
    }
    
    // Check for completed states and load them
    final completedStates = thumbnailStateManager.getCompletedStates();
    if (completedStates.isNotEmpty && mounted) {
      setState(() {
        for (var state in completedStates) {
          if (state.base64Image != null && state.base64Image!.isNotEmpty) {
            _generatedThumbnails.add(ThumbnailResult(
              id: state.id,
              base64: state.base64Image!,
              prompt: state.prompt,
              size: 'Restored',
              createdAt: state.startedAt,
            ));
          }
        }
      });
    }
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
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        title: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFFF0000), Color(0xFFFF6B00)],
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.auto_awesome, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 12),
            Text(
              'AI Thumbnail Generator',
              style: GoogleFonts.poppins(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ],
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: const Color(0xFFFF6B00),
          indicatorWeight: 3,
          labelColor: const Color(0xFFFF6B00),
          unselectedLabelColor: Colors.grey,
          labelStyle: GoogleFonts.poppins(fontWeight: FontWeight.w600),
          unselectedLabelStyle: GoogleFonts.poppins(fontWeight: FontWeight.normal),
          onTap: (index) => setState(() => _selectedTabIndex = index),
          tabs: const [
            Tab(icon: Icon(Icons.auto_awesome), text: 'Generate'),
            Tab(icon: Icon(Icons.photo_library), text: 'My Thumbnails'),
            Tab(icon: Icon(Icons.public), text: 'Gallery'),
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
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!_isLoggedIn) ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFFFF6B00).withOpacity(0.1),
                    const Color(0xFFFF0000).withOpacity(0.1),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFFF6B00).withOpacity(0.3), width: 1.5),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF6B00).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.info_outline, color: Color(0xFFFF6B00), size: 24),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'You can generate thumbnails as a guest. Log in to save to your account and access "My Thumbnails".',
                      style: GoogleFonts.poppins(
                        color: Colors.black87,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                      // Navigate to login screen
                    },
                    style: TextButton.styleFrom(
                      backgroundColor: const Color(0xFFFF6B00),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text('Log In'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],

          // Prompt Input Section
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFFF0000), Color(0xFFFF6B00)],
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.edit, color: Colors.white, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Describe Your Thumbnail',
                      style: GoogleFonts.poppins(
                        color: Colors.black87,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: TextField(
                    controller: _promptController,
                    style: GoogleFonts.poppins(color: Colors.black87, fontSize: 14),
                    maxLines: 5,
                    decoration: InputDecoration(
                      hintText: 'e.g., YouTube thumbnail for gaming video about Minecraft survival, colorful and exciting, bold text saying "EPIC SURVIVAL"',
                      hintStyle: GoogleFonts.poppins(color: Colors.grey[500], fontSize: 13),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.all(16),
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
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                            : const Icon(Icons.auto_awesome, size: 20),
                        label: Text(
                          _isGenerating ? 'Generating...' : 'Generate',
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFF6B00),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          elevation: 2,
                          shadowColor: const Color(0xFFFF6B00).withOpacity(0.4),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          disabledBackgroundColor: Colors.grey[300],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: !_isGenerating ? _generateMultipleThumbnails : null,
                        icon: const Icon(Icons.burst_mode, size: 20),
                        label: Text(
                          '3 Variations',
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: const Color(0xFFFF6B00),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          elevation: 0,
                          side: const BorderSide(color: Color(0xFFFF6B00), width: 2),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          disabledBackgroundColor: Colors.grey[200],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 30),

          // Generated Thumbnails
          if (_generatedThumbnails.isNotEmpty) ...[
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFF0000), Color(0xFFFF6B00)],
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.photo_library, color: Colors.white, size: 20),
                ),
                const SizedBox(width: 12),
                Text(
                  'Generated Thumbnails',
                  style: GoogleFonts.poppins(
                    color: Colors.black87,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF6B00).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${_generatedThumbnails.length}',
                    style: GoogleFonts.poppins(
                      color: const Color(0xFFFF6B00),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
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
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFFF0000), Color(0xFFFF6B00)],
                ),
                borderRadius: BorderRadius.circular(100),
              ),
              child: const Icon(Icons.lock_outline, color: Colors.white, size: 48),
            ),
            const SizedBox(height: 20),
            Text(
              'Login Required',
              style: GoogleFonts.poppins(
                color: Colors.black87,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Please log in to view your thumbnails',
              style: GoogleFonts.poppins(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: const Icon(Icons.login),
              label: const Text('Go to Login'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF6B00),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadUserThumbnails,
      color: const Color(0xFFFF6B00),
      child: _userThumbnails.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: Icon(Icons.photo_library_outlined, color: Colors.grey[400], size: 48),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'No Thumbnails Yet',
                    style: GoogleFonts.poppins(
                      color: Colors.black87,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Generate your first AI thumbnail!',
                    style: GoogleFonts.poppins(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
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
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFFFF6B00).withOpacity(0.2),
                  const Color(0xFFFF0000).withOpacity(0.2),
                ],
              ),
              borderRadius: BorderRadius.circular(100),
            ),
            child: const Icon(Icons.public, color: Color(0xFFFF6B00), size: 48),
          ),
          const SizedBox(height: 20),
          Text(
            'Public Gallery',
            style: GoogleFonts.poppins(
              color: Colors.black87,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Coming Soon',
            style: GoogleFonts.poppins(
              color: Colors.grey[600],
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Browse amazing thumbnails from our community',
            style: GoogleFonts.poppins(
              color: Colors.grey[500],
              fontSize: 12,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildThumbnailCard(ThumbnailResult thumbnail, {bool showActions = false}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image with gradient overlay
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                child: Image.memory(
                  thumbnail.imageBytes,
                  width: double.infinity,
                  height: 220,
                  fit: BoxFit.cover,
                ),
              ),
              Positioned(
                top: 12,
                right: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFF0000), Color(0xFFFF6B00)],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.auto_awesome, color: Colors.white, size: 14),
                      const SizedBox(width: 4),
                      Text(
                        'AI Generated',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  thumbnail.prompt,
                  style: GoogleFonts.poppins(
                    color: Colors.black87,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    height: 1.4,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 10),
                
                Row(
                  children: [
                    Icon(Icons.photo_size_select_actual, color: Colors.grey[600], size: 14),
                    const SizedBox(width: 4),
                    Text(
                      thumbnail.size,
                      style: GoogleFonts.poppins(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Icon(Icons.access_time, color: Colors.grey[600], size: 14),
                    const SizedBox(width: 4),
                    Text(
                      thumbnail.createdAt.toString().substring(0, 16),
                      style: GoogleFonts.poppins(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                
                if (showActions) ...[
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _downloadThumbnail(thumbnail),
                          icon: const Icon(Icons.download, size: 18),
                          label: Text(
                            'Download',
                            style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: const Color(0xFFFF6B00),
                            elevation: 0,
                            side: const BorderSide(color: Color(0xFFFF6B00), width: 1.5),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _copyToClipboard(thumbnail),
                          icon: const Icon(Icons.copy, size: 18),
                          label: Text(
                            'Copy',
                            style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFF6B00),
                            foregroundColor: Colors.white,
                            elevation: 2,
                            shadowColor: const Color(0xFFFF6B00).withOpacity(0.4),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
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
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFF0000), Color(0xFFFF6B00)],
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.image, color: Colors.white, size: 16),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    thumbnail.originalPrompt,
                    style: GoogleFonts.poppins(
                      color: Colors.black87,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: thumbnail.isPublic 
                              ? const Color(0xFFFF6B00).withOpacity(0.1)
                              : Colors.grey[200],
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: thumbnail.isPublic 
                                ? const Color(0xFFFF6B00)
                                : Colors.grey[400]!,
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              thumbnail.isPublic ? Icons.public : Icons.lock,
                              color: thumbnail.isPublic ? const Color(0xFFFF6B00) : Colors.grey[600],
                              size: 14,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              thumbnail.isPublic ? 'Public' : 'Private',
                              style: GoogleFonts.poppins(
                                color: thumbnail.isPublic ? const Color(0xFFFF6B00) : Colors.grey[600],
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      Icon(Icons.download_outlined, color: Colors.grey[600], size: 16),
                      const SizedBox(width: 4),
                      Text(
                        '${thumbnail.downloadCount}',
                        style: GoogleFonts.poppins(
                          color: Colors.grey[600],
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Icon(Icons.favorite_outline, color: Colors.grey[600], size: 16),
                      const SizedBox(width: 4),
                      Text(
                        '${thumbnail.likes}',
                        style: GoogleFonts.poppins(
                          color: Colors.grey[600],
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Icon(Icons.photo_size_select_actual, color: Colors.grey[500], size: 14),
                      const SizedBox(width: 4),
                      Text(
                        thumbnail.imageSize,
                        style: GoogleFonts.poppins(color: Colors.grey[600], fontSize: 11),
                      ),
                      const SizedBox(width: 12),
                      Icon(Icons.access_time, color: Colors.grey[500], size: 14),
                      const SizedBox(width: 4),
                      Text(
                        thumbnail.createdAt.toString().substring(0, 16),
                        style: GoogleFonts.poppins(color: Colors.grey[600], fontSize: 11),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}