import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'vanguard_game.dart';
import 'core/tutorial_controller.dart';

class TutorialOverlay extends StatelessWidget {
  final VanguardGame game;

  const TutorialOverlay({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    final controller = TutorialController.instance;
    if (!controller.active) return const SizedBox.shrink();

    String prompt = '';
    double? left, right, top, bottom;

    switch (controller.currentStep) {
      case TutorialStep.move:
        prompt = 'MOVE: USE JOYSTICK (BOTTOM-LEFT) OR A/D KEYS';
        left = 32;
        bottom = 200;
        break;
      case TutorialStep.jump:
        prompt = 'JUMP: PRESS JUMP BUTTON (RIGHT-MIDDLE) OR SPACE / W';
        right = 32;
        bottom = 250;
        break;
      case TutorialStep.attack:
        prompt = 'ATTACK: PRESS ATTACK (RIGHT-CENTER) OR F / J TO DEFEAT THE DUMMY';
        right = 32;
        bottom = 190;
        break;
      case TutorialStep.power:
        prompt = 'POWER: PRESS POWER (RIGHT-BOTTOM) OR K TO USE SPECIAL POWER';
        right = 32;
        bottom = 130;
        break;
      case TutorialStep.swap:
        prompt = 'SWAP: PRESS SWAP BUTTON (TOP-RIGHT) OR TAB / Q TO CYCLE HEROES';
        right = 140;
        top = 28;
        break;
      default:
        return const SizedBox.shrink();
    }

    return Stack(
      children: [
        // --- TOOLTIP BUBBLE ---
        Positioned(
          left: left,
          right: right,
          top: top,
          bottom: bottom,
          child: Material(
            color: Colors.transparent,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              constraints: const BoxConstraints(maxWidth: 320),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.85),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: const Color(0xFF00FFCC),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF00FFCC).withValues(alpha: 0.25),
                    blurRadius: 10,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: Text(
                prompt,
                style: GoogleFonts.pressStart2p(
                  color: const Color(0xFF00FFCC),
                  fontSize: 7.5,
                  height: 1.5,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),

        // --- SKIP BUTTON (Top Center) ---
        Positioned(
          top: 16,
          left: MediaQuery.of(context).size.width / 2 - 80,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => controller.skipTutorial(game),
              borderRadius: BorderRadius.circular(6),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.7),
                  border: Border.all(color: Colors.white38, width: 1.0),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'SKIP TUTORIAL',
                  style: GoogleFonts.pressStart2p(
                    color: Colors.white70,
                    fontSize: 7,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
