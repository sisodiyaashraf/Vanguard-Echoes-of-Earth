import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flame/widgets.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vanguard_echoes_of_earth/game/vanguard_game.dart';
import 'package:vanguard_echoes_of_earth/game/core/ui_constants.dart';
import 'package:vanguard_echoes_of_earth/game/components/hollow_boss.dart';

class GameHud extends StatefulWidget {
  final VanguardGame game;

  const GameHud({super.key, required this.game});

  @override
  State<GameHud> createState() => _GameHudState();
}

class _GameHudState extends State<GameHud> with SingleTickerProviderStateMixin {
  late final Ticker _ticker;

  @override
  void initState() {
    super.initState();
    _ticker = createTicker((_) {
      if (mounted) {
        setState(() {});
      }
    });
    _ticker.start();
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  Color _getHeroColor(String heroName) {
    switch (heroName.toLowerCase()) {
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
    if (!widget.game.isLoaded || widget.game.heroes.isEmpty) {
      return const SizedBox.shrink();
    }

    final hero = widget.game.activeHero;
    final stats = hero.stats;
    final activeHeroColor = _getHeroColor(hero.heroName);

    final healthPercent = (stats.currentHealth / stats.maxHealth).clamp(0.0, 1.0);
    final energyPercent = (stats.currentEnergy / stats.maxEnergy).clamp(0.0, 1.0);

    final boss = widget.game.world.children.whereType<HollowBoss>().firstOrNull;
    final showBoss = boss != null && boss.health > 0;

    final powerCooldown = hero.powerCooldownRemaining;
    final powerMaxCooldown = hero.powerCooldown;
    final powerCooldownPercent = (powerCooldown / powerMaxCooldown).clamp(0.0, 1.0);

    return Stack(
      children: [
          // --- TOP-LEFT COMPACT HUD PANEL ---
          Positioned(
            left: 16,
            top: 16,
            child: SafeArea(
              left: false,
              right: false,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 8.0),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.65),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: activeHeroColor.withValues(alpha: 0.4),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: activeHeroColor.withValues(alpha: 0.15),
                      blurRadius: 10,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: Image.asset(
                            'assets/app_icon/app_icon.jpg',
                            width: 16,
                            height: 16,
                            fit: BoxFit.cover,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'VANGUARD',
                          style: GoogleFonts.pressStart2p(
                            color: activeHeroColor,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 12),
                        GestureDetector(
                          onTap: () {
                            Navigator.pop(context);
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: activeHeroColor.withValues(alpha: 0.5),
                                width: 1.0,
                              ),
                              borderRadius: BorderRadius.circular(4),
                              color: activeHeroColor.withValues(alpha: 0.1),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.exit_to_app,
                                  size: 10,
                                  color: activeHeroColor,
                                ),
                                const SizedBox(width: 3),
                                Text(
                                  'EXIT',
                                  style: GoogleFonts.pressStart2p(
                                    color: activeHeroColor,
                                    fontSize: 6,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // Health row
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          width: 16,
                          height: 16,
                          child: SpriteWidget(sprite: widget.game.heartSprite),
                        ),
                        const SizedBox(width: 6),
                        _buildProgressBar(
                          width: UiConstants.barWidth,
                          height: UiConstants.barHeight,
                          percentage: healthPercent,
                          fillColor: const LinearGradient(
                            colors: [
                              UiConstants.healthRed,
                              Color(0xFFFF8A80),
                            ],
                          ),
                          label: '${stats.currentHealth}',
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),

                    // Energy row
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          width: 16,
                          height: 16,
                          child: SpriteWidget(sprite: widget.game.energySprite),
                        ),
                        const SizedBox(width: 6),
                        _buildProgressBar(
                          width: UiConstants.barWidth,
                          height: UiConstants.barHeight,
                          percentage: energyPercent,
                          fillColor: const LinearGradient(
                            colors: [
                              UiConstants.energyBlue,
                              Color(0xFFFFD54F),
                            ],
                          ),
                          label: '${stats.currentEnergy}',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          // --- BOTTOM-RIGHT ABILITY ICONS ---
          Positioned(
            right: 280,
            bottom: 75,
            child: SafeArea(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildAbilityIcon(
                    sprite: widget.game.meleeSprite,
                    cooldownPercent: 0,
                    cooldownText: '',
                    glowColor: Colors.orange.withValues(alpha: 0.5),
                    isReady: !hero.isAttacking,
                  ),
                  const SizedBox(width: 8),
                  _buildAbilityIcon(
                    sprite: _getPowerSprite(widget.game),
                    cooldownPercent: powerCooldownPercent,
                    cooldownText: powerCooldown > 0 ? '${powerCooldown.toStringAsFixed(1)}s' : '',
                    glowColor: activeHeroColor.withValues(alpha: 0.5),
                    isReady: powerCooldown <= 0 && stats.currentEnergy >= hero.powerEnergyCost,
                  ),
                ],
              ),
            ),
          ),
          if (showBoss)
            Positioned(
              top: 16,
              left: MediaQuery.of(context).size.width / 2 - 175,
              child: SafeArea(
                child: Container(
                  width: 350,
                  padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 8.0),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.75),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: const Color(0xFFFF3333).withValues(alpha: 0.5),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFFF3333).withValues(alpha: 0.2),
                        blurRadius: 10,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _getBossName(boss.bossType),
                        style: GoogleFonts.pressStart2p(
                          color: const Color(0xFFFF3333),
                          fontSize: 8,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),
                      _buildProgressBar(
                        width: 330,
                        height: 10,
                        percentage: (boss.health / boss.maxHealth).clamp(0.0, 1.0),
                        fillColor: const LinearGradient(
                          colors: [
                            Color(0xFFD32F2F),
                            Color(0xFFFF5252),
                          ],
                        ),
                        label: '${boss.health} / ${boss.maxHealth}',
                      ),
                    ],
                  ),
                ),
              ),
            ),
          if (widget.game.isBossRush)
            Positioned(
              top: 16,
              left: MediaQuery.of(context).size.width / 2 - 80,
              child: SafeArea(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.7),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFFF9800), width: 1.5),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.timer, color: Color(0xFFFF9800), size: 14),
                      const SizedBox(width: 6),
                      Text(
                        'TIME: ${widget.game.bossRushElapsedTime.toStringAsFixed(1)}s',
                        style: GoogleFonts.pressStart2p(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          if (widget.game.isSurvival)
            Positioned(
              top: 16,
              right: 16,
              child: SafeArea(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.7),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFF9C27B0), width: 1.5),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'WAVE: ${widget.game.survivalWavesSurvived}',
                        style: GoogleFonts.pressStart2p(
                          color: const Color(0xFF00FFCC),
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'KILLS: ${widget.game.survivalEnemiesDefeated}',
                        style: GoogleFonts.pressStart2p(
                          color: Colors.white70,
                          fontSize: 7,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      );
  }

  String _getBossName(String type) {
    switch (type.toLowerCase()) {
      case 'dragon':
        return 'VOLCANIC HARBINGER';
      case 't-rex':
        return 'SEISMIC COLOSSUS';
      case 'curator':
        return 'TEMPORAL ANOMALIST';
      case 'shark':
        return 'ABYSSAL LEVIATHAN';
      case 'kitsune':
        return 'SPECTRAL KITSUNE';
      default:
        return 'HOLLOW ENEMY';
    }
  }

  Sprite _getPowerSprite(VanguardGame game) {
    switch (game.activeHeroIndex) {
      case 0:
        return game.plasmaSprite;
      case 1:
        return game.meleeSprite;
      case 2:
        return game.plasmaSprite;
      case 3:
        return game.runSprite;
      case 4:
        return game.plasmaSprite;
      default:
        return game.plasmaSprite;
    }
  }

  Widget _buildProgressBar({
    required double width,
    required double height,
    required double percentage,
    required Gradient fillColor,
    required String label,
  }) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: const Color(0xFF1A1C23),
        borderRadius: BorderRadius.circular(2),
        border: Border.all(
          color: const Color(0xFF4A4D5A),
          width: 1.0,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(1),
        child: Stack(
          children: [
            FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: percentage,
              child: Container(
                decoration: BoxDecoration(
                  gradient: fillColor,
                ),
              ),
            ),
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.white.withValues(alpha: 0.18),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            Center(
              child: Text(
                label,
                style: GoogleFonts.pressStart2p(
                  color: Colors.white,
                  fontSize: 6,
                  fontWeight: FontWeight.bold,
                  shadows: [
                    const Shadow(
                      color: Colors.black,
                      offset: Offset(1, 1),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAbilityIcon({
    required Sprite sprite,
    required double cooldownPercent,
    required String cooldownText,
    required Color glowColor,
    required bool isReady,
  }) {
    return Container(
      width: UiConstants.abilityIconSize,
      height: UiConstants.abilityIconSize,
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(6),
        boxShadow: isReady
            ? [
                BoxShadow(
                  color: glowColor,
                  blurRadius: 6,
                  spreadRadius: 1,
                ),
              ]
            : [],
        border: Border.all(
          color: isReady ? Colors.white.withValues(alpha: 0.6) : Colors.white.withValues(alpha: 0.15),
          width: 1.0,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(5),
        child: Stack(
          children: [
            Positioned.fill(
              child: Opacity(
                opacity: isReady ? 1.0 : 0.45,
                child: SpriteWidget(sprite: sprite),
              ),
            ),
            if (cooldownPercent > 0)
              Positioned.fill(
                child: FractionallySizedBox(
                  alignment: Alignment.bottomCenter,
                  heightFactor: cooldownPercent,
                  child: Container(
                    color: Colors.black.withValues(alpha: UiConstants.abilityCooldownOpacity),
                  ),
                ),
              ),
            if (cooldownText.isNotEmpty)
              Center(
                child: Text(
                  cooldownText,
                  style: GoogleFonts.pressStart2p(
                    color: Colors.white,
                    fontSize: 7,
                    fontWeight: FontWeight.bold,
                    shadows: [
                      const Shadow(
                        color: Colors.black,
                        offset: Offset(1, 1),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
