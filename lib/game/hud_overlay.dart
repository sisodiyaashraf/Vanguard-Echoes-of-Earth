import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flame/widgets.dart';
import 'package:vanguard_echoes_of_earth/game/vanguard_game.dart';

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
    // Run ticker to force rebuild on every animation frame, 
    // ensuring stats and timers display in real-time.
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

  @override
  Widget build(BuildContext context) {
    // If the game or the active hero isn't fully loaded yet, render nothing.
    if (!widget.game.isLoaded) {
      return const SizedBox.shrink();
    }

    final hero = widget.game.activeHero;
    final stats = hero.stats;
    
    final healthPercent = (stats.currentHealth / stats.maxHealth).clamp(0.0, 1.0);
    final energyPercent = (stats.currentEnergy / stats.maxEnergy).clamp(0.0, 1.0);
    
    final powerCooldown = hero.powerCooldownRemaining;
    final powerMaxCooldown = hero.powerCooldown;
    final powerCooldownPercent = (powerCooldown / powerMaxCooldown).clamp(0.0, 1.0);

    return Align(
      alignment: Alignment.topLeft,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // HUD Container with premium dark glassmorphism styling
            Container(
              padding: const EdgeInsets.all(12.0),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.55),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Colors.white.withOpacity(0.12),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.4),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // --- LOGO & TITLE ---
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: Image.asset(
                          'assets/app_icon/app_icon.jpg',
                          width: 24,
                          height: 24,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'VANGUARD',
                        style: TextStyle(
                          color: Color(0xFF00FFCC),
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.5,
                          shadows: [
                            Shadow(
                              color: Color(0xFF00FFCC),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const Divider(color: Colors.white10, height: 16),

                  // --- HEALTH BAR ---
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Heart Icon wrapper
                      SizedBox(
                        width: 32,
                        height: 30,
                        child: SpriteWidget(sprite: widget.game.heartSprite),
                      ),
                      const SizedBox(width: 8),
                      // Health Bar Frame
                      _buildProgressBar(
                        width: 180,
                        height: 18,
                        percentage: healthPercent,
                        fillColor: const LinearGradient(
                          colors: [
                            Color(0xFFE53935), // Deep red
                            Color(0xFFFF5252), // Bright red
                          ],
                        ),
                        label: '${stats.currentHealth}/${stats.maxHealth}',
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // --- ENERGY BAR ---
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Lightning Bolt Icon wrapper
                      SizedBox(
                        width: 32,
                        height: 30,
                        child: SpriteWidget(sprite: widget.game.energySprite),
                      ),
                      const SizedBox(width: 8),
                      // Energy Bar Frame
                      _buildProgressBar(
                        width: 180,
                        height: 18,
                        percentage: energyPercent,
                        fillColor: const LinearGradient(
                          colors: [
                            Color(0xFF1E88E5), // Deep blue
                            Color(0xFFFFB300), // Yellow gold
                          ],
                        ),
                        label: '${stats.currentEnergy}/${stats.maxEnergy}',
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // --- ABILITY ICONS / COOLDOWNS ---
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Melee Ability Card
                _buildAbilityIcon(
                  sprite: widget.game.meleeSprite,
                  cooldownPercent: 0,
                  cooldownText: '',
                  glowColor: Colors.orange.withOpacity(0.5),
                  isReady: !hero.isAttacking,
                ),
                const SizedBox(width: 10),

                // Power Ability Card
                _buildAbilityIcon(
                  sprite: _getPowerSprite(widget.game),
                  cooldownPercent: powerCooldownPercent,
                  cooldownText: powerCooldown > 0 ? '${powerCooldown.toStringAsFixed(1)}s' : '',
                  glowColor: const Color(0xFF9C27B0).withOpacity(0.5),
                  isReady: powerCooldown <= 0 && stats.currentEnergy >= hero.powerEnergyCost,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Sprite _getPowerSprite(VanguardGame game) {
    switch (game.activeHeroIndex) {
      case 0: // Dragon
        return game.plasmaSprite;
      case 1: // T-Rex
        return game.meleeSprite;
      case 2: // Curator
        return game.plasmaSprite;
      case 3: // Shark
        return game.runSprite;
      case 4: // Kitsune
        return game.plasmaSprite;
      default:
        return game.plasmaSprite;
    }
  }

  // Helper builder for custom health/energy progress bars
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
        color: const Color(0xFF1A1C23), // Dark inner background
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: const Color(0xFF4A4D5A), // Silver/metallic bezel/frame
          width: 2.0,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(2),
        child: Stack(
          children: [
            // Filled portion
            FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: percentage,
              child: Container(
                decoration: BoxDecoration(
                  gradient: fillColor,
                ),
              ),
            ),
            // Text Label Overlay
            Center(
              child: Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  shadows: [
                    Shadow(
                      color: Colors.black,
                      offset: Offset(1, 1),
                      blurRadius: 1,
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

  // Helper builder for ability buttons with cooldown sweeps
  Widget _buildAbilityIcon({
    required Sprite sprite,
    required double cooldownPercent,
    required String cooldownText,
    required Color glowColor,
    required bool isReady,
  }) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(8),
        boxShadow: isReady
            ? [
                BoxShadow(
                  color: glowColor,
                  blurRadius: 8,
                  spreadRadius: 1,
                ),
              ]
            : [],
        border: Border.all(
          color: isReady ? Colors.white.withOpacity(0.6) : Colors.white.withOpacity(0.15),
          width: 1.5,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(6),
        child: Stack(
          children: [
            // Ability icon sprite
            Positioned.fill(
              child: Opacity(
                opacity: isReady ? 1.0 : 0.45,
                child: SpriteWidget(sprite: sprite),
              ),
            ),
            // Cooldown overlay sweep
            if (cooldownPercent > 0)
              Positioned.fill(
                child: FractionallySizedBox(
                  alignment: Alignment.bottomCenter,
                  heightFactor: cooldownPercent,
                  child: Container(
                    color: Colors.black.withOpacity(0.65),
                  ),
                ),
              ),
            // Cooldown text countdown
            if (cooldownText.isNotEmpty)
              Center(
                child: Text(
                  cooldownText,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    shadows: [
                      Shadow(
                        color: Colors.black,
                        offset: Offset(1, 1),
                        blurRadius: 2,
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
