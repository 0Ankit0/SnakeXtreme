import 'package:flutter/material.dart';
import '../utils/sprite_utils.dart';

/// A widget that displays an animated sprite from a sprite sheet
class AnimatedSprite extends StatefulWidget {
  final String imagePath;
  final int frameCount;
  final int row;
  final double frameWidth;
  final double frameHeight;
  final Duration frameDuration;
  final bool loop;
  final VoidCallback? onComplete;
  final double scale;

  const AnimatedSprite({
    super.key,
    required this.imagePath,
    required this.frameCount,
    this.row = 0,
    this.frameWidth = 32,
    this.frameHeight = 32,
    this.frameDuration = const Duration(milliseconds: 100),
    this.loop = true,
    this.onComplete,
    this.scale = 2.0,
  });

  /// Create a player sprite with a specific animation
  factory AnimatedSprite.player({
    Key? key,
    required int playerColorIndex,
    required PlayerAnimation animation,
    double scale = 2.0,
    bool loop = true,
    VoidCallback? onComplete,
  }) {
    final animInfo = PlayerSpriteConfig.animations[animation]!;
    return AnimatedSprite(
      key: key,
      imagePath: GameAssets.getPlayerSprite(playerColorIndex),
      frameCount: animInfo.frameCount,
      row: animInfo.row,
      frameWidth: PlayerSpriteConfig.frameSize,
      frameHeight: PlayerSpriteConfig.frameSize,
      frameDuration: animInfo.frameDuration,
      loop: loop,
      onComplete: onComplete,
      scale: scale,
    );
  }

  /// Create a dice rolling animation
  factory AnimatedSprite.diceRoll({
    Key? key,
    double scale = 1.5,
    VoidCallback? onComplete,
  }) {
    return AnimatedSprite(
      key: key,
      imagePath: GameAssets.diceRoll,
      frameCount: DiceConfig.rollFrameCount,
      row: 0,
      frameWidth: DiceConfig.faceSize,
      frameHeight: DiceConfig.faceSize,
      frameDuration: DiceConfig.rollFrameDuration,
      loop: false,
      onComplete: onComplete,
      scale: scale,
    );
  }

  /// Create a snake gulping animation
  factory AnimatedSprite.snakeGulp({
    Key? key,
    double scale = 1.5,
    bool loop = false,
    VoidCallback? onComplete,
  }) {
    return AnimatedSprite(
      key: key,
      imagePath: GameAssets.snakeGulp,
      frameCount: SnakeConfig.gulpFrameCount,
      row: 0,
      frameWidth: 80,
      frameHeight: 80,
      frameDuration: SnakeConfig.gulpFrameDuration,
      loop: loop,
      onComplete: onComplete,
      scale: scale,
    );
  }

  @override
  State<AnimatedSprite> createState() => _AnimatedSpriteState();
}

class _AnimatedSpriteState extends State<AnimatedSprite>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  int _currentFrame = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.frameDuration,
    );
    
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _nextFrame();
      }
    });
    
    _controller.forward();
  }

  void _nextFrame() {
    if (!mounted) return;
    
    setState(() {
      _currentFrame++;
      
      if (_currentFrame >= widget.frameCount) {
        if (widget.loop) {
          _currentFrame = 0;
        } else {
          _currentFrame = widget.frameCount - 1;
          widget.onComplete?.call();
          return;
        }
      }
    });
    
    _controller.reset();
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final displayWidth = widget.frameWidth * widget.scale;
    final displayHeight = widget.frameHeight * widget.scale;
    
    return SizedBox(
      width: displayWidth,
      height: displayHeight,
      child: ClipRect(
        child: OverflowBox(
          maxWidth: double.infinity,
          maxHeight: double.infinity,
          alignment: Alignment.topLeft,
          child: Transform.translate(
            offset: Offset(
              -_currentFrame * widget.frameWidth * widget.scale,
              -widget.row * widget.frameHeight * widget.scale,
            ),
            child: Image.asset(
              widget.imagePath,
              fit: BoxFit.none,
              scale: 1 / widget.scale,
              filterQuality: FilterQuality.none, // Keep pixel art crisp
            ),
          ),
        ),
      ),
    );
  }
}

/// A static sprite display widget (can slice from sprite sheet)
class StaticSprite extends StatelessWidget {
  final String imagePath;
  final double scale;
  final BoxFit fit;
  final double? frameWidth;
  final double? frameHeight;
  final int row;
  final int col;

  const StaticSprite({
    super.key,
    required this.imagePath,
    this.scale = 1.0,
    this.fit = BoxFit.contain,
    this.frameWidth,
    this.frameHeight,
    this.row = 0,
    this.col = 0,
  });

  /// Create a dice face showing a specific number (1-6)
  factory StaticSprite.diceFace({
    Key? key,
    required int number,
    double scale = 1.5,
  }) {
    // Dice faces are likely in a row. Frame 0 = 1, Frame 5 = 6.
    return StaticSprite(
      key: key,
      imagePath: GameAssets.diceFaces,
      scale: scale,
      frameWidth: DiceConfig.faceSize,
      frameHeight: DiceConfig.faceSize,
      col: (number - 1).clamp(0, 5),
      row: 0,
    );
  }

  /// Create a ladder sprite
  factory StaticSprite.ladder({
    Key? key,
    required int size, // 1=short, 2=medium, 3=long
    double scale = 1.0,
  }) {
    return StaticSprite(
      key: key,
      imagePath: GameAssets.getLadderBySize(size),
      scale: scale,
    );
  }

  /// Create a snake head sprite
  factory StaticSprite.snakeHead({
    Key? key,
    double scale = 1.0,
  }) {
    return StaticSprite(
      key: key,
      imagePath: GameAssets.snakeHead,
      scale: scale,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (frameWidth != null && frameHeight != null) {
       // Slicing logic
       final displayWidth = frameWidth! * scale;
       final displayHeight = frameHeight! * scale;

       return SizedBox(
         width: displayWidth,
         height: displayHeight,
         child: ClipRect(
           child: OverflowBox(
             maxWidth: double.infinity,
             maxHeight: double.infinity,
             alignment: Alignment.topLeft,
             child: Transform.translate(
               offset: Offset(
                 -col * frameWidth! * scale,
                 -row * frameHeight! * scale,
               ),
               child: Image.asset(
                 imagePath,
                 fit: BoxFit.none,
                 scale: 1 / scale,
                 filterQuality: FilterQuality.none, 
               ),
             ),
           ),
         ),
       );
    }

    return Image.asset(
      imagePath,
      scale: 1 / scale,
      filterQuality: FilterQuality.none, 
      fit: fit,
    );
  }
}
