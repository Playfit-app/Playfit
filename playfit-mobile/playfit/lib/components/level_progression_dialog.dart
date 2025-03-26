import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:playfit/components/experience_circle.dart';
import 'package:playfit/components/dotted_line.dart';

class LevelProgressionDialog extends StatelessWidget {
  const LevelProgressionDialog({super.key});

  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> levels = [
      {
        'image': 'assets/images/mountains/everest.png',
        'completed': false,
        'title': 'Everest',
      },
      {
        'image': 'assets/images/mountains/kilimanjaro.png',
        'completed': false,
        'title': 'Kilimanjaro',
      },
      {
        'image': 'assets/images/mountains/mont_blanc.png',
        'completed': true,
        'title': 'Mont Blanc',
        'description':
            'Le Mont blanc est plus haut sommet des Alpes et d\'Europe occidentale, situé à la frontière entre la France et l\'Italie. Il est considéré comme le berceau de l\'alpinisme, avec sa première ascension réussie en 1786.',
        'height': 4808,
        'xp': 70,
        'xpRequired': 100,
      },
    ];

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(16),
      child: Stack(
        alignment: Alignment.center,
        children: [
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
            child: Container(
              color: Colors.black.withAlpha((0.2 * 255).toInt()),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.orange, width: 1.5),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Align(
                  alignment: Alignment.topLeft,
                  child: GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: const Icon(Icons.close),
                  ),
                ),
                const SizedBox(height: 10),
                _buildLevelProgressionColumn(context, levels),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLevelProgressionColumn(
      BuildContext context, List<Map<String, dynamic>> levels) {
    final double imageSize = MediaQuery.of(context).size.width * 0.22;

    return Column(
      children: List.generate(levels.length, (i) {
        final level = levels[i];
        final isLast = i == levels.length - 1;
        final isCurrent = isLast;

        return SizedBox(
          height: imageSize + 100, // make room for the dotted line
          child: Stack(
            children: [
              if (!isLast)
                Positioned(
                  top: imageSize,
                  left: imageSize / 2 - 1,
                  child: const DottedLine(
                    height: 100,
                    color: Colors.blueAccent,
                    dotSize: 4,
                    spacing: 8,
                  ),
                ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: 16),
                    child: isCurrent
                        ? ExperienceCircle(
                            currentXP: (level['xp'] as int).toDouble(),
                            requiredXP: (level['xpRequired'] as int).toDouble(),
                            child: Padding(
                              padding: const EdgeInsets.all(6.0),
                              child: Opacity(
                                opacity: level['completed'] ? 1.0 : 0.4,
                                child: CircleAvatar(
                                  radius: (imageSize - 12) / 2,
                                  backgroundImage: AssetImage(level['image']),
                                ),
                              ),
                            ),
                          )
                        : Opacity(
                            opacity: level['completed'] ? 1.0 : 0.4,
                            child: CircleAvatar(
                              radius: imageSize / 2,
                              backgroundImage: AssetImage(level['image']),
                            ),
                          ),
                  ),
                  if (isCurrent)
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "${level['title']} - ${level['height']} mètres",
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Container(
                                  width: double.infinity,
                                  height: 1.5,
                                  color: Colors.orange,
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              level['description'],
                              style: const TextStyle(fontSize: 14),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        );
      }),
    );
  }
}
