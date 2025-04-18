import 'package:flutter/material.dart';

// Character widget that can move from a point a to a point b
class Character extends StatefulWidget {
  final Animation<double> animation;
  final List<Offset> points;
  final int startingPoint;
  final Map<String, String?> images;

  const Character({
    super.key,
    required this.animation,
    required this.points,
    required this.startingPoint,
    required this.images,
  });

  @override
  State<Character> createState() => _CharacterState();
}

class _CharacterState extends State<Character> {
  Offset _getBezierPoint(double t, Offset scale) {
    Offset p0 = widget.points[widget.startingPoint];
    Offset p1 = Offset(220 * scale.dx,
        widget.points[widget.startingPoint].dy - 100); // Control point
    Offset p2 = widget.points[widget.startingPoint + 1];

    double x =
        (1 - t) * (1 - t) * p0.dx + 2 * (1 - t) * t * p1.dx + t * t * p2.dx;
    double y =
        (1 - t) * (1 - t) * p0.dy + 2 * (1 - t) * t * p1.dy + t * t * p2.dy;

    return Offset(x, y);
  }

  @override
  Widget build(BuildContext context) {
    final scale = Offset(
      MediaQuery.of(context).size.width / 411,
      MediaQuery.of(context).size.height / 831,
    );

    return AnimatedBuilder(
      animation: widget.animation,
      builder: (context, child) {
        Offset position = _getBezierPoint(widget.animation.value, scale);
        return Positioned(
          left: position.dx,
          top: position.dy,
          child: Image.network(
            widget.images['base_character']!,
            width: 100,
            height: 100,
          ),
        );
      },
    );
  }
}
