class HeroStats {
  int _currentHealth;
  final int _maxHealth;
  int _currentEnergy;
  final int _maxEnergy;

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

  void reset() {
    _currentHealth = _maxHealth;
    _currentEnergy = _maxEnergy;
  }

  void takeDamage(int amount) {
    if (amount <= 0) return;
    _currentHealth = (_currentHealth - amount).clamp(0, _maxHealth);
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
