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
import 'package:playfit/components/anecdote_displayer.dart';
import 'package:playfit/utils/image.dart';

class AdventurePage extends StatefulWidget {
  final bool moveCharacter;
  final bool workoutDone;
  final String? landmarkUrl;
  // final String? completedDifficulty;

  const AdventurePage({
    super.key,
    this.moveCharacter = false,
    this.workoutDone = false,
    this.landmarkUrl = null,
    // this.completedDifficulty,
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
  late bool workoutDone;

  @override
  void initState() {
    super.initState();
    workoutDone = widget.workoutDone;
  }

  /// Scrolls to the character's position based on the current checkpoint.
  /// This method retrieves the world positions and animates the scroll
  /// to the character's position on the screen.
  ///
  /// `worldPositions` is a list of positions that contains the current checkpoint
  /// for the character.
  ///
  /// Throws an exception if there are no checkpoints or world positions available.
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

  /// Fetches the world positions from the server.
  /// This method retrieves the current positions of characters in the world
  /// and calculates their current checkpoints based on their status and level.
  ///
  /// Returns a [Future] that resolves to a list of world positions.
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
          final int offsetTransition =
              (d['city'] - 1) * 4; // Each transition has 4 checkpoints
          final int offsetCity =
              (d['city'] - 1) * 6; // Each city has 6 checkpoints

          d['current_checkpoint'] = level + offsetTransition + offsetCity;
        } else {
          // If the character is not in a city, calculate the checkpoint based on the transition
          // and the city they are coming from.
          final int level = d['level'] - 1;
          final int offsetTransition =
              (d['city_from'] - 1) * 4; // Each transition has 4 checkpoints
          final int offsetCity =
              d['city_from'] * 6; // Each city has 6 checkpoints

          d['current_checkpoint'] = level + offsetTransition + offsetCity;
        }
      }

      return data;
    } else {
      throw Exception('Failed to load world positions');
    }
  }

  /// Fetches decoration images for the specified country.
  /// This method retrieves images used for decorating the roads and cities
  /// based on the country specified in the world positions.
  ///
  /// `country` is the country for which to fetch decoration images.
  ///
  /// Returns a [Future] that resolves to a map of decoration images.
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

  /// Creates a list of roads based on the number of cities and decoration images.
  /// This method generates a list of roads, each represented by a `Road` object,
  /// and combines their paths into a single `Path` object.
  ///
  /// `decorationImages` is a map containing images used for decorating the roads.
  /// `screenSize` is the size of the screen, used to calculate the height of the roads.
  ///
  /// Returns a list of `Road` objects representing the roads in the adventure.
  List<Road> _createRoads(Map<String, dynamic> decorationImages,
      Size screenSize, String countryColor) {
    List<Road> roads = [];
    combinedPath = Path();
    // Calculate the total height of the roads based on the number of cities
    // A city road takes the full height of the screen,
    // and a transition road takes half the height of the screen.
    double height = screenSize.height * nbCities +
        (screenSize.height * 0.5 * (nbCities - 1));
    double startY = height;
    int cityIndex = 0;

    for (int i = 0; i < nbCities + (nbCities - 1); i++) {
      Road road;

      // Alternate between CityRoad and TransitionRoad
      // CityRoad for even indices, TransitionRoad for odd indices
      if (i % 2 == 0) {
        road = CityRoad(
          startY: startY,
          screenSize: screenSize,
          decorationImages: decorationImages,
          cityIndex: cityIndex,
          cityColor: _hexToColor(countryColor),
        );
        cityIndex++;
      } else {
        road = TransitionRoad(
          startY: startY,
          screenSize: screenSize,
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

  Color _hexToColor(String hex) {
    hex = hex.replaceAll("#", "");
    if (hex.length == 6) {
      hex = "FF$hex";
    }
    return Color(int.parse(hex, radix: 16));
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  /// Loads the world positions and decoration images asynchronously.
  /// This method fetches the world positions from the server and retrieves
  /// the decoration images based on the country of the first position.
  ///
  /// Returns a [Future] that resolves to a list containing the decoration images
  /// and the world positions.
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
      'path': await UIImageCacheManager().loadImageFromNetwork(
          '${dotenv.env['SERVER_BASE_URL']}${_decorationImages['path']}'),
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
    return FutureBuilder(
      future: _loadPositionsAndImages(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        Size screenSize = MediaQuery.of(context).size;
        final String serverBaseUrl = dotenv.env['SERVER_BASE_URL']!;
        final images = snapshot.data![0] as Map<String, dynamic>;
        final worldPositions = snapshot.data![1] as List<dynamic>;
        final String countryColor = worldPositions[0]['country_color'];

        nbCities = images['country'].length;
        double height = screenSize.height * nbCities +
            (screenSize.height * 0.5 * (nbCities - 1));

        final roads = _createRoads(images, screenSize, countryColor);

        // Extract checkpoints from roads
        // Each road has checkpoints, we need to flatten them into a single list
        // This will be used to position the characters correctly
        // We assume that each road has checkpoints defined in its getCheckpoints method
        // and that each checkpoint has a position property.
        checkpoints = roads
            .map((road) => road.getCheckpoints().map((c) => c.position))
            .expand((element) => element)
            .toList();

        // Scroll to the character's position after the first frame is rendered
        // This ensures that the character is visible on the screen
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _scrollToCharacter(worldPositions);
        });

        return Scaffold(
          body: Stack(
            children: [
              SingleChildScrollView(
                controller: _scrollController,
                reverse: true,
                child: SizedBox(
                  height: height,
                  width: screenSize.width,
                  child: Stack(
                    children: [
                      // Draw the roads and decorations using a CustomPainter
                      RepaintBoundary(
                        child: CustomPaint(
                          size: Size(screenSize.width, height),
                          painter: _RoadPainter(roads),
                        ),
                      ),
                      // Display the characters on the roads (user's character and friends)
                      ...[
                        for (int i = 0; i < worldPositions.length; i++)
                          // Only display the character if they are in the same country
                          // or if it's the first character (the user's character)
                          if (i == 0 ||
                              worldPositions[i]['country'] ==
                                      worldPositions[0]['country'] &&
                                  checkpoints[worldPositions[i]
                                          ['current_checkpoint']] !=
                                      checkpoints[worldPositions[0]
                                          ['current_checkpoint']])
                            Character(
                              position: (i == 0 && widget.moveCharacter)
                                  ? checkpoints[worldPositions[i]
                                          ['current_checkpoint'] +
                                      1]
                                  : checkpoints[worldPositions[i]
                                      ['current_checkpoint']],
                              scale: const Offset(0.15, 0.15),
                              size: const Size(410, 732),
                              isFlipped:
                                  worldPositions[i]['current_checkpoint'] % 2 ==
                                      0,
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
                                'tree': '${_decorationImages['tree']}',
                                'building': '${_decorationImages['building']}',
                                'path': '${_decorationImages['path']}',
                              },
                              sessionLevel: worldPositions[0]['level'],
                              city: worldPositions[0]['city_name'],
                              level: worldPositions[0]['level'],
                            ),
                      ],
                      // Display the landmark if the workout is done
                    ],
                  ),
                ),
              ),
              // White gradient at the top of the screen
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: Container(
                  height: MediaQuery.of(context).size.height * 0.3,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.white,
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
              if (workoutDone && widget.landmarkUrl != null)
                Positioned(
                  child: AnecdoteDisplayer(
                    landmarkUrl: widget.landmarkUrl!,
                    onClose: () {
                      setState(() {
                        workoutDone = false;
                      });
                    },
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _RoadPainter extends CustomPainter {
  final List<Road> roads;

  _RoadPainter(this.roads);

  @override
  void paint(Canvas canvas, Size size) {
    for (Road road in roads) {
      road.drawBackground(canvas);
    }

    for (Road road in roads) {
      road.paint(canvas, size);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
