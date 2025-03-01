import 'package:flame/components.dart';

class DecorationSpriteComponent extends SpriteComponent {
  final String imagePath;

  DecorationSpriteComponent({
    required this.imagePath, // Path to the sprite image
    required Vector2 position,
    required Vector2 size,
    double angle = 0.0,
  }) : super(
          position: position,
          size: size,
          angle: angle,
        );

  @override
  Future<void> onLoad() async {
    sprite = await Sprite.load(imagePath);
  }
}
