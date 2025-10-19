import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Appearance Settings Screen - Theme selection
class AppearanceSettingsScreen extends StatefulWidget {
  const AppearanceSettingsScreen({super.key});

  @override
  State<AppearanceSettingsScreen> createState() => _AppearanceSettingsScreenState();
}

class _AppearanceSettingsScreenState extends State<AppearanceSettingsScreen> {
  String _selectedTheme = 'Light';

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
          'Appearance',
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Theme',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 16),
            
            // Light Theme
            _buildThemeOption(
              'Light',
              'Use light theme',
              Icons.light_mode,
              Colors.amber,
              [Colors.white, Colors.grey.shade100],
            ),
            const SizedBox(height: 12),
            
            // Dark Theme
            _buildThemeOption(
              'Dark',
              'Use dark theme',
              Icons.dark_mode,
              Colors.indigo,
              [Colors.grey.shade900, Colors.grey.shade800],
            ),
            const SizedBox(height: 12),
            
            // System Theme
            _buildThemeOption(
              'System',
              'Follow system settings',
              Icons.settings_system_daydream,
              Colors.purple,
              [Colors.white, Colors.grey.shade900],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThemeOption(String theme, String subtitle, IconData icon, Color color, List<Color> previewColors) {
    final isSelected = _selectedTheme == theme;
    
    return GestureDetector(
      onTap: () {
        setState(() => _selectedTheme = theme);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Theme changed to $theme mode'),
            backgroundColor: const Color(0xFFFF6B00),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: isSelected ? const Color(0xFFFF6B00) : Colors.transparent,
            width: 2,
          ),
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
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    theme,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
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
            // Theme Preview
            Container(
              width: 60,
              height: 40,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: previewColors,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade300),
              ),
            ),
            const SizedBox(width: 12),
            Icon(
              isSelected ? Icons.check_circle : Icons.circle_outlined,
              color: isSelected ? const Color(0xFFFF6B00) : Colors.grey.shade400,
              size: 28,
            ),
          ],
        ),
      ),
    );
  }
}
