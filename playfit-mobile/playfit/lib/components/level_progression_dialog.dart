import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:playfit/components/experience_circle.dart';
import 'package:playfit/components/dotted_line.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class LevelProgressionDialog extends StatelessWidget {
  final List<dynamic> images;
  const LevelProgressionDialog({super.key, required this.images});

  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> levels = [
      {
        'image': '${dotenv.env['SERVER_BASE_URL']}${images[2]}',
        'completed': false,
        'title': 'Everest',
      },
      {
        'image': '${dotenv.env['SERVER_BASE_URL']}${images[1]}',
        'completed': false,
        'title': 'Kilimanjaro',
      },
      {
        'image': '${dotenv.env['SERVER_BASE_URL']}${images[0]}',
        'completed': true,
        'title': 'Mont Blanc',
        'description':
            'Le Mont blanc est plus haut sommet des Alpes et d\'Europe occidentale, situé à la frontière entre la France et l\'Italie. Il est considéré comme le berceau de l\'alpinisme, avec sa première ascension réussie en 1786.',
        'height': 4808,
        'xp': 70,
        'xpRequired': 100,
      },
    ];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.8,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.orange, width: 1.5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: SingleChildScrollView(
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
    );
  }

  Widget _buildLevelProgressionColumn(
      BuildContext context, List<Map<String, dynamic>> levels) {
    final double imageSize = MediaQuery.of(context).size.width * 0.22;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(levels.length, (i) {
        final level = levels[i];
        final isLast = i == levels.length - 1;
        final isCurrent = i == levels.length - 1;

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Avatar and line column
            Column(
              children: [
                // Avatar
                isCurrent
                    ? ExperienceCircle(
                        currentXP: (level['xp'] as int).toDouble(),
                        requiredXP: (level['xpRequired'] as int).toDouble(),
                        child: Padding(
                          padding: const EdgeInsets.all(6.0),
                          child: Opacity(
                            opacity: level['completed'] ? 1.0 : 0.4,
                            child: CircleAvatar(
                              radius: (imageSize - 12) / 2,
                              backgroundImage: NetworkImage(level['image']),
                            ),
                          ),
                        ),
                      )
                    : Opacity(
                        opacity: level['completed'] ? 1.0 : 0.4,
                        child: CircleAvatar(
                          radius: imageSize / 2,
                          backgroundImage: NetworkImage(level['image']),
                        ),
                      ),
                // Dotted line (only if not last)
                if (!isLast)
                  DottedLine(
                    height: imageSize + 12, // match avatar spacing perfectly
                    color: Colors.blueAccent,
                    dotSize: 4,
                    spacing: 8,
                  ),
              ],
            ),
            const SizedBox(width: 16),
            // Text content for current level
            if (isCurrent)
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: 12.0),
                  child: Column(
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
        );
      }),
    );
  }
}

void showLevelProgressionPopup(BuildContext context, List<dynamic> images) {
  showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: "Level Progression",
    barrierColor: Colors.black.withAlpha((0.2 * 255).toInt()),
    pageBuilder: (_, __, ___) {
      return Center(
        child: Material(
          color: Colors.transparent,
          child: LevelProgressionDialog(images: images),
        ),
      );
    },
  );
}
