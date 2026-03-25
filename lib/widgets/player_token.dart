import 'package:flutter/material.dart';
import '../utils/sprite_utils.dart';
import '../widgets/animated_sprite.dart';
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
    // Determine animation based on state
    final PlayerAnimation animation;
    switch (action) {
      case PlayerAction.walking:
        animation = PlayerAnimation.walking;
        break;
      case PlayerAction.climbing:
        animation = PlayerAnimation.climbing;
        break;
      case PlayerAction.sliding:
        animation = PlayerAnimation.beingEaten;
        break;
      case PlayerAction.dancing:
        animation = PlayerAnimation.dancing;
        break;
      case PlayerAction.idle:
        animation = PlayerAnimation.idle;
        break;
    }

    final tokenSize = (tileSize * 0.62).clamp(24.0, 52.0);
    final shadowWidth = tokenSize * 0.66;
    final shadowTop = tokenSize * 0.88;
    final spriteLift = tokenSize * 0.32;

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
          // Sprite
          Transform.translate(
            offset: Offset(0, -spriteLift), // Adjust to stand on tile center
            child: AnimatedSprite.player(
              playerColorIndex: playerIndex,
              animation: animation,
              scale: (tokenSize / PlayerSpriteConfig.frameSize).clamp(0.85, 1.65),
              loop: true,
            ),
          ),
          // Turn Indicator (if needed)
        ],
      ),
    );
  }
}
