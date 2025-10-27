import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:typed_data';
import '../services/thumbnail_service.dart';

/// AI Chat Screen
/// Chat interface for generating thumbnails with AI
class AIChatScreen extends StatefulWidget {
  final String? initialImage;
  final String? initialPrompt;
  
  const AIChatScreen({
    super.key,
    this.initialImage,
    this.initialPrompt,
  });

  @override
  State<AIChatScreen> createState() => _AIChatScreenState();
}

class _AIChatScreenState extends State<AIChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final List<ChatMessage> _messages = [];

  @override
  void initState() {
    super.initState();
    // If initial prompt or image is provided, show it
    if (widget.initialImage != null || widget.initialPrompt != null) {
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted) {
          setState(() {
            if (widget.initialPrompt != null) {
              _messages.add(ChatMessage(
                text: widget.initialPrompt!,
                isUser: false,
                timestamp: DateTime.now(),
              ));
            }
            if (widget.initialImage != null) {
              _messages.add(ChatMessage(
                text: 'Image added from trending content. You can now ask me to modify it or create a similar thumbnail.',
                isUser: false,
                timestamp: DateTime.now(),
                imageUrl: widget.initialImage,
              ));
            }
          });
        }
      });
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  void _sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;

    final userMessage = _messageController.text.trim();
    _messageController.clear();

    setState(() {
      _messages.add(ChatMessage(
        text: userMessage,
        isUser: true,
        timestamp: DateTime.now(),
      ));

      // Show typing indicator
      _messages.add(ChatMessage(
        text: '🎨 Generating your thumbnail...',
        isUser: false,
        timestamp: DateTime.now(),
        isTyping: true,
      ));
    });

    try {
      // Generate thumbnail using demo endpoint (since Gemini API has quota limits)
      final result = await thumbnailService.generateThumbnailDemo(
        prompt: userMessage,
      );

      setState(() {
        // Remove typing indicator
        _messages.removeWhere((msg) => msg.isTyping == true);
        
        // Add success message with image
        _messages.add(ChatMessage(
          text: 'Here\'s your generated thumbnail! 🎨\n\nPrompt: "${result.prompt}"\nSize: ${result.size}',
          isUser: false,
          timestamp: DateTime.now(),
          generatedImage: result.imageBytes,
          thumbnailId: result.id,
        ));
      });
    } catch (e) {
      setState(() {
        // Remove typing indicator
        _messages.removeWhere((msg) => msg.isTyping == true);
        
        // Show error message
        _messages.add(ChatMessage(
          text: '❌ Sorry, I couldn\'t generate that thumbnail.\n\nError: ${e.toString()}\n\nThis might be due to API quota limits. Please try again later or with a different prompt.',
          isUser: false,
          timestamp: DateTime.now(),
        ));
      });
    }
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
        title: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFFF0000), Color(0xFFFF6B00)],
                ),
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Icon(Icons.smart_toy, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 12),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'TubeNix AI',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Online',
                  style: TextStyle(
                    color: Colors.green,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.black),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          // Messages List
          Expanded(
            child: _messages.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFFFF0000), Color(0xFFFF6B00)],
                            ),
                            borderRadius: BorderRadius.circular(40),
                          ),
                          child: const Icon(
                            Icons.auto_awesome,
                            color: Colors.white,
                            size: 40,
                          ),
                        ),
                        const SizedBox(height: 24),
                        const Text(
                          'Start a conversation',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Generate thumbnails with AI assistance',
                          style: TextStyle(
                            color: Colors.black54,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 32),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          alignment: WrapAlignment.center,
                          children: [
                            _buildSuggestionChip('Create gaming thumbnail'),
                            _buildSuggestionChip('Tech review style'),
                            _buildSuggestionChip('Vlog thumbnail'),
                            _buildSuggestionChip('Tutorial design'),
                          ],
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      return _buildMessageBubble(_messages[index]);
                    },
                  ),
          ),

          // Input Area
          Container(
            padding: const EdgeInsets.all(16),
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
            child: Row(
              children: [
                // Attachment Button
                IconButton(
                  icon: const Icon(Icons.add_circle_outline, color: Color(0xFFFF6B00)),
                  onPressed: () {
                    _showAttachmentOptions();
                  },
                ),
                // Text Field
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Type your message...',
                      hintStyle: const TextStyle(color: Colors.black38),
                      filled: true,
                      fillColor: const Color(0xFFF5F5F5),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                    ),
                    style: const TextStyle(color: Colors.black),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                const SizedBox(width: 8),
                // Send Button
                Container(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFF0000), Color(0xFFFF6B00)],
                    ),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.send, color: Colors.white),
                    onPressed: _sendMessage,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestionChip(String text) {
    return InkWell(
      onTap: () {
        setState(() {
          _messageController.text = text;
        });
      },
      child: Chip(
        label: Text(text),
        labelStyle: const TextStyle(color: Colors.black87, fontSize: 12),
        backgroundColor: const Color(0xFFF5F5F5),
        side: BorderSide.none,
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment:
            message.isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!message.isUser) ...[
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFFF0000), Color(0xFFFF6B00)],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                message.isTyping ? Icons.more_horiz : Icons.smart_toy, 
                color: Colors.white, 
                size: 18
              ),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: message.isUser
                    ? const Color(0xFFFF6B00)
                    : const Color(0xFFF5F5F5),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Text message
                  Text(
                    message.text,
                    style: TextStyle(
                      color: message.isUser ? Colors.white : Colors.black,
                      fontSize: 14,
                    ),
                  ),
                  
                  // Generated image display
                  if (message.generatedImage != null) ...[
                    const SizedBox(height: 12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.memory(
                        message.generatedImage!,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            height: 200,
                            color: Colors.grey[300],
                            child: const Center(
                              child: Icon(Icons.error, color: Colors.red),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 8),
                    
                    // Action buttons for generated image
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildImageActionButton(
                          icon: Icons.download,
                          label: 'Download',
                          onTap: () => _downloadThumbnail(message.thumbnailId!),
                        ),
                        const SizedBox(width: 8),
                        _buildImageActionButton(
                          icon: Icons.share,
                          label: 'Share',
                          onTap: () => _shareThumbnail(message.thumbnailId!),
                        ),
                        const SizedBox(width: 8),
                        _buildImageActionButton(
                          icon: Icons.refresh,
                          label: 'Regenerate',
                          onTap: () => _regenerateThumbnail(message.text),
                        ),
                      ],
                    ),
                  ],
                  
                  // Regular image from URL (if provided)
                  if (message.imageUrl != null) ...[
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        message.imageUrl!,
                        width: 200,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: 200,
                            height: 100,
                            color: Colors.grey[300],
                            child: const Icon(Icons.broken_image),
                          );
                        },
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          if (message.isUser) const SizedBox(width: 8),
        ],
      ),
    );
  }

  void _showAttachmentOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildAttachmentOption(
              icon: Icons.image,
              title: 'Upload Image',
              subtitle: 'Generate from your image',
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Image upload coming soon!')),
                );
              },
            ),
            _buildAttachmentOption(
              icon: Icons.video_library,
              title: 'Upload Video',
              subtitle: 'Extract frame from video',
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Video upload coming soon!')),
                );
              },
            ),
            _buildAttachmentOption(
              icon: Icons.text_fields,
              title: 'Text Prompt',
              subtitle: 'Generate from description',
              onTap: () {
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAttachmentOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFFF0000), Color(0xFFFF6B00)],
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: Colors.white),
      ),
      title: Text(
        title,
        style: const TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(color: Colors.black54, fontSize: 12),
      ),
      onTap: onTap,
    );
  }

  Widget _buildImageActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(8),
          color: Colors.white,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: Colors.grey[600]),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _downloadThumbnail(String thumbnailId) async {
    try {
      final bytes = await thumbnailService.downloadThumbnail(thumbnailId);
      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Thumbnail downloaded successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Download failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _shareThumbnail(String thumbnailId) async {
    // Placeholder for sharing functionality
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('🚀 Sharing feature coming soon!'),
          backgroundColor: Colors.blue,
        ),
      );
    }
  }

  Future<void> _regenerateThumbnail(String originalPrompt) async {
    // Extract the user prompt from the message
    _messageController.text = originalPrompt;
    _sendMessage();
  }
}

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final String? imageUrl;
  final Uint8List? generatedImage;
  final String? thumbnailId;
  final bool isTyping;

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
    this.imageUrl,
    this.generatedImage,
    this.thumbnailId,
    this.isTyping = false,
  });
}
