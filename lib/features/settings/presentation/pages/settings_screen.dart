import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/utils/audio_manager.dart';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _isSoundEnabled = true;
  bool _isMusicEnabled = true;
  bool _isVibrationEnabled = true;
  String _graphicsQuality = 'High';

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isSoundEnabled = prefs.getBool('sound_enabled') ?? true;
      _isMusicEnabled = prefs.getBool('music_enabled') ?? true;
      _isVibrationEnabled = prefs.getBool('vibration_enabled') ?? true;
      _graphicsQuality = prefs.getString('graphics') ?? 'High';
    });
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('sound_enabled', _isSoundEnabled);
    await prefs.setBool('music_enabled', _isMusicEnabled);
    await prefs.setBool('vibration_enabled', _isVibrationEnabled);
    await prefs.setString('graphics', _graphicsQuality);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              const Color(0xFF4B0082),
              Colors.black,
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Stack(
          children: [
            // Background
            Positioned.fill(
              child: Image.asset(
                'assets/images/bg_1.png',
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const SizedBox.shrink(),
              ),
            ),

            // Dark overlay
            Positioned.fill(
              child: Container(
                color: Colors.black.withOpacity(0.6),
              ),
            ),

            // Content
            SafeArea(
              child: Column(
                children: [
                  // Header
                  _buildHeader(),

                  // Settings list
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.all(20),
                      children: [
                        _buildSectionTitle('AUDIO'),
                        _buildSoundToggle(),
                        const SizedBox(height: 12),
                        _buildMusicToggle(),

                        const SizedBox(height: 24),

                        _buildSectionTitle('GRAPHICS'),
                        _buildGraphicsSelector(),

                        const SizedBox(height: 24),

                        _buildSectionTitle('FEEDBACK'),
                        _buildVibrationToggle(),

                        const SizedBox(height: 32),

                        _buildResetButton(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          IconButton(
            onPressed: () {
              SoundService().playClick();
              Navigator.of(context).pop();
            },
            icon: const Icon(
              Icons.arrow_back,
              color: Color(0xFFFFD700),
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          const Text(
            'SETTINGS',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFFFFD700),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.white.withOpacity(0.6),
          letterSpacing: 1.5,
        ),
      ),
    );
  }

  Widget _buildSoundToggle() {
    return _buildToggleCard(
      icon: Icons.volume_up,
      title: 'Sound Effects',
      subtitle: 'Game sounds and effects',
      value: _isSoundEnabled,
      onChanged: (value) {
        setState(() {
          _isSoundEnabled = value;
        });
        _saveSettings();
        SoundService().setMuted(!value);
        if (value) {
          SoundService().playClick();
        }
      },
    );
  }

  Widget _buildMusicToggle() {
    return _buildToggleCard(
      icon: Icons.music_note,
      title: 'Music',
      subtitle: 'Background music',
      value: _isMusicEnabled,
      onChanged: (value) {
        setState(() {
          _isMusicEnabled = value;
        });
        _saveSettings();
        SoundService().playClick();
      },
    );
  }

  Widget _buildVibrationToggle() {
    return _buildToggleCard(
      icon: Icons.vibration,
      title: 'Vibration',
      subtitle: 'Haptic feedback',
      value: _isVibrationEnabled,
      onChanged: (value) {
        setState(() {
          _isVibrationEnabled = value;
        });
        _saveSettings();
        SoundService().playClick();
      },
    );
  }

  Widget _buildToggleCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required Function(bool) onChanged,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: value
              ? [
            Colors.purple.shade700.withOpacity(0.8),
            Colors.purple.shade800.withOpacity(0.9),
          ]
              : [
            Colors.grey.shade800.withOpacity(0.6),
            Colors.grey.shade900.withOpacity(0.7),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: value ? const Color(0xFFFFD700) : Colors.grey.shade700,
          width: 2,
        ),
        boxShadow: value
            ? [
          BoxShadow(
            color: const Color(0xFFFFD700).withOpacity(0.3),
            blurRadius: 12,
            spreadRadius: 2,
          ),
        ]
            : null,
      ),
      child: Row(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: value
                  ? const Color(0xFFFFD700).withOpacity(0.2)
                  : Colors.grey.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: value ? const Color(0xFFFFD700) : Colors.grey,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: value ? Colors.white : Colors.grey.shade400,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: value
                        ? Colors.white.withOpacity(0.7)
                        : Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: const Color(0xFFFFD700),
            activeTrackColor: const Color(0xFFFFD700).withOpacity(0.5),
            inactiveThumbColor: Colors.grey.shade600,
            inactiveTrackColor: Colors.grey.shade800,
          ),
        ],
      ),
    );
  }

  Widget _buildGraphicsSelector() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.purple.shade800.withOpacity(0.6),
            Colors.purple.shade900.withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFFFD700),
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFD700).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.high_quality,
                  color: Color(0xFFFFD700),
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Graphics Quality',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Visual quality settings',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildGraphicsButton('Low'),
              const SizedBox(width: 8),
              _buildGraphicsButton('Medium'),
              const SizedBox(width: 8),
              _buildGraphicsButton('High'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGraphicsButton(String quality) {
    final isSelected = _graphicsQuality == quality;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _graphicsQuality = quality;
          });
          _saveSettings();
          SoundService().playClick();
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isSelected
                  ? [const Color(0xFFFFD700), const Color(0xFFFF8C00)]
                  : [Colors.grey.shade700, Colors.grey.shade800],
            ),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected ? const Color(0xFFFFD700) : Colors.grey.shade600,
              width: isSelected ? 2 : 1,
            ),
            boxShadow: isSelected
                ? [
              BoxShadow(
                color: const Color(0xFFFFD700).withOpacity(0.4),
                blurRadius: 8,
                spreadRadius: 1,
              ),
            ]
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (isSelected)
                const Padding(
                  padding: EdgeInsets.only(right: 6),
                  child: Icon(
                    Icons.check_circle,
                    color: Colors.black,
                    size: 16,
                  ),
                ),
              Text(
                quality,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                  color: isSelected ? Colors.black : Colors.white70,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Widget _buildLanguageSelector() {
  //   return Container(
  //     padding: const EdgeInsets.all(16),
  //     decoration: BoxDecoration(
  //       gradient: LinearGradient(
  //         colors: [
  //           Colors.purple.shade800.withOpacity(0.6),
  //           Colors.purple.shade900.withOpacity(0.8),
  //         ],
  //       ),
  //       borderRadius: BorderRadius.circular(12),
  //       border: Border.all(
  //         color: const Color(0xFFFFD700),
  //         width: 2,
  //       ),
  //     ),
  //     child: Column(
  //       crossAxisAlignment: CrossAxisAlignment.start,
  //       children: [
  //         Row(
  //           children: [
  //             Container(
  //               padding: const EdgeInsets.all(10),
  //               decoration: BoxDecoration(
  //                 color: const Color(0xFFFFD700).withOpacity(0.2),
  //                 borderRadius: BorderRadius.circular(10),
  //               ),
  //               child: const Icon(
  //                 Icons.language,
  //                 color: Color(0xFFFFD700),
  //                 size: 24,
  //               ),
  //             ),
  //             const SizedBox(width: 16),
  //             const Expanded(
  //               child: Column(
  //                 crossAxisAlignment: CrossAxisAlignment.start,
  //                 children: [
  //                   Text(
  //                     'Language',
  //                     style: TextStyle(
  //                       fontSize: 16,
  //                       fontWeight: FontWeight.bold,
  //                       color: Colors.white,
  //                     ),
  //                   ),
  //                   SizedBox(height: 2),
  //                   Text(
  //                     'Select your language',
  //                     style: TextStyle(
  //                       fontSize: 12,
  //                       color: Colors.white70,
  //                     ),
  //                   ),
  //                 ],
  //               ),
  //             ),
  //           ],
  //         ),
  //         const SizedBox(height: 16),
  //         _buildLanguageButton('English', '🇬🇧'),
  //         const SizedBox(height: 8),
  //         _buildLanguageButton('Русский', '🇷🇺'),
  //         const SizedBox(height: 8),
  //         _buildLanguageButton('O\'zbek', '🇺🇿'),
  //       ],
  //     ),
  //   );
  // }
  //
  // Widget _buildLanguageButton(String language, String flag) {
  //   final isSelected = _selectedLanguage == language;
  //   return GestureDetector(
  //     onTap: () {
  //       setState(() {
  //         _selectedLanguage = language;
  //       });
  //       _saveSettings();
  //       SoundService().playClick();
  //
  //       // Show restart notice
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(
  //           content: Text('Language changed to $language. Restart app to apply.'),
  //           backgroundColor: Colors.green,
  //           duration: const Duration(seconds: 2),
  //         ),
  //       );
  //     },
  //     child: Container(
  //       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
  //       decoration: BoxDecoration(
  //         gradient: LinearGradient(
  //           colors: isSelected
  //               ? [const Color(0xFFFFD700), const Color(0xFFFF8C00)]
  //               : [Colors.grey.shade700, Colors.grey.shade800],
  //         ),
  //         borderRadius: BorderRadius.circular(8),
  //         border: Border.all(
  //           color: isSelected ? const Color(0xFFFFD700) : Colors.transparent,
  //           width: 2,
  //         ),
  //       ),
  //       child: Row(
  //         children: [
  //           Text(
  //             flag,
  //             style: const TextStyle(fontSize: 24),
  //           ),
  //           const SizedBox(width: 12),
  //           Text(
  //             language,
  //             style: TextStyle(
  //               fontSize: 14,
  //               fontWeight: FontWeight.bold,
  //               color: isSelected ? Colors.black : Colors.white,
  //             ),
  //           ),
  //           const Spacer(),
  //           if (isSelected)
  //             const Icon(
  //               Icons.check_circle,
  //               color: Colors.black,
  //               size: 20,
  //             ),
  //         ],
  //       ),
  //     ),
  //   );
  // }

  Widget _buildResetButton() {
    return GestureDetector(
      onTap: () {
        _showResetDialog();
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFE53935), Color(0xFFB71C1C)],
          ),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.red,
            width: 2,
          ),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.restore, color: Colors.white),
            SizedBox(width: 12),
            Text(
              'RESET TO DEFAULT',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showResetDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2D1B4E),
        title: const Text(
          'Reset Settings',
          style: TextStyle(color: Color(0xFFFFD700)),
        ),
        content: const Text(
          'Are you sure you want to reset all settings to default?',
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCEL'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);

              setState(() {
                _isSoundEnabled = true;
                _isMusicEnabled = true;
                _isVibrationEnabled = true;
                _graphicsQuality = 'High';
              });

              await _saveSettings();
              SoundService().playClick();

              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Settings reset to default'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('RESET'),
          ),
        ],
      ),
    );
  }
}