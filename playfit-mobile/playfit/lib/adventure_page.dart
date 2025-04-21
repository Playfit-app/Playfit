import 'dart:async';
import 'dart:convert';
import 'dart:ui' as ui;
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
  final String? completedDifficulty;

  const AdventurePage({
    super.key,
    this.moveCharacter = false,
    this.completedDifficulty,
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
  late Map<String, dynamic> _decorationImages;

  @override
  void initState() {
    super.initState();
    if (widget.moveCharacter) {
      completeWorkoutSession();
    }
  }

  void completeWorkoutSession() async {
    final String baseUrl = '${dotenv.env['SERVER_BASE_URL']}/api/workout';
    final String? token = await storage.read(key: 'token');

    final response = await http
        .patch(Uri.parse('$baseUrl/update_workout_session/'), headers: {
      'Authorization': 'Token $token',
    }, body: {
      'difficulty': widget.completedDifficulty!,
    });

    if (response.statusCode == 200) {
    } else {
      print("Can't update workout session");
    }
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
      throw Exception(
          'No checkpoints or world positions available. Please try again later.');
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

  Future<Map<String, dynamic>> _getDecorationImages(String country) async {
    final String url =
        '${dotenv.env['SERVER_BASE_URL']}/api/social/get-decoration-images/$country/';
    final String? token = await storage.read(key: 'token');

    final response = await http.get(
      Uri.parse(url),
      headers: {
        'Authorization': 'Token $token',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      return data;
    } else {
      throw Exception('Failed to load decoration images');
    }
  }

  List<Road> _createRoads(Map<String, dynamic> decorationImages) {
    List<Road> roads = [];
    combinedPath = Path();

    Size screenSize = MediaQueryData.fromView(
            WidgetsBinding.instance.platformDispatcher.views.first)
        .size;
    double referenceScreenHeight = 798;
    double referenceScreenWidth = 411;

    double height = referenceScreenHeight * nbCities +
        (referenceScreenHeight * 0.5 * (nbCities - 1));
    double startY = height;
    Offset scale = Offset(
      screenSize.width / referenceScreenWidth,
      screenSize.height / referenceScreenHeight,
    );
    int cityIndex = 0;

    for (int i = 0; i < nbCities + (nbCities - 1); i++) {
      Road road;

      if (i % 2 == 0) {
        road = CityRoad(
          startY: startY,
          screenSize: screenSize,
          scale: scale,
          decorationImages: decorationImages,
          cityIndex: cityIndex,
        );
        cityIndex++;
      } else {
        road = TransitionRoad(
          startY: startY,
          screenSize: screenSize,
          scale: scale,
          decorationImages: decorationImages,
          cityIndex: i,
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

  Future<List<dynamic>> _loadPositionsAndImages() async {
    final positions = await _getWorldPositions();
    final String country = positions.first['country'];
    _decorationImages = await _getDecorationImages(country);
    Map<String, dynamic> images = {
      'tree': await UIImageCacheManager().loadImageFromNetwork(
          '${dotenv.env['SERVER_BASE_URL']}${_decorationImages['tree']}'),
      'flag': await UIImageCacheManager().loadImageFromNetwork(
          '${dotenv.env['SERVER_BASE_URL']}${_decorationImages['flag']}'),
      'building': await UIImageCacheManager().loadImageFromNetwork(
          '${dotenv.env['SERVER_BASE_URL']}${_decorationImages['building']}'),
      'country': [],
    };

    for (var i = 0; i < _decorationImages['country'].length; i++) {
      final countryImages = await Future.wait(
        _decorationImages['country'][i].map<Future<ui.Image>>((imageUrl) async {
          final fullUrl = '${dotenv.env['SERVER_BASE_URL']}$imageUrl';

          return await UIImageCacheManager().loadImageFromNetwork(fullUrl);
        }).toList(),
      );
      images['country'].add(countryImages);
    }

    return [images, positions];
  }

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;

    return FutureBuilder(
      future: _loadPositionsAndImages(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final String serverBaseUrl = dotenv.env['SERVER_BASE_URL']!;
        final images = snapshot.data![0] as Map<String, dynamic>;
        final worldPositions = snapshot.data![1] as List<dynamic>;

        nbCities = images['country'].length;
        double referenceScreenHeight = 798;
        double height = referenceScreenHeight * nbCities +
            (referenceScreenHeight * 0.5 * (nbCities - 1));

        final roads = _createRoads(images);

        checkpoints = roads
            .map((road) => road.getCheckpoints().map((c) => c.position))
            .expand((element) => element)
            .toList();

        WidgetsBinding.instance.addPostFrameCallback((_) {
          _scrollToCharacter(worldPositions);
        });

        return Scaffold(
          body: SingleChildScrollView(
            controller: _scrollController,
            reverse: true,
            child: SizedBox(
              height: height,
              width: screenSize.width,
              child: Stack(
                children: [
                  RepaintBoundary(
                    child: CustomPaint(
                      size: Size(screenSize.width, height),
                      painter: _RoadPainter(roads),
                    ),
                  ),
                  ...[
                    for (int i = 0; i < worldPositions.length; i++)
                      if (i == 0 ||
                          worldPositions[i]['country'] ==
                                  worldPositions[0]['country'] &&
                              checkpoints[worldPositions[i]
                                      ['current_checkpoint']] !=
                                  checkpoints[worldPositions[0]
                                      ['current_checkpoint']])
                        Character(
                          position: (i == 0 && widget.moveCharacter)
                              ? checkpoints[
                                  worldPositions[i]['current_checkpoint'] + 1]
                              : checkpoints[worldPositions[i]
                                  ['current_checkpoint']],
                          scale: const Offset(0.15, 0.15),
                          size: const Size(410, 732),
                          isFlipped:
                              worldPositions[i]['current_checkpoint'] % 2 == 0,
                          isMe: i == 0,
                          images: {
                            'base_character':
                                '$serverBaseUrl${worldPositions[i]['character']['base_character']['image']}',
                            'hat':
                                '$serverBaseUrl${worldPositions[i]['character']['hat']}',
                            'backpack':
                                '$serverBaseUrl${worldPositions[i]['character']['backpack']}',
                            'shirt':
                                '$serverBaseUrl${worldPositions[i]['character']['shirt']}',
                            'pants':
                                '$serverBaseUrl${worldPositions[i]['character']['pants']}',
                            'shoes':
                                '$serverBaseUrl${worldPositions[i]['character']['shoes']}',
                            'gloves':
                                '$serverBaseUrl${worldPositions[i]['character']['gloves']}',
                            'landmark': (worldPositions[0]['status'] ==
                                    'in_city')
                                ? '${_decorationImages['country'][worldPositions[0]['city'] - 1][worldPositions[0]['level'] - 1]}'
                                : "/media/decorations/flag.webp",
                          },
                          sessionLevel: worldPositions[0]['level'],
                        ),
                  ]
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
