class HeroInputState {
  double keyboardMoveX = 0.0;
  double joystickMoveX = 0.0;

  double get moveX {
    if (joystickMoveX != 0.0) {
      return joystickMoveX;
    }
    return keyboardMoveX;
  }

  bool jumpPressed = false;
  bool attackPressed = false;
  bool powerPressed = false;

  void reset() {
    keyboardMoveX = 0.0;
    joystickMoveX = 0.0;
    jumpPressed = false;
    attackPressed = false;
    powerPressed = false;
  }

  void resetTriggers() {
    jumpPressed = false;
    attackPressed = false;
    powerPressed = false;
  }
}
