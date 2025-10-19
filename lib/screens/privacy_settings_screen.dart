import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Privacy Settings Screen
class PrivacySettingsScreen extends StatefulWidget {
  const PrivacySettingsScreen({super.key});

  @override
  State<PrivacySettingsScreen> createState() => _PrivacySettingsScreenState();
}

class _PrivacySettingsScreenState extends State<PrivacySettingsScreen> {
  bool _profileVisibility = true;
  bool _showEmail = false;
  bool _showActivity = true;
  bool _allowTagging = true;
  bool _dataCollection = false;
  bool _personalizedAds = false;
  bool _isDownloadingData = false;

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
          'Privacy',
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
            // Profile Privacy
            _buildSection(
              'Profile Privacy',
              [
                _buildSwitchTile(
                  Icons.visibility,
                  'Public Profile',
                  'Make your profile visible to everyone',
                  _profileVisibility,
                  (value) => setState(() => _profileVisibility = value),
                ),
                const Divider(height: 24),
                _buildSwitchTile(
                  Icons.email,
                  'Show Email',
                  'Display your email on profile',
                  _showEmail,
                  (value) => setState(() => _showEmail = value),
                ),
                const Divider(height: 24),
                _buildSwitchTile(
                  Icons.timeline,
                  'Show Activity',
                  'Let others see your activity',
                  _showActivity,
                  (value) => setState(() => _showActivity = value),
                ),
              ],
            ),
            const SizedBox(height: 20),
            
            // Interactions
            _buildSection(
              'Interactions',
              [
                _buildSwitchTile(
                  Icons.tag,
                  'Allow Tagging',
                  'Let others tag you in content',
                  _allowTagging,
                  (value) => setState(() => _allowTagging = value),
                ),
              ],
            ),
            const SizedBox(height: 20),
            
            // Data & Personalization
            _buildSection(
              'Data & Personalization',
              [
                _buildSwitchTile(
                  Icons.analytics,
                  'Data Collection',
                  'Allow collection of usage data',
                  _dataCollection,
                  (value) => setState(() => _dataCollection = value),
                ),
                const Divider(height: 24),
                _buildSwitchTile(
                  Icons.ads_click,
                  'Personalized Ads',
                  'Show ads based on your interests',
                  _personalizedAds,
                  (value) => setState(() => _personalizedAds = value),
                ),
              ],
            ),
            const SizedBox(height: 20),
            
            // Data Management Buttons
            Container(
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
                    'Data Management',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  _buildActionButton(
                    'Download My Data',
                    'Request a copy of your data',
                    Icons.download,
                    Colors.blue,
                    () async {
                      setState(() {
                        _isDownloadingData = true;
                      });

                      // Simulate data download preparation
                      await Future.delayed(const Duration(seconds: 2));

                      if (!mounted) return;

                      setState(() {
                        _isDownloadingData = false;
                      });

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Data download request submitted')),
                      );
                    },
                    isLoading: _isDownloadingData,
                  ),
                  const SizedBox(height: 12),
                  
                  _buildActionButton(
                    'Delete Account',
                    'Permanently delete your account',
                    Icons.delete_forever,
                    Colors.red,
                    () {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: Text('Delete Account?', style: GoogleFonts.poppins()),
                          content: Text(
                            'This action cannot be undone. All your data will be permanently deleted.',
                            style: GoogleFonts.poppins(),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: Text('Cancel', style: GoogleFonts.poppins()),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: Text('Delete', style: GoogleFonts.poppins(color: Colors.red)),
                            ),
                          ],
                        ),
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

  Widget _buildSwitchTile(IconData icon, String title, String subtitle, bool value, Function(bool) onChanged) {
    return Row(
      children: [
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
              const SizedBox(height: 4),
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

  Widget _buildActionButton(String title, String subtitle, IconData icon, Color color, VoidCallback onTap, {bool isLoading = false}) {
    return InkWell(
      onTap: isLoading ? null : onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isLoading ? Colors.grey.withOpacity(0.05) : color.withOpacity(0.05),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: isLoading ? Colors.grey.withOpacity(0.2) : color.withOpacity(0.2)),
        ),
        child: Row(
          children: [
            isLoading 
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                    ),
                  )
                : Icon(icon, color: color),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isLoading ? Colors.grey : color,
                    ),
                  ),
                  Text(
                    isLoading ? 'Processing...' : subtitle,
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            isLoading 
                ? const SizedBox(width: 16)
                : Icon(Icons.arrow_forward_ios, size: 16, color: color),
          ],
        ),
      ),
    );
  }
}
