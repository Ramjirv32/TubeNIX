import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';

/// Trending Chat Search - Interactive chat-like interface to explore trending content worldwide
class TrendingChatScreen extends StatefulWidget {
  const TrendingChatScreen({super.key});

  @override
  State<TrendingChatScreen> createState() => _TrendingChatScreenState();
}

class _TrendingChatScreenState extends State<TrendingChatScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];
  bool _isTyping = false;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _sendWelcomeMessage();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _sendWelcomeMessage() {
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() {
          _messages.add(ChatMessage(
            text: 'Welcome to Trending Content Explorer! 🌍',
            isUser: false,
            timestamp: DateTime.now(),
          ));
          _messages.add(ChatMessage(
            text: 'I can help you discover trending content worldwide. Try asking:',
            isUser: false,
            timestamp: DateTime.now(),
            suggestions: [
              'Show trending content',
              'Tech videos',
              'Gaming content',
              'Music trends',
            ],
          ));
        });
        _scrollToBottom();
      }
    });
  }

  void _sendMessage(String text) {
    if (text.trim().isEmpty) return;

    setState(() {
      _messages.add(ChatMessage(
        text: text,
        isUser: true,
        timestamp: DateTime.now(),
      ));
    });

    _messageController.clear();
    _scrollToBottom();

    // Simulate bot response
    setState(() => _isTyping = true);
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        _generateResponse(text.toLowerCase());
      }
    });
  }

  void _generateResponse(String query) {
    List<TrendingContent> content = [];
    String responseText = '';

    if (query.contains('trending') || query.contains('popular') || query.contains('show')) {
      responseText = 'Here are the top trending contents right now:';
      content = _getTrendingContent();
    } else if (query.contains('tech') || query.contains('technology')) {
      responseText = 'Top tech content trending worldwide:';
      content = _getTechContent();
    } else if (query.contains('game') || query.contains('gaming')) {
      responseText = 'Popular gaming content:';
      content = _getGamingContent();
    } else if (query.contains('music')) {
      responseText = 'Trending music videos:';
      content = _getMusicContent();
    } else {
      responseText = 'I found some interesting content for you:';
      content = _getTrendingContent();
    }

    setState(() {
      _isTyping = false;
      _messages.add(ChatMessage(
        text: responseText,
        isUser: false,
        timestamp: DateTime.now(),
        trendingContent: content,
        suggestions: [
          'More like this',
          'Different category',
          'Top creators',
        ],
      ));
    });
    _scrollToBottom();
  }

  List<TrendingContent> _getTrendingContent() {
    return [
      TrendingContent(
        title: 'AI Revolution 2025',
        creator: 'TechVision',
        views: '2.5M',
        category: 'Technology',
        imageUrl: 'https://picsum.photos/400/225?random=1',
      ),
      TrendingContent(
        title: 'Epic Gaming Moments',
        creator: 'GameMaster',
        views: '1.8M',
        category: 'Gaming',
        imageUrl: 'https://picsum.photos/400/225?random=2',
      ),
      TrendingContent(
        title: 'Top Music Hits 2025',
        creator: 'MusicWorld',
        views: '3.2M',
        category: 'Music',
        imageUrl: 'https://picsum.photos/400/225?random=3',
      ),
    ];
  }

  List<TrendingContent> _getTechContent() {
    return [
      TrendingContent(
        title: 'Next-Gen AI Tools',
        creator: 'TechInsider',
        views: '1.5M',
        category: 'Technology',
        imageUrl: 'https://picsum.photos/400/225?random=4',
      ),
      TrendingContent(
        title: 'Coding Tutorial 2025',
        creator: 'CodeMaster',
        views: '980K',
        category: 'Technology',
        imageUrl: 'https://picsum.photos/400/225?random=5',
      ),
      TrendingContent(
        title: 'Future of Tech',
        creator: 'TechVision',
        views: '2.1M',
        category: 'Technology',
        imageUrl: 'https://picsum.photos/400/225?random=6',
      ),
    ];
  }

  List<TrendingContent> _getGamingContent() {
    return [
      TrendingContent(
        title: 'GTA 6 First Look',
        creator: 'GameZone',
        views: '5.2M',
        category: 'Gaming',
        imageUrl: 'https://picsum.photos/400/225?random=7',
      ),
      TrendingContent(
        title: 'Fortnite Championship',
        creator: 'ProGamer',
        views: '3.8M',
        category: 'Gaming',
        imageUrl: 'https://picsum.photos/400/225?random=8',
      ),
      TrendingContent(
        title: 'Minecraft Builds',
        creator: 'BuildMaster',
        views: '2.6M',
        category: 'Gaming',
        imageUrl: 'https://picsum.photos/400/225?random=9',
      ),
    ];
  }

  List<TrendingContent> _getMusicContent() {
    return [
      TrendingContent(
        title: 'Chart Toppers 2025',
        creator: 'MusicHub',
        views: '4.5M',
        category: 'Music',
        imageUrl: 'https://picsum.photos/400/225?random=10',
      ),
      TrendingContent(
        title: 'EDM Festival Live',
        creator: 'DJWorld',
        views: '3.1M',
        category: 'Music',
        imageUrl: 'https://picsum.photos/400/225?random=11',
      ),
      TrendingContent(
        title: 'Acoustic Sessions',
        creator: 'IndieMusicLab',
        views: '1.9M',
        category: 'Music',
        imageUrl: 'https://picsum.photos/400/225?random=12',
      ),
    ];
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 300), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 2,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [Color(0xFFFF0000), Color(0xFFFF6B00)],
                ),
              ),
              child: const Icon(Icons.trending_up, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Trending Explorer',
                  style: GoogleFonts.poppins(
                    color: Colors.black,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                Text(
                  'Discover worldwide trends',
                  style: GoogleFonts.poppins(
                    color: Colors.grey.shade600,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // Messages List
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length + (_isTyping ? 1 : 0),
              itemBuilder: (context, index) {
                if (_isTyping && index == _messages.length) {
                  return _buildTypingIndicator();
                }
                return _buildMessageBubble(_messages[index]);
              },
            ),
          ),
          
          // Input Field
          Container(
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
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: TextField(
                      controller: _messageController,
                      style: GoogleFonts.poppins(fontSize: 15),
                      decoration: InputDecoration(
                        hintText: 'Ask about trending content...',
                        hintStyle: GoogleFonts.poppins(
                          color: Colors.grey.shade500,
                          fontSize: 14,
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                      ),
                      onSubmitted: _sendMessage,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFF0000), Color(0xFFFF6B00)],
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => _sendMessage(_messageController.text),
                      borderRadius: BorderRadius.circular(25),
                      child: const Icon(
                        Icons.send_rounded,
                        color: Colors.white,
                        size: 22,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment:
            message.isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          // Message Bubble
          Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.75,
            ),
            decoration: BoxDecoration(
              gradient: message.isUser
                  ? const LinearGradient(
                      colors: [Color(0xFFFF0000), Color(0xFFFF6B00)],
                    )
                  : null,
              color: message.isUser ? null : Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(20),
                topRight: const Radius.circular(20),
                bottomLeft: Radius.circular(message.isUser ? 20 : 4),
                bottomRight: Radius.circular(message.isUser ? 4 : 20),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Text(
              message.text,
              style: GoogleFonts.poppins(
                color: message.isUser ? Colors.white : Colors.black,
                fontSize: 14,
              ),
            ),
          ),
          
          // Trending Content Cards
          if (message.trendingContent != null) ...[
            const SizedBox(height: 12),
            ...message.trendingContent!.map((content) => _buildContentCard(content)),
          ],
          
          // Suggestion Chips
          if (message.suggestions != null) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: message.suggestions!
                  .map((suggestion) => _buildSuggestionChip(suggestion))
                  .toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildContentCard(TrendingContent content) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
          // Thumbnail
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
            child: CachedNetworkImage(
              imageUrl: content.imageUrl,
              height: 180,
              width: double.infinity,
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(
                height: 180,
                color: Colors.grey.shade200,
                child: const Center(
                  child: CircularProgressIndicator(
                    color: Color(0xFFFF6B00),
                    strokeWidth: 2,
                  ),
                ),
              ),
              errorWidget: (context, url, error) => Container(
                height: 180,
                color: Colors.grey.shade300,
                child: const Icon(Icons.image, size: 50, color: Colors.grey),
              ),
            ),
          ),
          
          // Content Info
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  content.title,
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFFF0000), Color(0xFFFF6B00)],
                        ),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        content.category,
                        style: GoogleFonts.poppins(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(Icons.person_outline, size: 14, color: Colors.grey.shade600),
                    const SizedBox(width: 4),
                    Text(
                      content.creator,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const Spacer(),
                    Icon(Icons.visibility_outlined, size: 14, color: Colors.grey.shade600),
                    const SizedBox(width: 4),
                    Text(
                      content.views,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade600,
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

  Widget _buildSuggestionChip(String suggestion) {
    return InkWell(
      onTap: () => _sendMessage(suggestion),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFFF6B00), width: 1.5),
        ),
        child: Text(
          suggestion,
          style: GoogleFonts.poppins(
            fontSize: 13,
            color: const Color(0xFFFF6B00),
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildDot(0),
                const SizedBox(width: 4),
                _buildDot(1),
                const SizedBox(width: 4),
                _buildDot(2),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDot(int index) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 600),
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, -4 * (0.5 - (value - index * 0.2).abs()).clamp(0.0, 0.5)),
          child: Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.grey.shade400,
            ),
          ),
        );
      },
      onEnd: () {
        if (mounted && _isTyping) {
          setState(() {});
        }
      },
    );
  }
}

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final List<TrendingContent>? trendingContent;
  final List<String>? suggestions;

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
    this.trendingContent,
    this.suggestions,
  });
}

class TrendingContent {
  final String title;
  final String creator;
  final String views;
  final String category;
  final String imageUrl;

  TrendingContent({
    required this.title,
    required this.creator,
    required this.views,
    required this.category,
    required this.imageUrl,
  });
}
