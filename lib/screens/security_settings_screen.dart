import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Security Settings Screen - 2FA and security options
class SecuritySettingsScreen extends StatefulWidget {
  const SecuritySettingsScreen({super.key});

  @override
  State<SecuritySettingsScreen> createState() => _SecuritySettingsScreenState();
}

class _SecuritySettingsScreenState extends State<SecuritySettingsScreen> {
  bool _twoFactorAuth = false;
  bool _biometricAuth = true;
  bool _loginAlerts = true;

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
          'Security',
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
            // Authentication Methods
            _buildSection(
              'Authentication',
              [
                _buildSwitchTile(
                  Icons.security,
                  'Two-Factor Authentication',
                  'Add an extra layer of security',
                  _twoFactorAuth,
                  (value) {
                    setState(() => _twoFactorAuth = value);
                    if (value) {
                      _show2FASetup();
                    }
                  },
                  Colors.green,
                ),
                const Divider(height: 24),
                _buildSwitchTile(
                  Icons.fingerprint,
                  'Biometric Authentication',
                  'Use fingerprint or face unlock',
                  _biometricAuth,
                  (value) => setState(() => _biometricAuth = value),
                  Colors.purple,
                ),
              ],
            ),
            const SizedBox(height: 20),
            
            // Security Alerts
            _buildSection(
              'Alerts',
              [
                _buildSwitchTile(
                  Icons.notifications_active,
                  'Login Alerts',
                  'Get notified of new logins',
                  _loginAlerts,
                  (value) => setState(() => _loginAlerts = value),
                  Colors.orange,
                ),
              ],
            ),
            const SizedBox(height: 20),
            
            // Active Sessions
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Active Sessions',
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: Text('End All Sessions?', style: GoogleFonts.poppins()),
                              content: Text(
                                'You will be logged out of all devices except this one.',
                                style: GoogleFonts.poppins(),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: Text('Cancel', style: GoogleFonts.poppins()),
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('All other sessions ended')),
                                    );
                                  },
                                  child: Text('End All', style: GoogleFonts.poppins(color: Colors.red)),
                                ),
                              ],
                            ),
                          );
                        },
                        child: Text(
                          'End All',
                          style: GoogleFonts.poppins(color: Colors.red),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  _buildSessionItem(
                    'Linux Desktop',
                    'Current device',
                    Icons.computer,
                    true,
                  ),
                  const SizedBox(height: 12),
                  _buildSessionItem(
                    'iPhone 15 Pro',
                    'Last active 2 hours ago',
                    Icons.phone_iphone,
                    false,
                  ),
                  const SizedBox(height: 12),
                  _buildSessionItem(
                    'Chrome on Windows',
                    'Last active 1 day ago',
                    Icons.laptop_windows,
                    false,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _show2FASetup() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.security, size: 48, color: Colors.green.shade700),
            ),
            const SizedBox(height: 20),
            Text(
              'Setup Two-Factor Authentication',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Scan this QR code with your authenticator app',
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Icon(Icons.qr_code_2, size: 150, color: Colors.grey.shade400),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF6B00),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: Text(
                  'Done',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
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

  Widget _buildSessionItem(String device, String info, IconData icon, bool isCurrent) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isCurrent ? Colors.green.shade50 : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isCurrent ? Colors.green.shade200 : Colors.grey.shade200,
        ),
      ),
      child: Row(
        children: [
          Icon(icon, color: isCurrent ? Colors.green.shade700 : Colors.grey.shade600),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  device,
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
                Text(
                  info,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          if (!isCurrent)
            IconButton(
              icon: const Icon(Icons.close, color: Colors.red, size: 20),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Ended session on $device')),
                );
              },
            ),
        ],
      ),
    );
  }
}
