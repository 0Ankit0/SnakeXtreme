import 'package:flutter/material.dart';

/// Defines the different animation types available for player sprites
enum PlayerAnimation {
  idle,
  walking,
  dancing,
  climbing,
  beingEaten,
  jumping,
}

/// Information about a sprite animation
class SpriteAnimationInfo {
  final int frameCount;
  final int row;
  final Duration frameDuration;

  const SpriteAnimationInfo({
    required this.frameCount,
    required this.row,
    this.frameDuration = const Duration(milliseconds: 100),
  });
}

/// Player sprite configuration
class PlayerSpriteConfig {
  /// Frame size in pixels
  static const double frameSize = 32.0;
  
  /// Animation definitions
  static const Map<PlayerAnimation, SpriteAnimationInfo> animations = {
    PlayerAnimation.idle: SpriteAnimationInfo(frameCount: 4, row: 0, frameDuration: Duration(milliseconds: 200)),
    PlayerAnimation.walking: SpriteAnimationInfo(frameCount: 6, row: 1, frameDuration: Duration(milliseconds: 100)),
    PlayerAnimation.dancing: SpriteAnimationInfo(frameCount: 8, row: 2, frameDuration: Duration(milliseconds: 120)),
    PlayerAnimation.climbing: SpriteAnimationInfo(frameCount: 6, row: 3, frameDuration: Duration(milliseconds: 150)),
    PlayerAnimation.beingEaten: SpriteAnimationInfo(frameCount: 6, row: 4, frameDuration: Duration(milliseconds: 180)),
    PlayerAnimation.jumping: SpriteAnimationInfo(frameCount: 4, row: 5, frameDuration: Duration(milliseconds: 80)),
  };
}

/// Dice animation configuration
class DiceConfig {
  static const double faceSize = 64.0;
  static const int faceCount = 6;
  static const int rollFrameCount = 8;
  static const Duration rollFrameDuration = Duration(milliseconds: 50);
}

/// Snake animation configuration
class SnakeConfig {
  static const double headSize = 64.0;
  static const double bodySize = 48.0;
  static const double tailSize = 48.0;
  static const int gulpFrameCount = 6;
  static const Duration gulpFrameDuration = Duration(milliseconds: 150);
}

/// Ladder configuration
class LadderConfig {
  static const double width = 48.0;
  static const double shortHeight = 96.0;
  static const double mediumHeight = 160.0;
  static const double longHeight = 224.0;
}

/// Asset paths for all game sprites
class GameAssets {
  // Player sprites
  static const String playerBase = 'assets/images/sprites/player_base.png';
  static const String playerRed = 'assets/images/sprites/player_red.png';
  static const String playerBlue = 'assets/images/sprites/player_blue.png';
  static const String playerGreen = 'assets/images/sprites/player_green.png';
  static const String playerYellow = 'assets/images/sprites/player_yellow.png';
  
  // Dice
  static const String diceFaces = 'assets/images/dice/dice_faces.png';
  static const String diceRoll = 'assets/images/dice/dice_roll.png';
  
  // Ladders
  static const String ladderShort = 'assets/images/ladder/ladder_short.png';
  static const String ladderMedium = 'assets/images/ladder/ladder_medium.png';
  static const String ladderLong = 'assets/images/ladder/ladder_long.png';
  
  // Snake
  static const String snakeHead = 'assets/images/snake/snake_head.png';
  static const String snakeBody = 'assets/images/snake/snake_body.png';
  static const String snakeTail = 'assets/images/snake/snake_tail.png';
  static const String snakeGulp = 'assets/images/snake/snake_gulp.png';
  
  /// Get player sprite path by color index (0-3)
  static String getPlayerSprite(int colorIndex) {
    switch (colorIndex) {
      case 0:
        return playerRed;
      case 1:
        return playerBlue;
      case 2:
        return playerGreen;
      case 3:
        return playerYellow;
      default:
        return playerBase;
    }
  }
  
  /// Get player color by index
  static Color getPlayerColor(int colorIndex) {
    switch (colorIndex) {
      case 0:
        return const Color(0xFFEF4444); // Red
      case 1:
        return const Color(0xFF3B82F6); // Blue
      case 2:
        return const Color(0xFF10B981); // Green
      case 3:
        return const Color(0xFFFBBF24); // Yellow
      default:
        return Colors.grey;
    }
  }
  
  /// Get ladder asset by size (1=short, 2=medium, 3=long)
  static String getLadderBySize(int size) {
    switch (size) {
      case 1:
        return ladderShort;
      case 2:
        return ladderMedium;
      case 3:
      default:
        return ladderLong;
    }
  }
}

/// Preload all game assets
Future<void> preloadGameAssets(BuildContext context) async {
  final assets = [
    GameAssets.playerBase,
    GameAssets.playerRed,
    GameAssets.playerBlue,
    GameAssets.playerGreen,
    GameAssets.playerYellow,
    GameAssets.diceFaces,
    GameAssets.diceRoll,
    GameAssets.ladderShort,
    GameAssets.ladderMedium,
    GameAssets.ladderLong,
    GameAssets.snakeHead,
    GameAssets.snakeBody,
    GameAssets.snakeTail,
    GameAssets.snakeGulp,
  ];
  
  for (final asset in assets) {
    await precacheImage(AssetImage(asset), context);
  }
}
