import 'package:flutter/material.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:vanguard_echoes_of_earth/game/core/save_manager.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  double bgmVolume = 0.7;
  double sfxVolume = 0.7;

  @override
  void initState() {
    super.initState();
    bgmVolume = SaveManager.getBgmVolume();
    sfxVolume = SaveManager.getSfxVolume();
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
        title: const Text(
          'SETTINGS',
          style: TextStyle(
            color: Color(0xFF00FFCC),
            fontSize: 20,
            fontWeight: FontWeight.bold,
            letterSpacing: 2.0,
          ),
        ),
        centerTitle: true,
      ),
      body: Center(
        child: Container(
          width: 400,
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'MUSIC VOLUME',
                style: TextStyle(
                  color: Colors.white70,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.music_note, color: Color(0xFF00FFCC)),
                  Expanded(
                    child: Slider(
                      value: bgmVolume,
                      activeColor: const Color(0xFF00FFCC),
                      inactiveColor: Colors.white24,
                      onChanged: (val) {
                        setState(() {
                          bgmVolume = val;
                        });
                        SaveManager.saveBgmVolume(val);
                        // Update active BGM volume if playing
                        try {
                          FlameAudio.bgm.audioPlayer.setVolume(val);
                        } catch (_) {}
                      },
                    ),
                  ),
                  Text(
                    '${(bgmVolume * 100).toInt()}%',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              const Text(
                'SOUND EFFECTS VOLUME',
                style: TextStyle(
                  color: Colors.white70,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.volume_up, color: Color(0xFF00FFCC)),
                  Expanded(
                    child: Slider(
                      value: sfxVolume,
                      activeColor: const Color(0xFF00FFCC),
                      inactiveColor: Colors.white24,
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
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
