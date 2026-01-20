import 'package:flutter/material.dart';
import '../utils/sprite_utils.dart';
import '../widgets/animated_sprite.dart';
import '../controllers/game_controller.dart';

class PlayerToken extends StatelessWidget {
  final int playerIndex; // 0, 1, 2, 3
  final PlayerAction action;

  const PlayerToken({
    super.key,
    required this.playerIndex,
    this.action = PlayerAction.idle,
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

    return SizedBox(
      width: 32,
      height: 32,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          // Shadow/Highlight
          Container(
            width: 20,
            height: 4,
            margin: const EdgeInsets.only(top: 28),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          // Sprite
          Transform.translate(
            offset: const Offset(0, -10), // Adjust to stand on tile center
            child: AnimatedSprite.player(
              playerColorIndex: playerIndex,
              animation: animation,
              scale: 1.5,
              loop: true,
            ),
          ),
          // Turn Indicator (if needed)
        ],
      ),
    );
  }
}
