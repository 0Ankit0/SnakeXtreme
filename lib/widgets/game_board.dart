import 'package:flutter/material.dart';
import '../widgets/board_tile.dart';
import '../widgets/player_token.dart';
import '../controllers/game_controller.dart';
import 'board_overlays.dart';

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
              Column(
                children: List.generate(10, (inverseRowIndex) {
                  final int rowIndex = 9 - inverseRowIndex;
                  return Expanded(
                    child: Row(
                      children: List.generate(10, (colIndex) {
                        final number = _getNumberAt(rowIndex, colIndex);
                        final isAlternate = (rowIndex + colIndex) % 2 == 0;
                        return Expanded(
                          child: BoardTile(number: number, isAlternate: isAlternate),
                        );
                      }),
                    ),
                  );
                }),
              ),
              if (controller != null) ...[
                BoardOverlayLayer(
                  snakes: controller!.snakes,
                  ladders: controller!.ladders,
                  tileSize: tileSize,
                ),
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
                      tileSize: tileSize,
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

  int _getNumberAt(int rowIndex, int colIndex) {
    if (rowIndex % 2 == 0) {
      return (rowIndex * 10) + colIndex + 1;
    }
    return ((rowIndex + 1) * 10) - colIndex;
  }

  Offset _getVisualOffset(int number, double tileSize) {
    number = number.clamp(1, 100);
    final rowIndex = (number - 1) ~/ 10;
    final colIndex = rowIndex % 2 == 0 ? (number - 1) % 10 : 9 - ((number - 1) % 10);
    final tokenSize = (tileSize * 0.62).clamp(24.0, 52.0);
    final x = colIndex * tileSize + (tileSize / 2) - (tokenSize / 2);
    final y = (9 - rowIndex) * tileSize + (tileSize / 2) - (tokenSize / 2);
    return Offset(x, y);
  }
}

class LadderPainter extends CustomPainter {
  final int rungCount;

  LadderPainter({required this.rungCount});

  @override
  void paint(Canvas canvas, Size size) {
    final railPaint = Paint()
      ..color = const Color(0xFFD97706)
      ..strokeWidth = size.width * 0.16
      ..strokeCap = StrokeCap.round;
    final rungPaint = Paint()
      ..color = const Color(0xFFFCD34D)
      ..strokeWidth = size.width * 0.13
      ..strokeCap = StrokeCap.round;
    final borderPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.22)
      ..strokeWidth = size.width * 0.22
      ..strokeCap = StrokeCap.round;

    final leftX = size.width * 0.28;
    final rightX = size.width * 0.72;
    final top = size.height * 0.06;
    final bottom = size.height * 0.94;

    canvas.drawLine(Offset(leftX, top), Offset(leftX, bottom), borderPaint);
    canvas.drawLine(Offset(rightX, top), Offset(rightX, bottom), borderPaint);
    canvas.drawLine(Offset(leftX, top), Offset(leftX, bottom), railPaint);
    canvas.drawLine(Offset(rightX, top), Offset(rightX, bottom), railPaint);

    for (int i = 1; i <= rungCount; i++) {
      final y = top + ((bottom - top) * i / (rungCount + 1));
      canvas.drawLine(Offset(leftX, y), Offset(rightX, y), rungPaint);
    }
  }

  @override
  bool shouldRepaint(covariant LadderPainter oldDelegate) {
    return oldDelegate.rungCount != rungCount;
  }
}
