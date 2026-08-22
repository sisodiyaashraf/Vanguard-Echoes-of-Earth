import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vanguard_echoes_of_earth/game/core/save_manager.dart';
import 'package:vanguard_echoes_of_earth/game/progression/skill_node.dart';
import 'package:vanguard_echoes_of_earth/game/progression/hero_progress.dart';

class SkillTreeScreen extends StatefulWidget {
  const SkillTreeScreen({super.key});

  @override
  State<SkillTreeScreen> createState() => _SkillTreeScreenState();
}

class _SkillTreeScreenState extends State<SkillTreeScreen> {
  final List<String> heroes = ['Dragon', 'T-Rex', 'Curator', 'Shark', 'Kitsune'];
  int activeIndex = 0;

  void _cycleHero(int direction) {
    setState(() {
      activeIndex = (activeIndex + direction) % heroes.length;
    });
  }

  void _unlockSkill(HeroProgress progress, SkillNode skill) {
    if (progress.skillPoints >= skill.cost && !progress.unlockedSkillIds.contains(skill.id)) {
      setState(() {
        progress.skillPoints -= skill.cost;
        progress.unlockedSkillIds.add(skill.id);
        SaveManager.saveHeroProgress(progress);

        // Check for fully upgraded achievement
        if (progress.unlockedSkillIds.length >= 3) {
          final unlockedAch = SaveManager.getUnlockedAchievements();
          if (!unlockedAch.contains('fully_upgraded')) {
            unlockedAch.add('fully_upgraded');
            SaveManager.saveUnlockedAchievements(unlockedAch);

            // Display snackbar notification for achievement unlock
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'ACHIEVEMENT UNLOCKED: FULLY UPGRADED (Unlock all 3 skills)',
                  style: GoogleFonts.pressStart2p(fontSize: 8, color: Colors.black),
                ),
                backgroundColor: const Color(0xFF00FFCC),
              ),
            );
          }
        }
      });
    }
  }

  String _getHeroAssetPath(String name) {
    switch (name.toLowerCase()) {
      case 'dragon':
        return 'assets/images/characters/Hero 1 Dragon — Kinetic Scales.png';
      case 't-rex':
        return 'assets/images/characters/Hero 2 T-Rex (Seismic Hammer).png';
      case 'curator':
        return 'assets/images/characters/Curator (Temporal Nanotech).png';
      case 'shark':
        return 'assets/images/characters/Shark (Hydrokinetic Agility).png';
      case 'kitsune':
      default:
        return 'assets/images/characters/Kitsune (Holographic).png';
    }
  }

  Color _getHeroThemeColor(String name) {
    switch (name.toLowerCase()) {
      case 'dragon':
        return const Color(0xFFFF4500);
      case 't-rex':
        return const Color(0xFFFFD700);
      case 'curator':
        return const Color(0xFF9400D3);
      case 'shark':
        return const Color(0xFF1E90FF);
      case 'kitsune':
      default:
        return const Color(0xFF00FFCC);
    }
  }

  @override
  Widget build(BuildContext context) {
    final activeHero = heroes[activeIndex];
    final progress = SaveManager.getHeroProgress(activeHero);
    final skillNodes = SkillNode.getSkillsForHero(activeHero);
    final themeColor = _getHeroThemeColor(activeHero);

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
          'HERO UPGRADES',
          style: GoogleFonts.pressStart2p(
            color: const Color(0xFF00FFCC),
            fontSize: 14,
            fontWeight: FontWeight.bold,
            letterSpacing: 2.0,
          ),
        ),
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 960),
            child: Row(
              children: [
                // Left Column: Hero Showcase & Info
                Expanded(
                  flex: 4,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E222B),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: themeColor.withValues(alpha: 0.3),
                        width: 2,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Hero Cycling Selector
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.chevron_left, color: Color(0xFF00FFCC), size: 32),
                              onPressed: () => _cycleHero(-1),
                            ),
                            Text(
                              activeHero.toUpperCase(),
                              style: GoogleFonts.pressStart2p(
                                color: themeColor,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 2.0,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.chevron_right, color: Color(0xFF00FFCC), size: 32),
                              onPressed: () => _cycleHero(1),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        // Hero Image
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.asset(
                              _getHeroAssetPath(activeHero),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Stats Card
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFF111218),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'LEVEL ${progress.level}',
                                    style: GoogleFonts.pressStart2p(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    '${progress.skillPoints} PTS AVAILABLE',
                                    style: GoogleFonts.pressStart2p(
                                      color: const Color(0xFF00FFCC),
                                      fontSize: 8,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              // XP Progress Bar
                              LinearProgressIndicator(
                                value: (progress.xp / progress.xpToNextLevel).clamp(0.0, 1.0),
                                backgroundColor: Colors.white12,
                                color: const Color(0xFF00FFCC),
                                minHeight: 8,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              const SizedBox(height: 6),
                              Align(
                                alignment: Alignment.bottomRight,
                                child: Text(
                                  'XP ${progress.xp}/${progress.xpToNextLevel}',
                                  style: GoogleFonts.vt323(
                                    color: Colors.white70,
                                    fontSize: 12,
                                    letterSpacing: 1.0,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 24),
                // Right Column: Skill Nodes
                Expanded(
                  flex: 5,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: skillNodes.map((skill) {
                      final isUnlocked = progress.unlockedSkillIds.contains(skill.id);
                      final canUnlock = progress.skillPoints >= skill.cost && !isUnlocked;

                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E222B),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isUnlocked ? const Color(0xFF00FFCC) : Colors.white12,
                            width: 1.5,
                          ),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    skill.name,
                                    style: GoogleFonts.pressStart2p(
                                      color: isUnlocked ? const Color(0xFF00FFCC) : Colors.white70,
                                      fontSize: 9,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    skill.description,
                                    style: GoogleFonts.vt323(
                                      color: Colors.white54,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 16),
                            // Action Button
                            SizedBox(
                              width: 110,
                              height: 38,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: isUnlocked
                                      ? Colors.white10
                                      : (canUnlock ? const Color(0xFF00FFCC) : Colors.white12),
                                  foregroundColor: canUnlock ? Colors.black : Colors.white30,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  elevation: canUnlock ? 5 : 0,
                                ),
                                onPressed: canUnlock ? () => _unlockSkill(progress, skill) : null,
                                child: Text(
                                  isUnlocked
                                      ? 'UNLOCKED'
                                      : (canUnlock ? 'UNLOCK (1)' : 'LOCKED'),
                                  style: GoogleFonts.pressStart2p(
                                    fontSize: 7,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
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
