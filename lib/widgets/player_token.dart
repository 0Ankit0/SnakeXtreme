import 'package:flutter/material.dart';
import '../utils/sprite_utils.dart';
import '../controllers/game_controller.dart';

class PlayerToken extends StatelessWidget {
  final int playerIndex; // 0, 1, 2, 3
  final PlayerAction action;
  final double tileSize;

  const PlayerToken({
    super.key,
    required this.playerIndex,
    this.action = PlayerAction.idle,
    this.tileSize = 40,
  });

  @override
  Widget build(BuildContext context) {
    final tokenSize = (tileSize * 0.62).clamp(24.0, 52.0);
    final shadowWidth = tokenSize * 0.66;
    final shadowTop = tokenSize * 0.88;
    final tokenColor = GameAssets.getPlayerColor(playerIndex);
    final isMoving = action == PlayerAction.walking || action == PlayerAction.climbing;
    final isDanger = action == PlayerAction.sliding;

    return SizedBox(
      width: tokenSize,
      height: tokenSize,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          // Shadow/Highlight
          Container(
            width: shadowWidth,
            height: tokenSize * 0.12,
            margin: EdgeInsets.only(top: shadowTop),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          // Code-rendered token avoids sprite-sheet/binary asset dependency.
          Transform.translate(
            offset: Offset(0, -tokenSize * 0.28),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              width: tokenSize * 0.74,
              height: tokenSize * 0.74,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: tokenColor,
                border: Border.all(color: Colors.white, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: tokenColor.withValues(alpha: isMoving ? 0.55 : 0.25),
                    blurRadius: isMoving ? 10 : 4,
                    spreadRadius: isMoving ? 2 : 0,
                  ),
                ],
              ),
              child: Icon(
                isDanger ? Icons.warning_rounded : Icons.sports_esports_rounded,
                color: Colors.white,
                size: tokenSize * 0.34,
              ),
            ),
          ),
          // Turn Indicator (if needed)
        ],
      ),
    );
  }
}
