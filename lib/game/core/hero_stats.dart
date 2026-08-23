class HeroStats {
  int _currentHealth;
  int _maxHealth;
  int _currentEnergy;
  int _maxEnergy;

  HeroStats({
    int maxHealth = 100,
    int maxEnergy = 100,
  })  : _maxHealth = maxHealth,
        _currentHealth = maxHealth,
        _maxEnergy = maxEnergy,
        _currentEnergy = maxEnergy;

  int get currentHealth => _currentHealth;
  int get maxHealth => _maxHealth;
  int get currentEnergy => _currentEnergy;
  int get maxEnergy => _maxEnergy;

  void upgradeStats(int healthBonus, int energyBonus) {
    _maxHealth += healthBonus;
    _maxEnergy += energyBonus;
    _currentHealth = (_currentHealth + healthBonus).clamp(0, _maxHealth);
    _currentEnergy = (_currentEnergy + energyBonus).clamp(0, _maxEnergy);
  }

  void reset() {
    _currentHealth = _maxHealth;
    _currentEnergy = _maxEnergy;
  }

  void takeDamage(int amount) {
    if (amount <= 0) return;
    _currentHealth = (_currentHealth - amount).clamp(0, _maxHealth);
  }

  void heal(int amount) {
    if (amount <= 0) return;
    _currentHealth = (_currentHealth + amount).clamp(0, _maxHealth);
  }

  bool spendEnergy(int amount) {
    if (amount <= 0) return true;
    if (_currentEnergy >= amount) {
      _currentEnergy -= amount;
      return true;
    }
    return false;
  }

  void regenEnergy(int amount) {
    if (amount <= 0) return;
    _currentEnergy = (_currentEnergy + amount).clamp(0, _maxEnergy);
  }
}
