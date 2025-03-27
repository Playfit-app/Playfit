import 'package:flutter/material.dart';
import 'package:playfit/components/level_cinematic/character.dart';
import 'package:playfit/components/level_cinematic/hill.dart';
import 'package:playfit/components/level_cinematic/decorations.dart';
import 'package:playfit/components/level_cinematic/landmark.dart';

class WorkoutProgressionPage extends StatefulWidget {
  final int difficulty;
  final Map<String, String> decorationImages;
  final String landmarkImage;
  final int startingPoint;

  const WorkoutProgressionPage({
    super.key,
    required this.difficulty,
    required this.decorationImages,
    required this.landmarkImage,
    required this.startingPoint,
  });

  @override
  State<WorkoutProgressionPage> createState() => _WorkoutProgressionPageState();
}

class _WorkoutProgressionPageState extends State<WorkoutProgressionPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  late List<Offset> points;

  @override
  void initState() {
    super.initState();

    final screenSize = MediaQueryData.fromView(
            WidgetsBinding.instance.platformDispatcher.views.first)
        .size;
    final scale = Offset(screenSize.width / 411, screenSize.height / 831);

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..forward();

    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);

    points = [
      Offset(30 * scale.dx, screenSize.height - 200 * scale.dy),
      Offset(280 * scale.dx, screenSize.height - 300 * scale.dy),
      Offset(30 * scale.dx, screenSize.height - 350 * scale.dy),
      Offset(280 * scale.dx, screenSize.height - 400 * scale.dy),
      Offset(30 * scale.dx, screenSize.height - 450 * scale.dy),
      Offset(280 * scale.dx, screenSize.height - 560 * scale.dy),
    ];
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scale = Offset(
      MediaQuery.of(context).size.width / 411,
      MediaQuery.of(context).size.height / 831,
    );

    return Scaffold(
      body: Stack(
        children: [
          Container(
            color: const Color.fromARGB(255, 197, 222, 250),
          ),
          ...[
            for (var i = widget.difficulty + 1; i >= 0; i--)
              Hill(
                position: i,
                scale: scale,
                decorationImages: widget.decorationImages,
              ),
          ],
          Decorations(
            decorationImages: widget.decorationImages,
            nbHills: widget.difficulty + 2,
            scale: scale,
          ),
          Landmark(
            image: widget.landmarkImage,
            scale: scale,
            difficulty: widget.difficulty,
          ),
          Character(
            animation: _animation,
            points: points,
            startingPoint: widget.startingPoint,
          ),
        ],
      ),
    );
  }
}
