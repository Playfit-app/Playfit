import 'dart:async';
import 'dart:ui' as ui;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
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
  final FlutterSecureStorage storage = const FlutterSecureStorage();
  // late AnimationController _animationController;
  // late Animation<double> _animation;
  late Path combinedPath;
  late List<Offset> checkpoints;
  late int nbCities;
  // int currentCheckpoint = 0;
  final List<String> imagePaths = [
    'assets/images/france/paris/eiffel_tower.png',
    'assets/images/france/paris/apt.png',
    'assets/images/tree.png',
  ];
  late Future<List<dynamic>> _worldPositions;

  @override
  void initState() {
    super.initState();
    nbCities = 2;
    _worldPositions = _getWorldPositions();
  }

  void _scrollToCharacter(List<dynamic> worldPositions) {
    if (checkpoints.isNotEmpty && worldPositions.isNotEmpty) {
      final targetOffset = checkpoints[worldPositions[0]['current_checkpoint']];
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent -
            targetOffset.dy +
            (MediaQuery.of(context).size.height * 0.85),
        duration: const Duration(milliseconds: 800),
        curve: Curves.easeInOut,
      );
    } else {
      debugPrint("No checkpoints or world positions available.");
    }
  }

  Future<List<dynamic>> _getWorldPositions() async {
    final String baseUrl = '${dotenv.env['SERVER_BASE_URL']}/api/social';
    final String? token = await storage.read(key: 'token');

    final response = await http.get(
      Uri.parse('$baseUrl/get-world-positions/'),
      headers: {
        'Authorization': 'Token $token',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      for (var i = 0; i < data.length; i++) {
        var d = data[i];

        if (d['status'] == 'in_city') {
          final int level = d['level'] - 1;
          final int offsetTransition = (d['city'] - 1) * 4;
          final int offsetCity = (d['city'] - 1) * 6;

          d['current_checkpoint'] = level + offsetTransition + offsetCity;
        } else {
          final int level = d['level'] - 1;
          final int offsetTransition = (d['city_from'] - 1) * 4;
          final int offsetCity = d['city_from'] * 6;

          d['current_checkpoint'] = level + offsetTransition + offsetCity;
        }
      }

      return data;
    } else {
      throw Exception('Failed to load world positions');
    }
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
      future: Future.wait([
        Future.wait(imagePaths.map((imagePath) {
          return UIImageCacheManager().loadImageFromAssets(imagePath);
        })),
        _worldPositions,
      ]),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final List<ui.Image> images = snapshot.data![0] as List<ui.Image>;
        final String serverBaseUrl = dotenv.env['SERVER_BASE_URL']!;

        final decorationImages = {
          "landmark": images[0],
          "building": images[1],
          "tree": images[2],
        };
        final roads = _createRoads(decorationImages);
        checkpoints = roads
            .map((road) => road.getCheckpoints().map((c) => c.position))
            .expand((element) => element)
            .toList();

        WidgetsBinding.instance.addPostFrameCallback((_) {
          _scrollToCharacter(snapshot.data![1]);
        });

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
                  for (int i = 0; i < snapshot.data![1].length; i++)
                    Character(
                      position: checkpoints[snapshot.data![1][i]
                          ['current_checkpoint']],
                      scale: const Offset(0.15, 0.15),
                      size: const Size(410, 732),
                      isFlipped:
                          snapshot.data![1][i]['current_checkpoint'] % 2 == 0,
                      isMe: i == 0,
                      images: {
                        'base_character':
                            '$serverBaseUrl${snapshot.data![1][i]['character']['base_character']['image']}',
                        'hat': '$serverBaseUrl${snapshot.data![1][i]['hat']}',
                        'backpack':
                            '$serverBaseUrl${snapshot.data![1][i]['backpack']}',
                        'shirt':
                            '$serverBaseUrl${snapshot.data![1][i]['shirt']}',
                        'pants':
                            '$serverBaseUrl${snapshot.data![1][i]['pants']}',
                        'shoes':
                            '$serverBaseUrl${snapshot.data![1][i]['shoes']}',
                        'gloves':
                            '$serverBaseUrl${snapshot.data![1][i]['gloves']}',
                      },
                    ),
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
