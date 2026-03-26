import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/app_colors.dart';
import '../widgets/animated_background.dart';
import '../controllers/map_editor_controller.dart';
import '../widgets/board_overlays.dart';

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
             
             BoardOverlayLayer(
               snakes: _controller.snakes,
               ladders: _controller.ladders,
               tileSize: tileSize,
             ),
          ],
        );
      }
    );
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
