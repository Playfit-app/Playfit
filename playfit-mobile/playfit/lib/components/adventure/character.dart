import 'package:flame/events.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class Character extends SpriteComponent with TapCallbacks {
  final Vector2 characterPosition;
  final Function onTap;
  final BuildContext context;
  late SpriteComponent _comment;

  Character({
    required this.characterPosition,
    required this.onTap,
    required this.context,
  }) {
    size = Vector2(410, 700);
    scale = Vector2(0.15, 0.15);
    position = characterPosition;
  }

  @override
  Future<void> onLoad() async {
    sprite = await Sprite.load('character.png');

    _comment = SpriteComponent(
      sprite: await Sprite.load('comments.png'),
      size: Vector2(90, 90),
      position: Vector2(position.x - size.x / 1.5, position.y - size.y - 200),
      scale: Vector2(4, 4),
    );
    add(_comment);

    updateDirection(0);
  }

  @override
  void onTapDown(TapDownEvent event) {
    onTap(context);
  }

  void updateDirection(int checkpoint) {
    if ((checkpoint == 0 ||
            checkpoint == 3 ||
            checkpoint == 4 ||
            checkpoint == 6) &&
        transform.scale.x > 0) {
      transform.flipHorizontally();
      position.x -= 57;
    } else if ((checkpoint == 1 ||
            checkpoint == 2 ||
            checkpoint == 4 ||
            checkpoint == 5) &&
        transform.scale.x < 0) {
      transform.flipHorizontally();
    }
  }
}
