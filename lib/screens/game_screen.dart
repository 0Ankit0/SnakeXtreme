import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/app_colors.dart';
import '../widgets/animated_background.dart';
import '../widgets/game_board.dart';
import '../controllers/game_controller.dart';
import '../services/audio_manager.dart';
import '../widgets/animated_sprite.dart';

class GameScreen extends StatefulWidget {
  final List<PlayerState>? players; // Optional, defaults if null
  final Map<int, int>? customSnakes;
  final Map<int, int>? customLadders;
  
  const GameScreen({
    super.key, 
    this.players,
    this.customSnakes,
    this.customLadders,
  });

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late GameController _controller;

  @override
  void initState() {
    super.initState();
    _controller = GameController(
      startPlayers: widget.players,
      customSnakes: widget.customSnakes,
      customLadders: widget.customLadders,
    );
    
    // Listen for game over
    _controller.addListener(() {
      if (_controller.status == GameStatus.won && mounted) {
        _showWinDialog(_controller.winnerName!);
      }
    });
    
    // Start BGM
    AudioManager().playBgm();
  }

  @override
  void dispose() {
    AudioManager().stopBgm();
    _controller.dispose();
    super.dispose();
  }

  void _showWinDialog(String winnerName) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.backgroundDark.withValues(alpha: 0.95),
        shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: BorderSide(color: AppColors.accent, width: 2),
        ),
        title: Text('GAME OVER', 
            style: GoogleFonts.pressStart2p(color: AppColors.secondary, fontSize: 18),
            textAlign: TextAlign.center,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🏆', style: TextStyle(fontSize: 60)),
            const SizedBox(height: 20),
            Text(
              '$winnerName WINS!',
              style: GoogleFonts.pressStart2p(color: Colors.white, fontSize: 14),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close dialog
              Navigator.of(context).pop(); // Go to menu
            }, 
            child: Text('MENU', style: GoogleFonts.outfit(color: Colors.white, fontSize: 18)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            onPressed: () {
               Navigator.of(context).pop();
               setState(() {
                 _controller = GameController(); // Reset
               });
            }, 
            child: Text('REPLAY', style: GoogleFonts.outfit(color: Colors.white, fontSize: 18)),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBackground(
        child: SafeArea(
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Column(
                children: [
                  // Header
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                        Text(
                          'SNAKE XTREME',
                          style: GoogleFonts.pressStart2p(
                            fontSize: 16,
                            color: Colors.white,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.pause_rounded, color: Colors.white),
                          onPressed: () {},
                        ),
                      ],
                    ),
                  ),

                  // Game Info Bar
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: List.generate(_controller.players.length, (index) {
                         final player = _controller.players[index];
                         return _buildPlayerScore(
                           player.name, 
                           player.color, 
                           _controller.currentPlayerIndex == index
                         );
                      }),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Game Board
                  Expanded(
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: GameBoard(controller: _controller),
                      ),
                    ),
                  ),

                  // Bottom Control Area (Dice)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.only(bottom: 0), // Padding handled by SafeArea inside or parent
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.5),
                        ],
                      ),
                    ),
                    child: SafeArea(
                      top: false,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        child: Center(
                          child: GestureDetector(
                            onTap: _controller.isRolling ? null : () => _controller.rollDice(),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                              decoration: BoxDecoration(
                                color: _controller.isRolling ? Colors.grey : AppColors.primary,
                                borderRadius: BorderRadius.circular(30),
                                boxShadow: [
                                  BoxShadow(
                                    color: (_controller.isRolling ? Colors.grey : AppColors.primary).withValues(alpha: 0.4),
                                    blurRadius: 10,
                                    spreadRadius: 2,
                                  ),
                                ],
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (_controller.isRolling)
                                    AnimatedSprite.diceRoll(
                                      key: const ValueKey('rolling'),
                                      scale: 1.5,
                                    )
                                  else
                                    StaticSprite.diceFace(
                                      key: ValueKey(_controller.diceValue),
                                      number: _controller.diceValue,
                                      scale: 1.5,
                                    ),
                                  
                                  const SizedBox(height: 8),
                                  
                                  Text(
                                    _controller.isRolling ? 'ROLLING...' : 'ROLL DICE',
                                    style: GoogleFonts.pressStart2p(
                                      fontSize: 12,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            }
          ),
        ),
      ),
    );
  }

  Widget _buildPlayerScore(String label, Color color, bool isActive) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: isActive ? BoxDecoration(
        border: Border.all(color: color, width: 2),
        borderRadius: BorderRadius.circular(12),
        color: color.withValues(alpha: 0.2),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.2),
            blurRadius: 8,
          )
        ]
      ) : BoxDecoration(
         borderRadius: BorderRadius.circular(12),
         color: Colors.transparent,
      ),
      child: Row(
        children: [
          Icon(Icons.person, color: color, size: 24),
          const SizedBox(width: 8),
          Text(
            label,
            style: GoogleFonts.outfit(
              color: isActive ? Colors.white : Colors.white54,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}

