import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vanguard_echoes_of_earth/game/vanguard_game.dart';
import 'package:vanguard_echoes_of_earth/game/story/story_entry.dart';

class DialogueOverlay extends StatelessWidget {
  final VanguardGame game;

  const DialogueOverlay({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<StoryEntry?>(
      valueListenable: game.currentDialogueNotifier,
      builder: (context, currentDialogue, child) {
        if (currentDialogue == null) {
          return const SizedBox.shrink();
        }

        final isNarration = currentDialogue.portraitAssetPath == null;

        return Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: GestureDetector(
            onTap: game.advanceDialogue,
            behavior: HitTestBehavior.opaque,
            child: Container(
              width: double.infinity,
              height: 180,
              color: Colors.transparent,
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
              child: Center(
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 800),
                  padding: const EdgeInsets.all(14.0),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.85),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFF00FFCC).withValues(alpha: 0.4),
                      width: 2.0,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF00FFCC).withValues(alpha: 0.15),
                        blurRadius: 12,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (!isNarration) ...[
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Container(
                            width: 64,
                            height: 64,
                            color: Colors.grey[900],
                            child: Image.asset(
                              currentDialogue.portraitAssetPath!,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return const Icon(
                                  Icons.account_circle,
                                  color: Color(0xFF00FFCC),
                                  size: 32,
                                );
                              },
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                      ],
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (!isNarration)
                              Text(
                                currentDialogue.speakerName.toUpperCase(),
                                style: GoogleFonts.pressStart2p(
                                  color: const Color(0xFF00FFCC),
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  shadows: [
                                    const Shadow(
                                      color: Color(0xFF00FFCC),
                                      blurRadius: 2,
                                    ),
                                  ],
                                ),
                              )
                            else
                              Text(
                                currentDialogue.speakerName.toUpperCase(),
                                style: GoogleFonts.pressStart2p(
                                  color: Colors.grey[500],
                                  fontSize: 8,
                                  fontWeight: FontWeight.bold,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            const SizedBox(height: 8),
                            Expanded(
                              child: SingleChildScrollView(
                                physics: const BouncingScrollPhysics(),
                                child: Text(
                                  currentDialogue.text,
                                  style: GoogleFonts.vt323(
                                    color: Colors.white.withValues(alpha: 0.92),
                                    fontSize: 16,
                                    height: 1.25,
                                    fontStyle: isNarration ? FontStyle.italic : FontStyle.normal,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Align(
                              alignment: Alignment.bottomRight,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.play_arrow,
                                    size: 10,
                                    color: Colors.white.withValues(alpha: 0.4),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'ENTER or Tap to continue',
                                    style: GoogleFonts.pressStart2p(
                                      color: Colors.white.withValues(alpha: 0.35),
                                      fontSize: 6,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
