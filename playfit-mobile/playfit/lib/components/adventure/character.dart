import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:playfit/components/adventure/workout_session_dialog.dart';

class Character extends StatefulWidget {
  final Offset position;
  final Offset scale;
  final Size size;
  final bool isFlipped;
  final bool isMe;
  final Map<String, String?> images;
  final FlutterSecureStorage storage = const FlutterSecureStorage();

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
  Map<String, List<dynamic>> workoutSessionExercises = {
    'beginner': [],
    'intermediate': [],
    'advanced': [],
  };

  @override
  void initState() {
    super.initState();
    isFlipped = widget.isFlipped;
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> getWorkoutSessionExercises() async {
    final String url =
        '${dotenv.env['SERVER_BASE_URL']}/api/workout/get_workout_session_exercises/';
    final String? token = await widget.storage.read(key: 'token');

    final response = await http.get(
      Uri.parse(url),
      headers: {
        'Authorization': 'Token $token',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      for (String difficulty in data.keys) {
        workoutSessionExercises[difficulty] ??= [];
        setState(() {
          workoutSessionExercises[difficulty]!.addAll(
            data[difficulty].map((exercise) {
              return {
                'name': exercise['name'],
                'description': exercise['description'],
                'video_url': exercise['video_url'],
                'sets': exercise['sets'],
                'repetitions': exercise['repetitions'],
                'weight': exercise['weight'],
              };
            }).toList(),
          );
        });
      }
    } else {
      throw Exception('Failed to load exercises: ${response.statusCode}');
    }
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
        onTap: () async {
          if (widget.isMe) {
            if (workoutSessionExercises['beginner']!.isEmpty &&
                workoutSessionExercises['intermediate']!.isEmpty &&
                workoutSessionExercises['advanced']!.isEmpty) {
              await getWorkoutSessionExercises();
            }
            showDialog(
              context: context,
              builder: (context) {
                return WorkoutSessionDialog(
                  workoutSessionExercises: workoutSessionExercises,
                );
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
