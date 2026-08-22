import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class HeroOption {
  final String id;
  final String name;
  final String powerName;
  final String imagePath;
  final Color themeColor;

  const HeroOption({
    required this.id,
    required this.name,
    required this.powerName,
    required this.imagePath,
    required this.themeColor,
  });
}

class HeroSelectScreen extends StatelessWidget {
  const HeroSelectScreen({super.key});

  static const List<HeroOption> options = [
    HeroOption(
      id: 'dragon',
      name: 'DRAGON',
      powerName: 'Kinetic Scales',
      imagePath: 'assets/images/characters/Hero 1 Dragon — Kinetic Scales.png',
      themeColor: Color(0xFFFF4500),
    ),
    HeroOption(
      id: 't-rex',
      name: 'T-REX',
      powerName: 'Seismic Hammer',
      imagePath: 'assets/images/characters/Hero 2 T-Rex (Seismic Hammer).png',
      themeColor: Color(0xFFFFD700),
    ),
    HeroOption(
      id: 'curator',
      name: 'CURATOR',
      powerName: 'Temporal Nanotech',
      imagePath: 'assets/images/characters/Curator (Temporal Nanotech).png',
      themeColor: Color(0xFF9400D3),
    ),
    HeroOption(
      id: 'shark',
      name: 'SHARK',
      powerName: 'Hydrokinetic Agility',
      imagePath: 'assets/images/characters/Shark (Hydrokinetic Agility).png',
      themeColor: Color(0xFF1E90FF),
    ),
    HeroOption(
      id: 'kitsune',
      name: 'KITSUNE',
      powerName: 'Holographic Decoy',
      imagePath: 'assets/images/characters/Kitsune (Holographic).png',
      themeColor: Color(0xFF00FFCC),
    ),
    HeroOption(
      id: 'team',
      name: 'TEAM MISSION',
      powerName: 'Full Squad Campaign',
      imagePath: 'assets/images/characters/UI elements (icons, not animated).png',
      themeColor: Color(0xFFFF007F),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF111218),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF00FFCC)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'SELECT CAMPAIGN',
          style: GoogleFonts.pressStart2p(
            color: const Color(0xFF00FFCC),
            fontSize: 14,
            fontWeight: FontWeight.bold,
            letterSpacing: 2.0,
          ),
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1E222B),
                side: const BorderSide(color: Color(0xFF00FFCC), width: 1.5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () => Navigator.pushNamed(context, '/skills'),
              icon: const Icon(Icons.bolt, color: Color(0xFF00FFCC), size: 16),
              label: Text(
                'SKILLS',
                style: GoogleFonts.pressStart2p(
                  color: const Color(0xFF00FFCC),
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 960),
            child: GridView.builder(
              shrinkWrap: true,
              physics: const BouncingScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.2,
              ),
              itemCount: options.length,
              itemBuilder: (context, index) {
                final opt = options[index];
                return GestureDetector(
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      '/level-select',
                      arguments: opt.id,
                    );
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E222B),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: opt.themeColor.withValues(alpha: 0.3),
                        width: 2.0,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: opt.themeColor.withValues(alpha: 0.15),
                          blurRadius: 10,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          Opacity(
                            opacity: 0.8,
                            child: Image.asset(
                              opt.imagePath,
                              fit: opt.id == 'team' ? BoxFit.contain : BoxFit.cover,
                              alignment: Alignment.topCenter,
                            ),
                          ),
                          Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.transparent,
                                  Colors.black.withValues(alpha: 0.85),
                                ],
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.end,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  opt.name,
                                  style: GoogleFonts.pressStart2p(
                                    color: opt.themeColor,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 10,
                                    letterSpacing: 1.0,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  opt.powerName.toUpperCase(),
                                  style: GoogleFonts.vt323(
                                    color: Colors.white70,
                                    fontSize: 14,
                                    letterSpacing: 1.0,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
