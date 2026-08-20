import 'package:flutter/material.dart';
import 'package:vanguard_echoes_of_earth/game/vanguard_game.dart';
import 'package:vanguard_echoes_of_earth/game/levels/level_registry.dart';

class LevelSelectionOverlay extends StatefulWidget {
  final VanguardGame game;

  const LevelSelectionOverlay({super.key, required this.game});

  @override
  State<LevelSelectionOverlay> createState() => _LevelSelectionOverlayState();
}

class _LevelSelectionOverlayState extends State<LevelSelectionOverlay> {
  String selectedFilter = 'All';

  final List<String> filters = [
    'All',
    'Dragon',
    'T-Rex',
    'Curator',
    'Shark',
    'Kitsune',
    'Team',
  ];

  Color _getHeroColor(String heroId) {
    switch (heroId.toLowerCase()) {
      case 'dragon':
        return const Color(0xFFFF4500); // Orange-Red
      case 't-rex':
        return const Color(0xFFFFD700); // Gold / Amber
      case 'curator':
        return const Color(0xFF9400D3); // Deep Violet
      case 'shark':
        return const Color(0xFF1E90FF); // Dodger Blue
      case 'kitsune':
        return const Color(0xFF00FFCC); // Neon Cyan
      default:
        return const Color(0xFFFF007F); // Neon Pink (Team)
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredLevels = LevelRegistry.levels.where((level) {
      if (selectedFilter == 'All') return true;
      return level.heroId.toLowerCase() == selectedFilter.toLowerCase();
    }).toList();

    return Material(
      color: Colors.black.withValues(alpha: 0.85),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 900, maxHeight: 600),
          margin: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFF111218),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: const Color(0xFF00FFCC).withValues(alpha: 0.3),
              width: 2.0,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF00FFCC).withValues(alpha: 0.15),
                blurRadius: 20,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'MISSION BRIEFINGS',
                      style: TextStyle(
                        color: Color(0xFF00FFCC),
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2.0,
                        shadows: [
                          Shadow(
                            color: Color(0xFF00FFCC),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white, size: 28),
                      onPressed: () {
                        widget.game.overlays.remove('level_selection');
                      },
                    ),
                  ],
                ),
              ),

              // Filter Tabs
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: filters.map((filter) {
                    final isSelected = selectedFilter == filter;
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      child: ChoiceChip(
                        label: Text(
                          filter.toUpperCase(),
                          style: TextStyle(
                            color: isSelected ? Colors.black : Colors.white70,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                            letterSpacing: 1.0,
                          ),
                        ),
                        selected: isSelected,
                        selectedColor: const Color(0xFF00FFCC),
                        backgroundColor: const Color(0xFF1E222B),
                        onSelected: (selected) {
                          if (selected) {
                            setState(() {
                              selectedFilter = filter;
                            });
                          }
                        },
                      ),
                    );
                  }).toList(),
                ),
              ),

              const SizedBox(height: 12),

              // Level List
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  physics: const BouncingScrollPhysics(),
                  itemCount: filteredLevels.length,
                  itemBuilder: (context, index) {
                    final level = filteredLevels[index];
                    final heroColor = _getHeroColor(level.heroId);

                    // Extract level display ID (e.g. dragon_1 -> 01)
                    final levelNum = level.id.split('_').last;
                    final formattedLvl = int.tryParse(levelNum) != null
                        ? 'LVL ${levelNum.padLeft(2, '0')}'
                        : 'MISSION';

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E222B),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: heroColor.withValues(alpha: 0.2),
                          width: 1.5,
                        ),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                        title: Row(
                          children: [
                            Text(
                              '$formattedLvl - ',
                              style: TextStyle(
                                color: heroColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            Expanded(
                              child: Text(
                                level.displayName.toUpperCase(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  letterSpacing: 1.0,
                                ),
                              ),
                            ),
                          ],
                        ),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            level.heroId == 'team'
                                ? 'Full squad campaign. Switch heroes mid-battle.'
                                : 'Solo deployment for ${level.heroId.toUpperCase()}.',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.65),
                              fontSize: 13,
                            ),
                          ),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: heroColor.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: heroColor.withValues(alpha: 0.4)),
                              ),
                              child: Text(
                                level.heroId.toUpperCase(),
                                style: TextStyle(
                                  color: heroColor,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF00FFCC),
                                foregroundColor: Colors.black,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              ),
                              onPressed: () {
                                widget.game.loadLevel(level);
                                widget.game.overlays.remove('level_selection');
                              },
                              child: const Text(
                                'LAUNCH',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
