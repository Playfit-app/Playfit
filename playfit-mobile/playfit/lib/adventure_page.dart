import 'package:flame/game.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class AdventurePage extends StatelessWidget {
  const AdventurePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GameWidget(
        game: AdventureGame(),
      ),
    );
  }
}

class AdventureGame extends FlameGame {
  late SpriteComponent character;
  late List<LevelCircle> levelCircles;

  @override
  Color backgroundColor() => const Color(0xFF87CEEB);

  @override
  Future<void> onLoad() async {
    super.onLoad();

    // Add the road FIRST so it's drawn below other elements
    final road = RoadComponent(size); // Pass game size to road
    add(road);

    // Add buildings, tree, and light post in separate places
    addBuilding(Vector2(size.x * 0.15, size.y * 0.2)); // Left side
    addBuilding(Vector2(size.x * 0.73, size.y * 0.55)); // Right side
    addTree(Vector2(size.x * 0.8, size.y * 0.3)); // Right side
    addLight(Vector2(size.x * 0.2, size.y * 0.7)); // Lower left side

    // Add interactive level circles (checkpoints)
    levelCircles = [
      LevelCircle(Vector2(size.x * 0.37, size.y * 0.63), 1, 'checkpointNotPass.png'),
      LevelCircle(Vector2(size.x * 0.53, size.y * 0.43), 2, 'checkpointNotPass.png'),
      LevelCircle(Vector2(size.x * 0.47, size.y * 0.07), 3, 'checkpointNotPass.png'),

    ];
    for (var circle in levelCircles) {
      add(circle);
    }

    // Add the character on the road
    character = SpriteComponent()
      ..sprite = await loadSprite('characterMap.png')
      ..size = Vector2(80, 120)
      ..position = Vector2(size.x * 0.37, size.y * 0.8); // Adjusted character position
    add(character);
  }

  // Helper methods to add assets in correct positions
  void addBuilding(Vector2 position) async {
    final building = SpriteComponent()
      ..sprite = await loadSprite('building.png')
      ..position = position
      ..size = Vector2(100, 200);
    add(building);
  }

  void addTree(Vector2 position) async {
    final tree = SpriteComponent()
      ..sprite = await loadSprite('tree.png')
      ..position = position
      ..size = Vector2(50, 100);
    add(tree);
  }

  void addLight(Vector2 position) async {
    final light = SpriteComponent()
      ..sprite = await loadSprite('light.png')
      ..position = position
      ..size = Vector2(30, 60);
    add(light);
  }
}

// Interactive level circles (checkpoints)
class LevelCircle extends SpriteComponent {
  final String assetName;

  LevelCircle(Vector2 position, int levelNumber, this.assetName) {
    this.position = position;
    size = Vector2(50, 50);
  }

  @override
  Future<void> onLoad() async {
    sprite = await Sprite.load(assetName);
  }
}

// Road Component (Now Works Properly)
class RoadComponent extends PositionComponent {
  final Vector2 gameSize;

  RoadComponent(this.gameSize) {
    size = Vector2(gameSize.x, gameSize.y); // Set size properly
  }

  @override
  void render(Canvas canvas) {
    final paint = Paint()
      ..color = const Color(0xFF4B4B4B) // Dark grey road
      ..style = PaintingStyle.fill; // Solid shape

    final path = Path();

    // Define road width
    const roadWidth = 120;

    // Create a zigzag road shape
    path.moveTo(gameSize.x * 0.5 - roadWidth / 2, gameSize.y); // Bottom left of road
    path.lineTo(gameSize.x * 0.4 - roadWidth / 2, gameSize.y * 0.65);
    path.lineTo(gameSize.x * 0.6 - roadWidth / 2, gameSize.y * 0.45);
    path.lineTo(gameSize.x * 0.5 - roadWidth / 2, 0); // Top left of road

    path.lineTo(gameSize.x * 0.5 + roadWidth / 2, 0); // Top right of road
    path.lineTo(gameSize.x * 0.6 + roadWidth / 2, gameSize.y * 0.45);
    path.lineTo(gameSize.x * 0.4 + roadWidth / 2, gameSize.y * 0.65);
    path.lineTo(gameSize.x * 0.5 + roadWidth / 2, gameSize.y); // Bottom right of road

    path.close();

    canvas.drawPath(path, paint);
  }

}
