import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Language Settings Screen
class LanguageSettingsScreen extends StatefulWidget {
  const LanguageSettingsScreen({super.key});

  @override
  State<LanguageSettingsScreen> createState() => _LanguageSettingsScreenState();
}

class _LanguageSettingsScreenState extends State<LanguageSettingsScreen> {
  String _selectedLanguage = 'English';

  final List<Map<String, String>> _languages = [
    {'name': 'English', 'code': 'en', 'native': 'English'},
    {'name': 'Spanish', 'code': 'es', 'native': 'Español'},
    {'name': 'French', 'code': 'fr', 'native': 'Français'},
    {'name': 'German', 'code': 'de', 'native': 'Deutsch'},
    {'name': 'Italian', 'code': 'it', 'native': 'Italiano'},
    {'name': 'Portuguese', 'code': 'pt', 'native': 'Português'},
    {'name': 'Russian', 'code': 'ru', 'native': 'Русский'},
    {'name': 'Japanese', 'code': 'ja', 'native': '日本語'},
    {'name': 'Korean', 'code': 'ko', 'native': '한국어'},
    {'name': 'Chinese', 'code': 'zh', 'native': '中文'},
    {'name': 'Arabic', 'code': 'ar', 'native': 'العربية'},
    {'name': 'Hindi', 'code': 'hi', 'native': 'हिन्दी'},
  ];

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
          'Language',
          style: GoogleFonts.poppins(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: Colors.blue.shade50,
            child: Row(
              children: [
                Icon(Icons.info_outline, color: Colors.blue.shade700),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'App will restart to apply language changes',
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: Colors.blue.shade900,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _languages.length,
              itemBuilder: (context, index) {
                final language = _languages[index];
                final isSelected = language['name'] == _selectedLanguage;
                
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
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
                  child: RadioListTile<String>(
                    value: language['name']!,
                    groupValue: _selectedLanguage,
                    onChanged: (value) {
                      setState(() => _selectedLanguage = value!);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Language changed to ${language['name']}'),
                          backgroundColor: const Color(0xFFFF6B00),
                        ),
                      );
                    },
                    activeColor: const Color(0xFFFF6B00),
                    title: Text(
                      language['name']!,
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                        color: Colors.black,
                      ),
                    ),
                    subtitle: Text(
                      language['native']!,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    secondary: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: isSelected 
                            ? const Color(0xFFFF6B00).withOpacity(0.1)
                            : Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        Icons.language,
                        color: isSelected ? const Color(0xFFFF6B00) : Colors.grey.shade600,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
