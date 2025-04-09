import 'package:flutter/material.dart';
import 'package:playfit/components/adventure/workout_session_dialog.dart';

class Character extends StatefulWidget {
  final Offset position;
  final Offset scale;
  final Size size;
  final bool isFlipped;

  Character({
    super.key,
    required Offset position,
    required this.scale,
    required this.size,
    required this.isFlipped,
  }) : position = Offset(
          position.dx - size.width * scale.dx / 2,
          position.dy - size.height * scale.dy,
        );

  @override
  State<Character> createState() => _CharacterState();
}

class _CharacterState extends State<Character> {
  late Image image;
  late bool isFlipped;

  @override
  void initState() {
    super.initState();
    isFlipped = widget.isFlipped;
    image = Image.asset(
      'assets/images/character.png',
      height: widget.size.height * widget.scale.dy,
      width: widget.size.width * widget.scale.dx,
    );
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
          showDialog(
            context: context,
            builder: (context) {
              return const WorkoutSessionDialog();
            },
          );
        },
        child: Transform(
          alignment: Alignment.center,
          transform: Matrix4.rotationY(isFlipped ? 3.14 : 0),
          child: image,
        ),
      ),
    );
  }
}
