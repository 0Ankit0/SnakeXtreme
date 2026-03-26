import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:snake_xtreme/controllers/map_editor_controller.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('map editor places valid entities and erases by endpoint/path', () async {
    SharedPreferences.setMockInitialValues({});
    final controller = MapEditorController();
    await Future<void>.delayed(const Duration(milliseconds: 20));

    controller.selectTool(EditorTool.snake);
    controller.handleTap(98);
    controller.handleTap(78);
    expect(controller.snakes[98], 78);

    controller.selectTool(EditorTool.ladder);
    controller.handleTap(4);
    controller.handleTap(14);
    expect(controller.ladders[4], 14);

    controller.selectTool(EditorTool.eraser);
    controller.handleTap(14); // erase by endpoint
    expect(controller.ladders.isEmpty, true);

    controller.handleTap(88); // near snake path tiles -> should erase snake
    expect(controller.snakes.isEmpty, true);
  });
}
