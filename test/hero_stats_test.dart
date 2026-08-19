import 'package:flutter_test/flutter_test.dart';
import 'package:vanguard_echoes_of_earth/game/core/hero_stats.dart';

void main() {
  group('HeroStats Tests', () {
    test('initial values are set correctly', () {
      final stats = HeroStats();
      expect(stats.currentHealth, 100);
      expect(stats.maxHealth, 100);
      expect(stats.currentEnergy, 100);
      expect(stats.maxEnergy, 100);
    });

    test('custom initial values work', () {
      final stats = HeroStats(maxHealth: 150, maxEnergy: 80);
      expect(stats.currentHealth, 150);
      expect(stats.maxHealth, 150);
      expect(stats.currentEnergy, 80);
      expect(stats.maxEnergy, 80);
    });

    test('takeDamage reduces health and clamps at 0', () {
      final stats = HeroStats(maxHealth: 100);
      stats.takeDamage(20);
      expect(stats.currentHealth, 80);
      
      stats.takeDamage(100);
      expect(stats.currentHealth, 0);

      stats.takeDamage(-10); // Negative damage shouldn't affect health
      expect(stats.currentHealth, 0);
    });

    test('spendEnergy returns boolean and clamps at 0', () {
      final stats = HeroStats(maxEnergy: 50);
      
      // Spend within limits
      bool success = stats.spendEnergy(20);
      expect(success, isTrue);
      expect(stats.currentEnergy, 30);

      // Spend too much
      success = stats.spendEnergy(40);
      expect(success, isFalse);
      expect(stats.currentEnergy, 30); // Unchanged

      // Spend exactly remaining
      success = stats.spendEnergy(30);
      expect(success, isTrue);
      expect(stats.currentEnergy, 0);
    });

    test('regenEnergy increases energy and clamps at max', () {
      final stats = HeroStats(maxEnergy: 100);
      stats.spendEnergy(60);
      expect(stats.currentEnergy, 40);

      stats.regenEnergy(20);
      expect(stats.currentEnergy, 60);

      stats.regenEnergy(100);
      expect(stats.currentEnergy, 100); // Clamped at maxEnergy
    });
  });
}
