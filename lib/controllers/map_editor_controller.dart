import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum EditorTool { none, snake, ladder, eraser }

class MapEditorController extends ChangeNotifier {
  // State
  Map<int, int> snakes = {};
  Map<int, int> ladders = {};
  
  EditorTool activeTool = EditorTool.none;
  int? pendingStartTile; // For two-step placement
  
  // Persistence
  static const String _storageKey = 'custom_map_data';

  // Helper getters
  bool get hasPendingAction => pendingStartTile != null;

  MapEditorController() {
    loadMap();
  }

  void selectTool(EditorTool tool) {
    activeTool = tool;
    pendingStartTile = null; // Reset pending action
    notifyListeners();
  }

  void handleTap(int tile) {
    if (tile < 1 || tile > 100) return;

    if (activeTool == EditorTool.eraser) {
       _eraseAt(tile);
       return;
    }

    if (activeTool == EditorTool.snake || activeTool == EditorTool.ladder) {
       if (pendingStartTile == null) {
         // Step 1: Select Start
         if (_isOccupied(tile)) {
           // Can't start where something already is
           // Feedback needed? Handled by UI highlighting usually.
           return;
         }
         pendingStartTile = tile;
         notifyListeners();
       } else {
         // Step 2: Select End
         if (tile == pendingStartTile) {
           // Cancel if tapped same
           pendingStartTile = null;
           notifyListeners();
           return;
         }
         
         if (_isValidPlacement(pendingStartTile!, tile)) {
           _placeEntity(pendingStartTile!, tile);
           pendingStartTile = null;
           notifyListeners();
         } else {
           // Invalid placement (e.g. Snake going up)
           // Reset or keep pending? Let's reset.
           pendingStartTile = null;
           notifyListeners();
         }
       }
    }
  }

  void _eraseAt(int tile) {
    bool changed = false;
    if (snakes.containsKey(tile)) {
      snakes.remove(tile);
      changed = true;
    }
    if (ladders.containsKey(tile)) {
      ladders.remove(tile);
      changed = true;
    }
    if (changed) notifyListeners();
  }
  
  bool _isOccupied(int tile) {
    return snakes.containsKey(tile) || ladders.containsKey(tile);
  }

  bool _isValidPlacement(int start, int end) {
    if (start == end) return false;
    // Check overlaps (simple check: start point free? yes, checked in step 1)
    // End point doesn't strictly need to be free of starts, but chains are complex.
    // Let's prevent chains for simplicity: Start cannot be an End of another? 
    // Complicated. Let's just prevent Start overlaps.
    
    if (activeTool == EditorTool.snake) {
      return start > end; // Snakes go down
    } else if (activeTool == EditorTool.ladder) {
      return start < end; // Ladders go up
    }
    return false;
  }

  void _placeEntity(int start, int end) {
    if (activeTool == EditorTool.snake) {
      snakes[start] = end;
    } else if (activeTool == EditorTool.ladder) {
      ladders[start] = end;
    }
  }

  Future<void> saveMap() async {
    final prefs = await SharedPreferences.getInstance();
    final data = {
      'snakes': snakes.map((k, v) => MapEntry(k.toString(), v)),
      'ladders': ladders.map((k, v) => MapEntry(k.toString(), v)),
    };
    await prefs.setString(_storageKey, jsonEncode(data));
  }
  
  Future<void> loadMap() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_storageKey);
    
    if (jsonString != null) {
      try {
        final data = jsonDecode(jsonString) as Map<String, dynamic>;
        
        final loadedSnakes = (data['snakes'] as Map<String, dynamic>).map(
          (k, v) => MapEntry(int.parse(k), v as int)
        );
        final loadedLadders = (data['ladders'] as Map<String, dynamic>).map(
          (k, v) => MapEntry(int.parse(k), v as int)
        );
        
        snakes = loadedSnakes;
        ladders = loadedLadders;
        notifyListeners();
      } catch (e) {
        debugPrint('Error loading map: $e');
      }
    }
  }
  
  void clearMap() {
    snakes.clear();
    ladders.clear();
    notifyListeners();
  }
}
