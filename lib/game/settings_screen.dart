import 'package:flutter/material.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vanguard_echoes_of_earth/game/core/save_manager.dart';
import 'package:vanguard_echoes_of_earth/game/core/localization.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  double bgmVolume = 0.7;
  double sfxVolume = 0.7;
  bool highContrastVfx = false;
  bool largerText = false;
  bool leftHanded = false;

  @override
  void initState() {
    super.initState();
    bgmVolume = SaveManager.getBgmVolume();
    sfxVolume = SaveManager.getSfxVolume();
    highContrastVfx = SaveManager.isHighContrastVfx();
    largerText = SaveManager.isLargerText();
    leftHanded = SaveManager.isLeftHanded();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF111218),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF00FFCC)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          AppLocalizations.translate('settings_title'),
          style: GoogleFonts.pressStart2p(
            color: const Color(0xFF00FFCC),
            fontSize: 16,
            fontWeight: FontWeight.bold,
            letterSpacing: 2.0,
          ),
        ),
        centerTitle: true,
      ),
      body: Center(
        child: Container(
          width: 520,
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Music Volume Section
                Text(
                  AppLocalizations.translate('settings_music_volume'),
                  style: GoogleFonts.pressStart2p(
                    color: Colors.white70,
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.0,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.music_note, color: Color(0xFF00FFCC), size: 18),
                    Expanded(
                      child: Slider(
                        value: bgmVolume,
                        activeColor: const Color(0xFF00FFCC),
                        inactiveColor: Colors.white12,
                        onChanged: (val) {
                          setState(() {
                            bgmVolume = val;
                          });
                          SaveManager.saveBgmVolume(val);
                          try {
                            FlameAudio.bgm.audioPlayer.setVolume(val);
                          } catch (_) {}
                        },
                      ),
                    ),
                    Text(
                      '${(bgmVolume * 100).toInt()}%',
                      style: GoogleFonts.pressStart2p(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // SFX Volume Section
                Text(
                  AppLocalizations.translate('settings_sfx_volume'),
                  style: GoogleFonts.pressStart2p(
                    color: Colors.white70,
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.0,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.volume_up, color: Color(0xFF00FFCC), size: 18),
                    Expanded(
                      child: Slider(
                        value: sfxVolume,
                        activeColor: const Color(0xFF00FFCC),
                        inactiveColor: Colors.white12,
                        onChanged: (val) {
                          setState(() {
                            sfxVolume = val;
                          });
                          SaveManager.saveSfxVolume(val);
                        },
                      ),
                    ),
                    Text(
                      '${(sfxVolume * 100).toInt()}%',
                      style: GoogleFonts.pressStart2p(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Accessibility Section
                Text(
                  AppLocalizations.translate('settings_accessibility'),
                  style: GoogleFonts.pressStart2p(
                    color: const Color(0xFF00FFCC),
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.0,
                  ),
                ),
                const SizedBox(height: 8),

                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    AppLocalizations.translate('settings_high_contrast'),
                    style: GoogleFonts.vt323(color: Colors.white, fontSize: 16),
                  ),
                  value: highContrastVfx,
                  activeColor: const Color(0xFF00FFCC),
                  onChanged: (val) {
                    setState(() {
                      highContrastVfx = val;
                    });
                    SaveManager.setHighContrastVfx(val);
                  },
                ),

                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    AppLocalizations.translate('settings_larger_text'),
                    style: GoogleFonts.vt323(color: Colors.white, fontSize: 16),
                  ),
                  value: largerText,
                  activeColor: const Color(0xFF00FFCC),
                  onChanged: (val) {
                    setState(() {
                      largerText = val;
                    });
                    SaveManager.setLargerText(val);
                  },
                ),

                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    AppLocalizations.translate('settings_left_handed'),
                    style: GoogleFonts.vt323(color: Colors.white, fontSize: 16),
                  ),
                  value: leftHanded,
                  activeColor: const Color(0xFF00FFCC),
                  onChanged: (val) {
                    setState(() {
                      leftHanded = val;
                    });
                    SaveManager.setLeftHanded(val);
                  },
                ),
                const SizedBox(height: 24),

                // Reset Tutorial Button
                Center(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1F2937),
                      side: const BorderSide(color: Color(0xFF00FFCC), width: 1.5),
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                    onPressed: () async {
                      await SaveManager.setHasSeenTutorial(false);
                      await SaveManager.setHasSeenTeamTutorial(false);
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'TUTORIAL RESET! PLAY ANY LEVEL TO REPLAY.',
                              style: GoogleFonts.pressStart2p(fontSize: 8, color: Colors.black),
                            ),
                            backgroundColor: const Color(0xFF00FFCC),
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      }
                    },
                    child: Text(
                      'REPLAY TUTORIAL',
                      style: GoogleFonts.pressStart2p(
                        color: const Color(0xFF00FFCC),
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
