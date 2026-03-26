import 'package:flutter/material.dart';
import 'dart:math';
import '../services/audio_manager.dart';

enum GameStatus { playing, won }

enum PlayerAction {
  idle,
  walking,
  climbing, // Going up ladder
  sliding,  // Being eaten by snake
  dancing,  // Won the game
}

class PlayerState {
  final int id;
  final String name;
  final Color color;
  final bool isComputer;
  int position; // 1 to 100
  PlayerAction action;

  PlayerState({
    required this.id,
    required this.name,
    required this.color,
    this.isComputer = false,
    this.position = 1,
    this.action = PlayerAction.idle,
  });
}

class GameController extends ChangeNotifier {
  // Game Configuration
  // Default configurations
  static const Map<int, int> defaultSnakes = {
    16: 6, 47: 26, 49: 11, 56: 53, 62: 19, 
    64: 60, 87: 24, 93: 73, 95: 75, 98: 78,
  };

  static const Map<int, int> defaultLadders = {
    1: 38, 4: 14, 9: 31, 21: 42, 28: 84, 
    36: 44, 51: 67, 71: 91, 80: 100,
  };

  final Map<int, int> snakes;
  final Map<int, int> ladders;

  // State
  List<PlayerState> players = [];
  int currentPlayerIndex = 0;
  int diceValue = 1;
  bool isRolling = false;
  GameStatus status = GameStatus.playing;
  String? winnerName;

  GameController({
    List<PlayerState>? startPlayers,
    Map<int, int>? customSnakes,
    Map<int, int>? customLadders,
  }) : snakes = customSnakes ?? defaultSnakes,
       ladders = customLadders ?? defaultLadders {
    if (startPlayers != null && startPlayers.isNotEmpty) {
      players = startPlayers;
    } else {
      // Default: 2 Human Players
      players = [
        PlayerState(id: 0, name: 'Player 1', color: Colors.blue),
        PlayerState(id: 1, name: 'Player 2', color: Colors.green),
      ];
    }
    
    // Check if first player is computer (e.g. Bot vs Bot)
    _checkComputerTurn();
  }

  PlayerState get currentPlayer => players[currentPlayerIndex];

  Future<void> rollDice() async {
    if (isRolling || status == GameStatus.won || currentPlayer.action != PlayerAction.idle) return;

    isRolling = true;
    notifyListeners();

    // Visual rolling time (matches animation duration approx)
    AudioManager().playSfx(SfxType.diceRoll);
    await Future.delayed(const Duration(milliseconds: 1000));

    diceValue = Random().nextInt(6) + 1;
    isRolling = false;
    notifyListeners();

    await _movePlayer(currentPlayer, diceValue);
  }

  Future<void> _movePlayer(PlayerState player, int steps) async {
    player.action = PlayerAction.walking;
    notifyListeners();

    // Move step by step
    for (int i = 0; i < steps; i++) {
        if (player.position < 100) {
            player.position++;
            AudioManager().playSfx(SfxType.step);
            notifyListeners();
            await Future.delayed(const Duration(milliseconds: 300));
        }
    }
    
    player.action = PlayerAction.idle;
    notifyListeners();
    
    // Check Win
    if (player.position == 100) {
       _handleWin(player);
       return;
    }

    // Check Snake or Ladder
    if (snakes.containsKey(player.position)) {
      // Hit a snake
      await Future.delayed(const Duration(milliseconds: 200));
      player.action = PlayerAction.sliding; // 'Being Eaten' animation
      AudioManager().playSfx(SfxType.gulp);
      await Future.delayed(const Duration(milliseconds: 140));
      AudioManager().playSfx(SfxType.slide);
      notifyListeners();
      
      // Wait for gulp/scare animation
      await Future.delayed(const Duration(milliseconds: 1000));
      
      // Move to tail
      player.position = snakes[player.position]!;
      player.action = PlayerAction.idle;
      notifyListeners();
      
    } else if (ladders.containsKey(player.position)) {
      // Hit a ladder
      await Future.delayed(const Duration(milliseconds: 200));
      player.action = PlayerAction.climbing;
      AudioManager().playSfx(SfxType.climb);
      notifyListeners();
      
      // Climb time
      await Future.delayed(const Duration(milliseconds: 1000));
      
      // Move to top
      player.position = ladders[player.position]!;
      player.action = PlayerAction.idle;
      notifyListeners();
    }
    
    if (player.position == 100) {
       _handleWin(player);
       return;
    }

    _nextTurn();
    notifyListeners();
  }
  
  void _handleWin(PlayerState player) {
      status = GameStatus.won;
      winnerName = player.name;
      player.action = PlayerAction.dancing;
      AudioManager().playSfx(SfxType.win);
      notifyListeners();
  }

  void _nextTurn() {
    if (diceValue != 6) {
       currentPlayerIndex = (currentPlayerIndex + 1) % players.length;
    }
    notifyListeners();
    _checkComputerTurn();
  }

  void _checkComputerTurn() {
    if (status == GameStatus.playing && currentPlayer.isComputer) {
      Future.delayed(const Duration(milliseconds: 1500), () {
        // Double check state after delay
        if (status == GameStatus.playing && 
            currentPlayer.isComputer && 
            currentPlayer.action == PlayerAction.idle && 
            !isRolling) {
          rollDice();
        }
      });
    }
  }
}
