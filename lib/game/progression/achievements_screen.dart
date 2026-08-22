import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vanguard_echoes_of_earth/game/core/save_manager.dart';
import 'package:vanguard_echoes_of_earth/game/progression/achievement.dart';

class AchievementsScreen extends StatelessWidget {
  const AchievementsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final unlockedIds = SaveManager.getUnlockedAchievements();
    final achievements = Achievement.getAchievements(unlockedIds: unlockedIds);

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
          'ACHIEVEMENTS',
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
            child: GridView.builder(
              physics: const BouncingScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.8,
              ),
              itemCount: achievements.length,
              itemBuilder: (context, index) {
                final ach = achievements[index];
                return Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: ach.unlocked ? const Color(0xFF1E222B) : const Color(0xFF15181F),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: ach.unlocked ? const Color(0xFF00FFCC) : Colors.white10,
                      width: 1.5,
                    ),
                    boxShadow: ach.unlocked
                        ? [
                            BoxShadow(
                              color: const Color(0xFF00FFCC).withValues(alpha: 0.1),
                              blurRadius: 10,
                              spreadRadius: 1,
                            ),
                          ]
                        : null,
                  ),
                  child: Row(
                    children: [
                      // Status Icon
                      Container(
                        padding: const EdgeInsets.all(8.0),
                        decoration: BoxDecoration(
                          color: const Color(0xFF111218),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: ach.unlocked ? const Color(0xFFFFD700) : Colors.white10,
                            width: 1.0,
                          ),
                        ),
                        child: Icon(
                          ach.unlocked ? Icons.emoji_events : Icons.lock,
                          color: ach.unlocked ? const Color(0xFFFFD700) : Colors.white24,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Info
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              ach.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.pressStart2p(
                                color: ach.unlocked ? Colors.white : Colors.white38,
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              ach.unlocked ? ach.description : '???',
                              style: GoogleFonts.vt323(
                                color: ach.unlocked ? Colors.white70 : Colors.white24,
                                fontSize: 13,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
