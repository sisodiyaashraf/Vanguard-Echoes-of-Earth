import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class MainMenuScreen extends StatelessWidget {
  const MainMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final showQuit = !kIsWeb && (Platform.isAndroid || Platform.isWindows);

    return Scaffold(
      backgroundColor: const Color(0xFF111218),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo placeholder/Visual Art
              Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(
                    color: const Color(0xFF00FFCC).withValues(alpha: 0.3),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF00FFCC).withValues(alpha: 0.1),
                      blurRadius: 20,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(28),
                  child: Image.asset(
                    'assets/images/characters/Hero 1 Dragon — Kinetic Scales.png',
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'VANGUARD',
                style: TextStyle(
                  color: Color(0xFF00FFCC),
                  fontSize: 48,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 8.0,
                  shadows: [
                    Shadow(
                      color: Color(0xFF00FFCC),
                      blurRadius: 15,
                    ),
                  ],
                ),
              ),
              const Text(
                'ECHOES OF EARTH',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 4.0,
                ),
              ),
              const SizedBox(height: 56),
              _buildMenuButton(
                context,
                'PLAY',
                const Color(0xFF00FFCC),
                Colors.black,
                () => Navigator.pushNamed(context, '/hero-select'),
              ),
              const SizedBox(height: 16),
              _buildMenuButton(
                context,
                'SETTINGS',
                Colors.white,
                Colors.black,
                () => Navigator.pushNamed(context, '/settings'),
              ),
              if (showQuit) ...[
                const SizedBox(height: 16),
                _buildMenuButton(
                  context,
                  'QUIT',
                  Colors.white10,
                  Colors.white70,
                  () => SystemNavigator.pop(),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuButton(
    BuildContext context,
    String text,
    Color backgroundColor,
    Color foregroundColor,
    VoidCallback onPressed,
  ) {
    return Container(
      width: 260,
      height: 50,
      decoration: BoxDecoration(
        boxShadow: backgroundColor == const Color(0xFF00FFCC)
            ? [
                BoxShadow(
                  color: const Color(0xFF00FFCC).withValues(alpha: 0.2),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: foregroundColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
            side: backgroundColor == Colors.white10
                ? const BorderSide(color: Colors.white24)
                : BorderSide.none,
          ),
        ),
        onPressed: onPressed,
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            letterSpacing: 2.0,
          ),
        ),
      ),
    );
  }
}
