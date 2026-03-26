import 'dart:math' as math;
import 'package:flutter/material.dart';

class BoardOverlayLayer extends StatelessWidget {
  final Map<int, int> snakes;
  final Map<int, int> ladders;
  final double tileSize;

  const BoardOverlayLayer({
    super.key,
    required this.snakes,
    required this.ladders,
    required this.tileSize,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ...ladders.entries.map((entry) => _buildLadder(entry.key, entry.value)),
        ...snakes.entries.map((entry) => _buildSnake(entry.key, entry.value)),
      ],
    );
  }

  Widget _buildLadder(int start, int end) {
    final startCenter = BoardGeometry.tileCenter(start, tileSize);
    final endCenter = BoardGeometry.tileCenter(end, tileSize);
    final dx = endCenter.dx - startCenter.dx;
    final dy = endCenter.dy - startCenter.dy;
    final distance = math.sqrt(dx * dx + dy * dy);
    final angle = math.atan2(dy, dx);
    final midPoint = Offset(
      (startCenter.dx + endCenter.dx) / 2,
      (startCenter.dy + endCenter.dy) / 2,
    );

    final tilesSpanned = distance / tileSize;
    int ladderSize = 3;
    if (tilesSpanned < 2.5) {
      ladderSize = 1;
    } else if (tilesSpanned < 5.0) {
      ladderSize = 2;
    }

    return Positioned(
      left: midPoint.dx - (_ladderWidth() / 2),
      top: midPoint.dy - (distance / 2),
      child: Transform.rotate(
        angle: angle + (math.pi / 2),
        child: SizedBox(
          width: _ladderWidth(),
          height: distance,
          child: CustomPaint(
            painter: LadderPainter(
              rungCount: ladderSize == 1 ? 4 : ladderSize == 2 ? 6 : 8,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSnake(int start, int end) {
    final startCenter = BoardGeometry.tileCenter(start, tileSize);
    final endCenter = BoardGeometry.tileCenter(end, tileSize);
    return Stack(
      children: [
        Positioned.fill(
          child: CustomPaint(
            painter: SnakeBodyPainter(
              start: startCenter,
              end: endCenter,
              tileSize: tileSize,
            ),
          ),
        ),
        Positioned(
          left: startCenter.dx - (_snakeHeadSize() / 2),
          top: startCenter.dy - (_snakeHeadSize() / 2),
          child: SizedBox(
            width: _snakeHeadSize(),
            height: _snakeHeadSize(),
            child: DecoratedBox(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFEF4444),
                border: Border.all(color: Colors.white, width: 1.8),
              ),
              child: const Icon(Icons.pest_control_rounded, color: Colors.white),
            ),
          ),
        ),
        Positioned(
          left: endCenter.dx - (_snakeTailSize() / 2),
          top: endCenter.dy - (_snakeTailSize() / 2),
          child: Container(
            width: _snakeTailSize(),
            height: _snakeTailSize(),
            decoration: BoxDecoration(
              color: const Color(0xFF16A34A),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: Colors.white, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }

  double _ladderWidth() => (tileSize * 0.72).clamp(18.0, 40.0);
  double _snakeHeadSize() => (tileSize * 0.88).clamp(24.0, 52.0);
  double _snakeTailSize() => (tileSize * 0.72).clamp(20.0, 44.0);
}

class BoardGeometry {
  static Offset tileCenter(int tileNumber, double tileSize) {
    int y = (tileNumber - 1) ~/ 10;
    int x = (tileNumber - 1) % 10;
    if (y % 2 != 0) {
      x = 9 - x;
    }
    return Offset(
      x * tileSize + (tileSize / 2),
      (9 - y) * tileSize + (tileSize / 2),
    );
  }

  static Set<int> sampledPathTiles({
    required int start,
    required int end,
    required bool snake,
  }) {
    final points = <Offset>[];
    final s = _boardGridOffset(start);
    final e = _boardGridOffset(end);
    final mid = (s + e) / 2;
    final wave = 1.5;
    final c1 = snake ? Offset(mid.dx + wave, s.dy) : Offset(mid.dx, mid.dy);
    final c2 = snake ? Offset(mid.dx - wave, e.dy) : Offset(mid.dx, mid.dy);

    const samples = 50;
    for (int i = 0; i <= samples; i++) {
      final t = i / samples;
      final p = _cubicPoint(s, c1, c2, e, t);
      points.add(p);
    }
    final tiles = <int>{start, end};
    for (final p in points) {
      int x = p.dx.round().clamp(0, 9);
      int y = p.dy.round().clamp(0, 9);
      int boardX = (y % 2 == 0) ? x : 9 - x;
      tiles.add(y * 10 + boardX + 1);
    }
    return tiles;
  }

  static Offset _boardGridOffset(int tileNumber) {
    final row = (tileNumber - 1) ~/ 10;
    final rawCol = (tileNumber - 1) % 10;
    final col = row.isEven ? rawCol : 9 - rawCol;
    return Offset(col.toDouble(), row.toDouble());
  }

  static Offset _cubicPoint(Offset p0, Offset p1, Offset p2, Offset p3, double t) {
    final mt = 1 - t;
    final x = mt * mt * mt * p0.dx +
        3 * mt * mt * t * p1.dx +
        3 * mt * t * t * p2.dx +
        t * t * t * p3.dx;
    final y = mt * mt * mt * p0.dy +
        3 * mt * mt * t * p1.dy +
        3 * mt * t * t * p2.dy +
        t * t * t * p3.dy;
    return Offset(x, y);
  }
}

class SnakeBodyPainter extends CustomPainter {
  final Offset start;
  final Offset end;
  final double tileSize;

  SnakeBodyPainter({
    required this.start,
    required this.end,
    required this.tileSize,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final path = Path()..moveTo(start.dx, start.dy);
    final mid = (start + end) / 2;
    final wave = (tileSize * 1.1).clamp(24.0, 52.0);
    final control1 = Offset(mid.dx + wave, start.dy + (mid.dy - start.dy) / 2);
    final control2 = Offset(mid.dx - wave, end.dy - (end.dy - mid.dy) / 2);
    path.cubicTo(control1.dx, control1.dy, control2.dx, control2.dy, end.dx, end.dy);

    canvas.drawPath(
      path,
      paint
        ..strokeWidth = (tileSize * 0.34).clamp(10.0, 20.0)
        ..color = Colors.black.withValues(alpha: 0.5)
        ..shader = null,
    );
    canvas.drawPath(
      path,
      paint
        ..strokeWidth = (tileSize * 0.26).clamp(7.0, 16.0)
        ..shader = const LinearGradient(colors: [Colors.greenAccent, Colors.green])
            .createShader(Rect.fromPoints(start, end)),
    );
  }

  @override
  bool shouldRepaint(covariant SnakeBodyPainter oldDelegate) {
    return oldDelegate.start != start || oldDelegate.end != end || oldDelegate.tileSize != tileSize;
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
  bool shouldRepaint(covariant LadderPainter oldDelegate) => oldDelegate.rungCount != rungCount;
}
