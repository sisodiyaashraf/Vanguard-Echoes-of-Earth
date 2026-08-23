import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vanguard_echoes_of_earth/game/core/save_manager.dart';
import 'package:vanguard_echoes_of_earth/game/progression/daily_challenge.dart';
import 'package:vanguard_echoes_of_earth/game/modes/survival_config.dart';
import 'package:vanguard_echoes_of_earth/game/core/localization.dart';

class MainMenuScreen extends StatelessWidget {
  const MainMenuScreen({super.key});

  void _checkDailyChallengeRotation() {
    final todayStr = DateTime.now().toIso8601String().substring(0, 10);
    final savedDate = SaveManager.getLastChallengeDate();
    if (savedDate != todayStr) {
      final list = ['defeat_20_enemies', 'complete_2_levels', 'defeat_boss_no_power'];
      final nextIndex = DateTime.now().day % list.length;
      final newChallengeId = list[nextIndex];

      SaveManager.saveCurrentChallengeId(newChallengeId);
      SaveManager.saveDailyChallengeProgress(0);
      SaveManager.setDailyChallengeCompleted(false);
      SaveManager.saveLastChallengeDate(todayStr);
    }
  }

  @override
  Widget build(BuildContext context) {
    _checkDailyChallengeRotation();
    final showQuit = !kIsWeb && (Platform.isAndroid || Platform.isWindows);

    // Get current challenge details
    final challengeId = SaveManager.getCurrentChallengeId();
    final progress = SaveManager.getDailyChallengeProgress();
    final isCompleted = SaveManager.isDailyChallengeCompleted();
    final challenge = DailyChallenge.getChallengeById(challengeId);

    return Scaffold(
      backgroundColor: const Color(0xFF111218),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 16.0),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 960),
            child: Row(
              children: [
                // Left Side: Title & Menu Buttons
                Expanded(
                  flex: 5,
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Game Logo Icon
                        Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: const Color(0xFF00FFCC).withValues(alpha: 0.3),
                              width: 2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF00FFCC).withValues(alpha: 0.1),
                                blurRadius: 15,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(18),
                            child: Image.asset(
                              'assets/images/characters/Hero 1 Dragon — Kinetic Scales.png',
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        // Title
                        Text(
                          'VANGUARD',
                          style: GoogleFonts.pressStart2p(
                            color: const Color(0xFF00FFCC),
                            fontSize: 26,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 4.0,
                            shadows: [
                              const Shadow(
                                color: Color(0xFF00FFCC),
                                blurRadius: 12,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'ECHOES OF EARTH',
                          style: GoogleFonts.pressStart2p(
                            color: Colors.white70,
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2.0,
                          ),
                        ),
                        const SizedBox(height: 36),
                        // Buttons
                        _buildMenuButton(
                          context,
                          AppLocalizations.translate('menu_play'),
                          const Color(0xFF00FFCC),
                          Colors.black,
                          () => Navigator.pushNamed(context, '/hero-select'),
                        ),
                        const SizedBox(height: 12),
                        // Boss Rush button
                        _buildMenuButton(
                          context,
                          SaveManager.isBossRushUnlocked()
                              ? AppLocalizations.translate('menu_boss_rush')
                              : '${AppLocalizations.translate('menu_boss_rush')} (${AppLocalizations.translate('menu_locked')})',
                          SaveManager.isBossRushUnlocked() ? const Color(0xFFFF9800) : Colors.white10,
                          SaveManager.isBossRushUnlocked() ? Colors.black : Colors.white24,
                          () {
                            if (SaveManager.isBossRushUnlocked()) {
                              Navigator.pushNamed(context, '/hero-select', arguments: 'boss_rush');
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'LOCKED: CLEAR ALL 5 CAMPAIGN BOSSES TO PLAY!',
                                    style: GoogleFonts.pressStart2p(fontSize: 8, color: Colors.black),
                                  ),
                                  backgroundColor: const Color(0xFFFF5252),
                                ),
                              );
                            }
                          },
                        ),
                        const SizedBox(height: 12),
                        // Survival button
                        _buildMenuButton(
                          context,
                          AppLocalizations.translate('menu_survival'),
                          const Color(0xFF9C27B0),
                          Colors.white,
                          () {
                            final config = SurvivalConfig();
                            Navigator.pushNamed(context, '/game', arguments: config);
                          },
                        ),
                        const SizedBox(height: 12),
                        _buildMenuButton(
                          context,
                          AppLocalizations.translate('menu_achievements'),
                          Colors.white,
                          Colors.black,
                          () => Navigator.pushNamed(context, '/achievements'),
                        ),
                        const SizedBox(height: 12),
                        _buildMenuButton(
                          context,
                          AppLocalizations.translate('menu_settings'),
                          Colors.white,
                          Colors.black,
                          () => Navigator.pushNamed(context, '/settings'),
                        ),
                        if (showQuit) ...[
                          const SizedBox(height: 12),
                          _buildMenuButton(
                            context,
                            AppLocalizations.translate('menu_quit'),
                            Colors.white10,
                            Colors.white70,
                            () => SystemNavigator.pop(),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 32),
                // Right Side: Daily Challenge Card
                Expanded(
                  flex: 4,
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.all(20.0),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E222B),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isCompleted ? const Color(0xFF00FFCC) : Colors.white12,
                          width: 2.0,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: isCompleted
                                ? const Color(0xFF00FFCC).withValues(alpha: 0.15)
                                : Colors.black.withValues(alpha: 0.3),
                            blurRadius: 15,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'DAILY MISSION',
                                style: GoogleFonts.pressStart2p(
                                  color: isCompleted ? const Color(0xFF00FFCC) : Colors.white70,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.0,
                                ),
                              ),
                              Icon(
                                isCompleted ? Icons.check_circle : Icons.calendar_today,
                                color: isCompleted ? const Color(0xFF00FFCC) : Colors.white24,
                                size: 20,
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          const Divider(color: Colors.white12, thickness: 1.5),
                          const SizedBox(height: 12),
                          Text(
                            challenge.description.toUpperCase(),
                            style: GoogleFonts.vt323(
                              color: Colors.white,
                              fontSize: 18,
                              letterSpacing: 1.0,
                              height: 1.2,
                            ),
                          ),
                          const SizedBox(height: 24),
                          // Progress Text
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'PROGRESS',
                                style: GoogleFonts.pressStart2p(
                                  color: Colors.white54,
                                  fontSize: 8,
                                ),
                              ),
                              Text(
                                isCompleted
                                    ? 'COMPLETE'
                                    : '${progress.clamp(0, challenge.target)}/${challenge.target}',
                                style: GoogleFonts.pressStart2p(
                                  color: isCompleted ? const Color(0xFF00FFCC) : Colors.white,
                                  fontSize: 8,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          // Progress Bar
                          LinearProgressIndicator(
                            value: (progress / challenge.target).clamp(0.0, 1.0),
                            backgroundColor: Colors.white12,
                            color: isCompleted ? const Color(0xFF00FFCC) : const Color(0xFFFF9800),
                            minHeight: 10,
                            borderRadius: BorderRadius.circular(5),
                          ),
                          const SizedBox(height: 16),
                          // Reward text
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                            decoration: BoxDecoration(
                              color: const Color(0xFF111218),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.bolt,
                                  color: Color(0xFFFFD700),
                                  size: 16,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  'REWARD: +250 XP (LAST PLAYED HERO)',
                                  style: GoogleFonts.vt323(
                                    color: const Color(0xFFFFD700),
                                    fontSize: 13,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
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

  Widget _buildMenuButton(
    BuildContext context,
    String text,
    Color backgroundColor,
    Color foregroundColor,
    VoidCallback onPressed,
  ) {
    return Container(
      width: 260,
      height: 44,
      decoration: BoxDecoration(
        boxShadow: backgroundColor == const Color(0xFF00FFCC)
            ? [
                BoxShadow(
                  color: const Color(0xFF00FFCC).withValues(alpha: 0.15),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ]
            : null,
      ),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: foregroundColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
            side: backgroundColor == Colors.white10
                ? const BorderSide(color: Colors.white24)
                : BorderSide.none,
          ),
        ),
        onPressed: onPressed,
        child: Text(
          text,
          style: GoogleFonts.pressStart2p(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.0,
          ),
        ),
      ),
    );
  }
}
