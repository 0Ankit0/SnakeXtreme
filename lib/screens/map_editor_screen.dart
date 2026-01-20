import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/app_colors.dart';
import '../widgets/animated_background.dart';
import '../controllers/map_editor_controller.dart';
import '../utils/sprite_utils.dart';
import '../widgets/animated_sprite.dart';

class MapEditorScreen extends StatefulWidget {
  const MapEditorScreen({super.key});

  @override
  State<MapEditorScreen> createState() => _MapEditorScreenState();
}

class _MapEditorScreenState extends State<MapEditorScreen> {
  final MapEditorController _controller = MapEditorController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBackground(
        child: SafeArea(
          child: Column(
            children: [
              // Header
              _buildHeader(),

              // Instructions / Status
              AnimatedBuilder(
                animation: _controller,
                builder: (context, _) => Container(
                   padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                   color: Colors.black26,
                   width: double.infinity,
                   child: Text(
                     _getInstructionText(),
                     style: GoogleFonts.outfit(color: AppColors.accent, fontWeight: FontWeight.bold),
                     textAlign: TextAlign.center,
                   ),
                ),
              ),

              // Board Area
              Expanded(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: AspectRatio(
                      aspectRatio: 1.0,
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          return _buildInteractiveBoard(constraints.biggest);
                        },
                      ),
                    ),
                  ),
                ),
              ),

              // Toolbox
              _buildToolbox(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
          Text(
            'MAP EDITOR',
            style: GoogleFonts.pressStart2p(fontSize: 18, color: Colors.white),
          ),
          IconButton(
            icon: const Icon(Icons.save_rounded, color: AppColors.primary),
            onPressed: () async {
              await _controller.saveMap();
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Map Saved!', style: GoogleFonts.outfit())),
                );
              }
            },
          ),
        ],
      ),
    );
  }
  
  String _getInstructionText() {
    switch (_controller.activeTool) {
      case EditorTool.none: return "Select a tool to begin";
      case EditorTool.eraser: return "Tap a tile to remove item";
      case EditorTool.snake: 
        return _controller.pendingStartTile == null 
               ? "Tap Start Tile (Top)" 
               : "Tap End Tile (Bottom)";
      case EditorTool.ladder:
        return _controller.pendingStartTile == null 
               ? "Tap Start Tile (Bottom)" 
               : "Tap End Tile (Top)";
    }
  }

  Widget _buildInteractiveBoard(Size size) {
    final tileSize = size.width / 10;
    
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return Stack(
          children: [
             // Grid and Taps
             Column(
               children: List.generate(10, (rowIndex) {
                 return Row(
                   children: List.generate(10, (colIndex) {
                     // Calculate tile number (1-100)
                     // Row 0 is top (91-100), Row 9 is bottom (1-10)
                     int y = 9 - rowIndex;
                     int x = (y % 2 == 0) ? colIndex : (9 - colIndex);
                     final int tileNumber = y * 10 + x + 1;
                     
                     final isSelected = _controller.pendingStartTile == tileNumber;
                     
                     return GestureDetector(
                       onTap: () => _controller.handleTap(tileNumber),
                       child: Container(
                         width: tileSize,
                         height: tileSize,
                         decoration: BoxDecoration(
                           color: isSelected 
                                ? AppColors.accent.withValues(alpha: 0.5)
                                : ((tileNumber % 2 == 0) 
                                    ? Colors.white.withValues(alpha: 0.05) 
                                    : Colors.white.withValues(alpha: 0.1)),
                           border: Border.all(
                              color: isSelected ? AppColors.accent : Colors.white10,
                              width: isSelected ? 2 : 0.5
                           ),
                         ),
                         child: Center(
                           child: Text(
                             '$tileNumber',
                             style: TextStyle(
                               color: Colors.white24,
                               fontSize: tileSize * 0.3,
                             ),
                           ),
                         ),
                       ),
                     );
                   }),
                 );
               }),
             ),
             
             // Overlays (Snakes & Ladders)
             // Ladders
             ..._controller.ladders.entries.map((entry) {
                 return _buildLadderOverlay(entry.key, entry.value, tileSize);
             }),
             // Snakes
             ..._controller.snakes.entries.map((entry) {
                 return _buildSnakeOverlay(entry.key, entry.value, tileSize);
             }),
          ],
        );
      }
    );
  }
  
  // Duplicated rendering logic from GameBoard, but adapted
  Widget _buildLadderOverlay(int start, int end, double tileSize) {
    // start < end
    final startPos = _getTileCenter(start, tileSize);
    final endPos = _getTileCenter(end, tileSize);
    
    final dx = endPos.dx - startPos.dx;
    final dy = endPos.dy - startPos.dy;
    final distance = (endPos - startPos).distance;
    
    final center = Offset((startPos.dx + endPos.dx)/2, (startPos.dy + endPos.dy)/2);
    
    final double rads =  (Offset(dx, dy).direction) + 3.14159/2;

    double tilesSpanned = distance / tileSize;
    int size = 3;
    if (tilesSpanned < 2.5) {
      size = 1;
    } else if (tilesSpanned < 5.0) {
      size = 2;
    }

    return Positioned(
      left: center.dx - 24, // Assuming width ~48
      top: center.dy - (distance / 2),
      child: Transform.rotate(
        angle: rads,
        child: SizedBox(
          height: distance,
          child: StaticSprite.ladder(size: size, scale: 0.8), // Adjust scale
        ),
      ),
    );
  }
  
  Widget _buildSnakeOverlay(int start, int end, double tileSize) {
     final startPos = _getTileCenter(start, tileSize);
     final endPos = _getTileCenter(end, tileSize);

     return Stack(
       children: [
         CustomPaint(
           painter: SnakeBodyPainter(startPos, endPos),
         ),
         Positioned(
           left: startPos.dx - 16,
           top: startPos.dy - 16,
           child: StaticSprite.snakeHead(scale: 0.6),
         ),
         Positioned(
           left: endPos.dx - 16,
           top: endPos.dy - 16,
           child: Image.asset(GameAssets.snakeTail, width: 32, height: 32),
         ),
       ],
     );
  }

  Offset _getTileCenter(int tileNumber, double tileSize) {
    // 0-indexed coords
    int y = (tileNumber - 1) ~/ 10; // 0 is bottom
    int x = (tileNumber - 1) % 10;
    if (y % 2 != 0) x = 9 - x; // Zigzag
    
    // Convert to screen coords (Top-Left origin)
    // Row 0 is Top (y=9 in our logic).
    // ScreenY = (9 - y) * tileSize
    final double screenX = x * tileSize + (tileSize / 2);
    final double screenY = (9 - y) * tileSize + (tileSize / 2);
    return Offset(screenX, screenY);
  }

  Widget _buildToolbox() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.black45,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildToolButton(EditorTool.snake, '🐍 Snake', Icons.gesture),
          _buildToolButton(EditorTool.ladder, '🪜 Ladder', Icons.stairs),
          _buildToolButton(EditorTool.eraser, 'Eraser', Icons.delete_outline),
        ],
      ),
    );
  }

  Widget _buildToolButton(EditorTool tool, String label, IconData icon) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final isSelected = _controller.activeTool == tool;
        return Column(
          children: [
            ElevatedButton(
              onPressed: () => _controller.selectTool(tool),
              style: ElevatedButton.styleFrom(
                backgroundColor: isSelected ? AppColors.primary : Colors.grey[800],
                shape: const CircleBorder(),
                padding: const EdgeInsets.all(20),
              ),
              child: Icon(icon, color: Colors.white, size: 28),
            ),
            const SizedBox(height: 8),
            Text(label, style: GoogleFonts.outfit(color: isSelected ? AppColors.primary : Colors.white54, fontSize: 12)),
          ],
        );
      },
    );
  }
}

// Minimal duplication of painter for editor visual
class SnakeBodyPainter extends CustomPainter {
  final Offset start; // Head
  final Offset end;   // Tail

  SnakeBodyPainter(this.start, this.end);

  @override
  void paint(Canvas canvas, Size size) {
    paintSnakeBody(canvas, start, end);
  }
  
  // Reusing logic (inline)
  void paintSnakeBody(Canvas canvas, Offset start, Offset end) {
    final paint = Paint()
      ..color = const Color(0xFF00FF00)
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 6;

    final path = Path();
    path.moveTo(start.dx, start.dy);
    final mid = (start + end) / 2;
    // Simple S curve
    final control1 = Offset(mid.dx + 40, start.dy + (mid.dy - start.dy)/2);
    final control2 = Offset(mid.dx - 40, end.dy - (end.dy - mid.dy)/2);
    path.cubicTo(control1.dx, control1.dy, control2.dx, control2.dy, end.dx, end.dy);
    
    // Outer glow
    canvas.drawPath(path, paint..strokeWidth = 10..color = const Color(0xFF00FF00).withValues(alpha: 0.3)..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10));
    // Inner Clean
    canvas.drawPath(path, paint..strokeWidth = 4..color = const Color(0xFFAAFFAA)..maskFilter = null);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
