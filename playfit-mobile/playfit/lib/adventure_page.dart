import 'dart:async';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:playfit/components/adventure/roads/city_road.dart';
import 'package:playfit/components/adventure/roads/road.dart';
import 'package:playfit/components/adventure/roads/transition_road.dart';
import 'package:playfit/components/adventure/character.dart';
import 'package:playfit/utils/image.dart';

class AdventurePage extends StatefulWidget {
  final bool moveCharacter;

  const AdventurePage({
    super.key,
    this.moveCharacter = false,
  });

  @override
  State<AdventurePage> createState() => _AdventurePageState();
}

class _AdventurePageState extends State<AdventurePage>
    with SingleTickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  // late AnimationController _animationController;
  // late Animation<double> _animation;
  late Path combinedPath;
  late int nbCities;
  int currentCheckpoint = 0;
  final List<String> imagePaths = [
    'assets/images/paris/france/eiffel_tower.png',
    'assets/images/france/paris/apt.png',
    'assets/images/tree.png',
  ];

  @override
  void initState() {
    super.initState();
    nbCities = 2;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollController.jumpTo(_scrollController.position.minScrollExtent);
    });
    _scrollController.addListener(() {
      if (_scrollController.offset < 0) {
        _scrollController.jumpTo(0);
      }
    });
  }

  List<Road> _createRoads(Map<String, ui.Image> decorationImages) {
    List<Road> roads = [];
    combinedPath = Path();

    Size screenSize = MediaQueryData.fromView(
            WidgetsBinding.instance.platformDispatcher.views.first)
        .size;

    double height = screenSize.height * (nbCities + (nbCities - 1) * 0.5);
    double startY = height;
    Offset scale = Offset(
      screenSize.width / 411,
      height / (nbCities + (nbCities - 1) * 0.5) / 830,
    );

    for (int i = 0; i <= nbCities; i++) {
      Road road;

      if (i % 2 == 0) {
        road = CityRoad(
          startY: startY,
          scale: scale,
          decorationImages: decorationImages,
        );
      } else {
        road = TransitionRoad(
          startY: startY,
          scale: scale,
          decorationImages: decorationImages,
        );
      }
      startY = road.getStartY();
      roads.add(road);
      combinedPath.addPath(road.path, Offset.zero);
    }

    return roads;
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;
    double height = screenSize.height * (nbCities + (nbCities - 1) * 0.5);

    return FutureBuilder(
      future: Future.wait(
        imagePaths.map((imagePath) {
          return UIImageCacheManager().loadImageFromAssets(imagePath);
        }),
      ),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final decorationImages = {
          "landmark": snapshot.data![0],
          "building": snapshot.data![1],
          "tree": snapshot.data![2],
        };
        final roads = _createRoads(decorationImages);
        final checkpoints = roads
            .map((road) => road.getCheckpoints().map((c) => c.position))
            .expand((element) => element)
            .toList();

        return Scaffold(
          body: SizedBox(
            height: screenSize.height * 2,
            child: SingleChildScrollView(
              controller: _scrollController,
              reverse: true,
              child: Stack(
                children: [
                  RepaintBoundary(
                    child: CustomPaint(
                      size: Size(screenSize.width, height),
                      painter: _RoadPainter(roads),
                    ),
                  ),
                  Character(
                    position: checkpoints[currentCheckpoint],
                    scale: const Offset(0.15, 0.15),
                    size: const Size(410, 732),
                    isFlipped: currentCheckpoint % 2 == 0,
                  )
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _RoadPainter extends CustomPainter {
  final List<Road> roads;

  _RoadPainter(this.roads);

  void drawWhiteTopGradient(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomLeft,
        colors: [
          Colors.white,
          Colors.white.withAlpha(0),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, 292));

    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, 292), paint);
  }

  @override
  void paint(Canvas canvas, Size size) {
    for (Road road in roads) {
      road.drawBackground(canvas);
    }

    for (Road road in roads) {
      road.paint(canvas, size);
    }

    drawWhiteTopGradient(canvas, size);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
