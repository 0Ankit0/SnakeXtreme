import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../widgets/board_tile.dart';
import '../widgets/player_token.dart';
import '../controllers/game_controller.dart';
import '../utils/sprite_utils.dart';
import '../widgets/animated_sprite.dart';

class GameBoard extends StatelessWidget {
  final GameController? controller;

  const GameBoard({super.key, this.controller});

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.0,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final boardSize = constraints.biggest;
          final tileSize = boardSize.width / 10;
          
          return Stack(
            children: [
              // Layer 1: Tiles
              Column(
                children: List.generate(10, (inverseRowIndex) {
                  final int rowIndex = 9 - inverseRowIndex;
                  return Expanded(
                    child: Row(
                      children: List.generate(10, (colIndex) {
                        int number = _getNumberAt(rowIndex, colIndex);
                        final bool isAlternate = (rowIndex + colIndex) % 2 == 0;
                        return Expanded(
                          child: BoardTile(
                            number: number,
                            isAlternate: isAlternate,
                          ),
                        );
                      }),
                    ),
                  );
                }),
              ),
              
              // Layer 2: Ladders & Snakes (Overlays)
              if (controller != null) ...[
                 // Draw Ladders
                 ...controller!.ladders.entries.map((entry) {
                   return _buildOverlay(
                     start: entry.key,
                     end: entry.value,
                     tileSize: tileSize,
                     isSnake: false,
                   );
                 }),

                 // Draw Snakes (Body + Head/Tail)
                 ...controller!.snakes.entries.map((entry) {
                   return _buildOverlay(
                     start: entry.key,
                     end: entry.value,
                     tileSize: tileSize,
                     isSnake: true,
                   );
                 }),

                 // Layer 3: Players
                 ...controller!.players.map((player) {
                   final pos = _getVisualOffset(player.position, tileSize);
                   return AnimatedPositioned(
                     duration: const Duration(milliseconds: 300),
                     curve: Curves.easeInOut,
                     left: pos.dx,
                     top: pos.dy,
                     child: PlayerToken(
                       playerIndex: player.id,
                       action: player.action,
                     ),
                   );
                 }),
              ],
            ],
          );
        },
      ),
    );
  }

  // Returns number at grid index (row 0=bottom)
  int _getNumberAt(int rowIndex, int colIndex) {
      if (rowIndex % 2 == 0) {
        return (rowIndex * 10) + colIndex + 1;
      } else {
        return ((rowIndex + 1) * 10) - colIndex;
      }
  }

  // Returns visual Offset (Left, Top) for a board number (1-100)
  // Stack uses Top-Left.
  Offset _getVisualOffset(int number, double tileSize) {
     if (number < 1) number = 1;
     if (number > 100) number = 100;
     
     // Grid logic
     final int rowIndex = (number - 1) ~/ 10; // 0=bottom
     int colIndex;
     
     if (rowIndex % 2 == 0) {
       colIndex = (number - 1) % 10;
     } else {
       colIndex = 9 - ((number - 1) % 10);
     }
     
     // Visual logic (Stack is Top-Left)
     // Visual Row 0 is Top. Grid Row 0 is Bottom.
     // So Visual Row = 9 - rowIndex.
     // x = colIndex * tileSize
     final double x = colIndex * tileSize + (tileSize / 2) - 16;
     final double y = (9 - rowIndex) * tileSize + (tileSize / 2) - 16;
     
     return Offset(x, y);
  }

  // Builds Snake or Ladder visual connecting two tiles
  Widget _buildOverlay({
      required int start, 
      required int end, 
      required double tileSize, 
      required bool isSnake
  }) {
      final startPos = _getVisualOffset(start, tileSize); // Left, Top (of token center roughly)
      final endPos = _getVisualOffset(end, tileSize);
      
      // Adjust to true centers for math (offset was for 32px token)
      final startCenter = startPos + const Offset(16, 16);
      final endCenter = endPos + const Offset(16, 16);
      
      final dx = endCenter.dx - startCenter.dx;
      final dy = endCenter.dy - startCenter.dy;
      final distance = math.sqrt(dx * dx + dy * dy);
      final angle = math.atan2(dy, dx); // Angle from horizontal
      
      // Midpoint for positioning rotated object
      final midPoint = Offset(
        (startCenter.dx + endCenter.dx) / 2,
        (startCenter.dy + endCenter.dy) / 2,
      );

      if (!isSnake) {
        // --- LADDER RENDER ---
        // Determine asset based on length (approx rows spanned)
        // distance / tileSize
        final tilesSpanned = distance / tileSize;
        int ladderSize = 3; // Long default
        if (tilesSpanned < 2.5) {
          ladderSize = 1;
        } else if (tilesSpanned < 5.0) {
          ladderSize = 2;
        }
        
        final asset = GameAssets.getLadderBySize(ladderSize);

        // Ladders are vertical images. Rotating +90 deg relative to angle?
        // atan2(dy, dx) gives angle of line.
        // If line is vertical up (-90 deg), we want image up.
        // Image is vertical. So rotation = angle - (-pi/2) = angle + pi/2.
        
        return Positioned(
          left: midPoint.dx - (24), // Approx width/2. 48px width asset?
          top: midPoint.dy - (distance / 2),
          child: Transform.rotate(
            angle: angle + (math.pi / 2),
            child: SizedBox(
              width: 48, // Fixed width for ladder
              height: distance,
              child: Image.asset(
                asset,
                fit: BoxFit.fill,
                filterQuality: FilterQuality.none,
              ),
            ),
          ),
        );
      } else {
        // --- SNAKE RENDER ---
        // 1. Draw Body Curve (CustomPainter)
        // 2. Head at Start (Top/Head of snake)
        // 3. Tail at End (Bottom/Tail of snake)
        
        return Stack(
          children: [
             // Body Curve
             Positioned.fill(
               child: CustomPaint(
                 painter: SnakeBodyPainter(start: startCenter, end: endCenter),
               ),
             ),
             // Head (at Start)
             Positioned(
               left: startCenter.dx - 16,
               top: startCenter.dy - 16,
               child: StaticSprite.snakeHead(scale: 1.0), // 32px
             ),
             // Tail (at End)
             Positioned(
               left: endCenter.dx - 16,
               top: endCenter.dy - 16,
               child: Image.asset(
                 GameAssets.snakeTail,
                 width: 32, height: 32,
                 filterQuality: FilterQuality.none,
               ),
             ),
          ],
        );
      }
  }
}

class SnakeBodyPainter extends CustomPainter {
  final Offset start;
  final Offset end;

  SnakeBodyPainter({required this.start, required this.end});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..strokeWidth = 12.0
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke
      ..shader = const LinearGradient(
        colors: [Colors.greenAccent, Colors.green],
      ).createShader(Rect.fromPoints(start, end));

    final path = Path();
    path.moveTo(start.dx, start.dy);
    
    // S-curve
    final mid = (start + end) / 2;
    // Add perpendicular offset for curve
    
    final control1 = Offset(mid.dx + 40, start.dy + (mid.dy - start.dy)/2);
    final control2 = Offset(mid.dx - 40, end.dy - (end.dy - mid.dy)/2);
    
    path.cubicTo(control1.dx, control1.dy, control2.dx, control2.dy, end.dx, end.dy);
    
    // Draw thick border
    canvas.drawPath(path, paint..strokeWidth = 14..color = Colors.black.withValues(alpha: 0.5)..shader = null);
    // Draw body
    canvas.drawPath(path, paint..strokeWidth = 10..shader = const LinearGradient(colors: [Colors.greenAccent, Colors.green]).createShader(Rect.fromPoints(start, end)));
    
    // Segment lines (ribs)
    // Complex to draw smoothly along curve without metric extraction. 
    // MVP: Patterned line?
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
