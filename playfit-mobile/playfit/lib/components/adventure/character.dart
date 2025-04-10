import 'package:flutter/material.dart';
import 'package:playfit/components/adventure/workout_session_dialog.dart';

class Character extends StatefulWidget {
  final Offset position;
  final Offset scale;
  final Size size;
  final bool isFlipped;
  final bool isMe;
  final Map<String, String?> images;

  Character({
    super.key,
    required Offset position,
    required this.scale,
    required this.size,
    required this.isFlipped,
    required this.isMe,
    required this.images,
  }) : position = Offset(
          position.dx - size.width * scale.dx / 2,
          position.dy - size.height * scale.dy,
        );

  @override
  State<Character> createState() => _CharacterState();
}

class _CharacterState extends State<Character> {
  late bool isFlipped;

  @override
  void initState() {
    super.initState();
    isFlipped = widget.isFlipped;
  }

  void flip() {
    setState(() {
      isFlipped = !isFlipped;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: widget.position.dx,
      top: widget.position.dy,
      child: GestureDetector(
        onTap: () {
          if (widget.isMe) {
            showDialog(
              context: context,
              builder: (context) {
                return const WorkoutSessionDialog();
              },
            );
          }
        },
        child: Transform(
          alignment: Alignment.center,
          transform: Matrix4.rotationY(widget.isFlipped ? 3.14 : 0),
          child: Image.network(
            widget.images['base_character']!,
            height: widget.size.height * widget.scale.dy,
            width: widget.size.width * widget.scale.dx,
          ),
        ),
      ),
    );
  }
}
