import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Notifications Settings Screen
class NotificationsSettingsScreen extends StatefulWidget {
  const NotificationsSettingsScreen({super.key});

  @override
  State<NotificationsSettingsScreen> createState() => _NotificationsSettingsScreenState();
}

class _NotificationsSettingsScreenState extends State<NotificationsSettingsScreen> {
  bool _pushNotifications = true;
  bool _emailNotifications = true;
  bool _newLikes = true;
  bool _newComments = true;
  bool _newFollowers = true;
  bool _analyticsUpdates = false;
  bool _promotions = false;
  bool _weeklyReports = true;

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
        title: Text(
          'Notifications',
          style: GoogleFonts.poppins(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // General Notifications
            _buildSection(
              'General',
              [
                _buildSwitchTile(
                  Icons.notifications_active,
                  'Push Notifications',
                  'Receive push notifications',
                  _pushNotifications,
                  (value) => setState(() => _pushNotifications = value),
                  Colors.purple,
                ),
                const Divider(height: 24),
                _buildSwitchTile(
                  Icons.email,
                  'Email Notifications',
                  'Receive notifications via email',
                  _emailNotifications,
                  (value) => setState(() => _emailNotifications = value),
                  Colors.blue,
                ),
              ],
            ),
            const SizedBox(height: 20),
            
            // Activity Notifications
            _buildSection(
              'Activity',
              [
                _buildSwitchTile(
                  Icons.favorite,
                  'New Likes',
                  'When someone likes your content',
                  _newLikes,
                  (value) => setState(() => _newLikes = value),
                  Colors.red,
                ),
                const Divider(height: 24),
                _buildSwitchTile(
                  Icons.comment,
                  'New Comments',
                  'When someone comments on your content',
                  _newComments,
                  (value) => setState(() => _newComments = value),
                  Colors.green,
                ),
                const Divider(height: 24),
                _buildSwitchTile(
                  Icons.person_add,
                  'New Followers',
                  'When someone follows you',
                  _newFollowers,
                  (value) => setState(() => _newFollowers = value),
                  const Color(0xFFFF6B00),
                ),
              ],
            ),
            const SizedBox(height: 20),
            
            // Updates & Reports
            _buildSection(
              'Updates & Reports',
              [
                _buildSwitchTile(
                  Icons.bar_chart,
                  'Analytics Updates',
                  'Daily analytics summary',
                  _analyticsUpdates,
                  (value) => setState(() => _analyticsUpdates = value),
                  Colors.indigo,
                ),
                const Divider(height: 24),
                _buildSwitchTile(
                  Icons.campaign,
                  'Promotions',
                  'Special offers and updates',
                  _promotions,
                  (value) => setState(() => _promotions = value),
                  Colors.amber,
                ),
                const Divider(height: 24),
                _buildSwitchTile(
                  Icons.summarize,
                  'Weekly Reports',
                  'Weekly performance summary',
                  _weeklyReports,
                  (value) => setState(() => _weeklyReports = value),
                  Colors.teal,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(20),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildSwitchTile(IconData icon, String title, String subtitle, bool value, Function(bool) onChanged, Color color) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
        Switch(
          value: value,
          onChanged: onChanged,
          activeColor: const Color(0xFFFF6B00),
        ),
      ],
    );
  }
}
