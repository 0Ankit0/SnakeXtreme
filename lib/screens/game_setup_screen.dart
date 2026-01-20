import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/app_colors.dart';
import '../widgets/animated_background.dart';
import '../controllers/game_controller.dart';
import '../controllers/map_editor_controller.dart';
import 'game_screen.dart';

class GameSetupScreen extends StatefulWidget {
  const GameSetupScreen({super.key});

  @override
  State<GameSetupScreen> createState() => _GameSetupScreenState();
}

class _GameSetupScreenState extends State<GameSetupScreen> {
  int playerCount = 2;
  bool useCustomMap = false;
  List<bool> isComputer = [false, true, false, false]; // Default: P1 Human, P2 Bot
  // 4 Slots max. We only read first playerCount items.

  final List<Color> playerColors = [
    Colors.blue,
    Colors.green,
    Colors.red,
    Colors.yellow,
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBackground(
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'GAME SETUP',
                      style: GoogleFonts.pressStart2p(
                        fontSize: 20,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    children: [
                      // Player Count Selector
                      Text(
                        'NUMBER OF PLAYERS',
                        style: GoogleFonts.outfit(
                          color: AppColors.secondary,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [2, 3, 4].map((count) {
                          final isSelected = playerCount == count;
                          return GestureDetector(
                            onTap: () => setState(() => playerCount = count),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              margin: const EdgeInsets.symmetric(horizontal: 12),
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                color: isSelected 
                                    ? AppColors.primary 
                                    : Colors.white.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: isSelected ? AppColors.accent : Colors.white24,
                                  width: 2,
                                ),
                                boxShadow: isSelected ? [
                                  BoxShadow(
                                    color: AppColors.primary.withValues(alpha: 0.5),
                                    blurRadius: 12,
                                  )
                                ] : [],
                              ),
                              child: Center(
                                child: Text(
                                  '$count',
                                  style: GoogleFonts.pressStart2p(
                                    color: Colors.white,
                                    fontSize: 20,
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),

                      const SizedBox(height: 24),
                      
                      // Map Selector
                      Text(
                        'MAP SELECTION',
                        style: GoogleFonts.outfit(
                          color: AppColors.secondary,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildMapOption('CLASSIC', !useCustomMap, () => setState(() => useCustomMap = false)),
                          const SizedBox(width: 16),
                          _buildMapOption('CUSTOM', useCustomMap, () => setState(() => useCustomMap = true)),
                        ],
                      ),

                      const SizedBox(height: 40),

                      // Player Configuration List
                      Text(
                        'PLAYER CONFIGURATION',
                        style: GoogleFonts.outfit(
                          color: AppColors.secondary,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2,
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      Expanded(
                        child: ListView.builder(
                          itemCount: playerCount,
                          itemBuilder: (context, index) {
                            return _buildPlayerConfigRow(index);
                          },
                        ),
                      ),
                      
                      const SizedBox(height: 20),
                      
                      // Start Button
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: _startGame,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 8,
                            shadowColor: AppColors.primary.withValues(alpha: 0.5),
                          ),
                          child: Text(
                            'START GAME',
                            style: GoogleFonts.pressStart2p(
                              fontSize: 18,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlayerConfigRow(int index) {
    // Determine default name
    String name = 'Player ${index + 1}';
    if (isComputer[index]) name = 'Bot ${index + 1}';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white12),
      ),
      child: Row(
        children: [
          // Player Token/Icon
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: playerColors[index].withValues(alpha: 0.2),
              shape: BoxShape.circle,
              border: Border.all(color: playerColors[index], width: 2),
            ),
            child: Icon(Icons.person, color: playerColors[index]),
          ),
          
          const SizedBox(width: 16),
          
          // Name
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  isComputer[index] ? 'Computer AI' : 'Human Player',
                  style: GoogleFonts.outfit(
                    color: Colors.white54,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          
          // CPU Toggle
          Row(
            children: [
              Text(
                'CPU',
                style: GoogleFonts.pressStart2p(
                  fontSize: 10,
                  color: isComputer[index] ? AppColors.accent : Colors.white24,
                ),
              ),
              const SizedBox(width: 8),
              Switch(
                value: isComputer[index],
                onChanged: (val) {
                  setState(() {
                    isComputer[index] = val;
                  });
                },
                activeThumbColor: AppColors.accent,
                activeTrackColor: AppColors.accent.withValues(alpha: 0.5),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMapOption(String label, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.accent : Colors.transparent,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: isSelected ? AppColors.accent : Colors.white24,
            width: 2,
          ),
          boxShadow: isSelected ? [
             BoxShadow(color: AppColors.accent.withValues(alpha: 0.4), blurRadius: 10)
          ] : [],
        ),
        child: Text(
          label,
          style: GoogleFonts.pressStart2p(
            color: isSelected ? Colors.black : Colors.white54,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  void _startGame() async {
    List<PlayerState> players = [];
    for (int i = 0; i < playerCount; i++) {
        players.add(PlayerState(
           id: i,
           name: isComputer[i] ? 'Bot ${i+1}' : 'Player ${i+1}',
           color: playerColors[i],
           isComputer: isComputer[i],
        ));
    }

    Map<int, int>? customSnakes;
    Map<int, int>? customLadders;

    if (useCustomMap) {
       final editor = MapEditorController();
       await editor.loadMap();
       if (editor.snakes.isEmpty && editor.ladders.isEmpty) {
          if (mounted) {
             ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Custom Map is Empty! Using Classic.', style: GoogleFonts.outfit())),
             );
          }
          // Fallback or Return? Let's fallback but notify.
       } else {
          customSnakes = editor.snakes;
          customLadders = editor.ladders;
       }
    }

    if (!mounted) return;

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => GameScreen(
           players: players,
           customSnakes: customSnakes,
           customLadders: customLadders,
        ),
      ),
    );
  }
}
