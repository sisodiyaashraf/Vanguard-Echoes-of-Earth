import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vanguard_echoes_of_earth/game/core/save_manager.dart';
import 'package:vanguard_echoes_of_earth/game/levels/level_registry.dart';

class LevelSelectScreen extends StatelessWidget {
  const LevelSelectScreen({super.key});

  Color _getHeroColor(String heroId) {
    switch (heroId.toLowerCase()) {
      case 'dragon':
        return const Color(0xFFFF4500);
      case 't-rex':
        return const Color(0xFFFFD700);
      case 'curator':
        return const Color(0xFF9400D3);
      case 'shark':
        return const Color(0xFF1E90FF);
      case 'kitsune':
        return const Color(0xFF00FFCC);
      default:
        return const Color(0xFFFF007F);
    }
  }

  @override
  Widget build(BuildContext context) {
    final heroId = ModalRoute.of(context)!.settings.arguments as String;
    final heroColor = _getHeroColor(heroId);

    final filteredLevels = LevelRegistry.levels.where((level) {
      return level.heroId.toLowerCase() == heroId.toLowerCase();
    }).toList();

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
          '${heroId.toUpperCase()} MISSIONS',
          style: GoogleFonts.pressStart2p(
            color: const Color(0xFF00FFCC),
            fontSize: 12,
            fontWeight: FontWeight.bold,
            letterSpacing: 2.0,
          ),
        ),
        centerTitle: true,
      ),
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 600),
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 24),
            physics: const BouncingScrollPhysics(),
            itemCount: filteredLevels.length,
            itemBuilder: (context, index) {
              final level = filteredLevels[index];
              final levelNum = level.id.split('_').last;
              final formattedLvl = int.tryParse(levelNum) != null
                  ? 'LVL ${levelNum.padLeft(2, '0')}'
                  : 'MISSION';

              final isUnlocked = index == 0 || SaveManager.isLevelCompleted(filteredLevels[index - 1].id);
              final isCompleted = SaveManager.isLevelCompleted(level.id);

              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: isUnlocked ? const Color(0xFF1E222B) : const Color(0xFF111218),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isUnlocked
                        ? heroColor.withValues(alpha: 0.3)
                        : Colors.white10,
                    width: 1.5,
                  ),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  enabled: isUnlocked,
                  leading: isUnlocked
                      ? (isCompleted
                          ? const Icon(Icons.check_circle, color: Color(0xFF00FFCC), size: 28)
                          : Icon(Icons.play_circle_fill, color: heroColor, size: 28))
                      : const Icon(Icons.lock, color: Colors.white24, size: 28),
                  title: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        formattedLvl,
                        style: GoogleFonts.pressStart2p(
                          color: isUnlocked ? heroColor : Colors.white24,
                          fontWeight: FontWeight.bold,
                          fontSize: 9,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        level.displayName.toUpperCase(),
                        style: GoogleFonts.pressStart2p(
                          color: isUnlocked ? Colors.white : Colors.white24,
                          fontWeight: FontWeight.bold,
                          fontSize: 10,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ],
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                      level.heroId == 'team'
                          ? 'Full squad campaign. Switch heroes mid-battle.'
                          : 'Solo deployment for ${level.heroId.toUpperCase()}.',
                      style: GoogleFonts.vt323(
                        color: isUnlocked ? Colors.white60 : Colors.white24,
                        fontSize: 14,
                        letterSpacing: 1.0,
                      ),
                    ),
                  ),
                  onTap: isUnlocked
                      ? () {
                          Navigator.pushNamed(
                            context,
                            '/game',
                            arguments: level,
                          );
                        }
                      : null,
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
