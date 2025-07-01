import 'package:flutter/material.dart';
import 'package:playfit/i18n/strings.g.dart';
import 'package:playfit/services/workout_timer_service.dart';

/// A widget that displays a celebratory overlay after completing a stage or level.
///
/// The [CelebrationOverlay] shows a semi-transparent background with a centered
/// card containing the stage and level information, a character image, the final
/// completion time, and the difficulty level.
///
/// The overlay is responsive to screen size and uses custom styling for a festive look.
class CelebrationOverlay extends StatelessWidget {
  final Duration finalTime;
  final String city;
  final int level;
  final Map<String, String?> characterImages;
  final String difficulty;
  late WorkoutTimerService _workoutTimerService;

  CelebrationOverlay({
    super.key,
    required this.finalTime,
    required this.city,
    required this.level,
    required this.characterImages,
    required this.difficulty,
  }) {
    _workoutTimerService = WorkoutTimerService();
    // Ensure the timer is stopped when the overlay is created
    _workoutTimerService.stop();
    _workoutTimerService.reset();
  }

  int _calculateStarCount(Duration time, String difficulty) {
    final seconds = time.inSeconds;
    switch (difficulty.toLowerCase()) {
      case 'beginner':
        if (seconds <= 40) return 3;
        if (seconds <= 50) return 2;
        if (seconds <= 60) return 1;
        break;
      case 'intermediate':
        if (seconds <= 90) return 3;
        if (seconds <= 110) return 2;
        if (seconds <= 120) return 1;
        break;
      case 'advanced':
        if (seconds <= 150) return 3;
        if (seconds <= 180) return 2;
        if (seconds <= 210) return 1;
        break;
    }
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    final double screenWidth = MediaQuery.of(context).size.width;
    final int starCount = _calculateStarCount(finalTime, difficulty);

    return Container(
      color: Colors.black.withAlpha(153), // semi-transparent background
      child: Center(
        child: Container(
          width: screenWidth * 0.9,
          height: screenHeight * 0.7,
          padding: EdgeInsets.all(screenWidth * 0.06),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(screenWidth * 0.05),
            border: Border.all(
              color: Colors.deepOrangeAccent,
              width: screenWidth * 0.01,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: screenWidth * 0.03,
                offset: Offset(0, screenWidth * 0.015),
              ),
            ],
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                Text(
                  t.workout_session_dialog.level
                      .replaceAll('{city}', city.toString())
                      .replaceAll('{level}', level.toString()),
                  style: TextStyle(
                    fontSize: screenWidth * 0.07,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: screenHeight * 0.02),
                Container(
                  height: screenHeight * 0.25,
                  width: double.infinity,
                  padding: EdgeInsets.all(screenWidth * 0.03),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8E8E8),
                    border: Border.all(color: Colors.orange.shade200),
                    borderRadius: BorderRadius.circular(screenWidth * 0.03),
                  ),
                  child: Stack(
                    children: [
                      Center(
                        child: Padding(
                          padding:
                              EdgeInsets.symmetric(vertical: screenHeight * 0.02),
                          child: Image.network(
                            characterImages['base_character']!,
                            width: 100,
                            height: 100,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: screenHeight * 0.025),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Column(
                      children: [
                        Icon(Icons.timer,
                            color: Colors.orange, size: screenWidth * 0.07),
                        SizedBox(height: screenHeight * 0.015),
                        // Icon(Icons.local_fire_department,
                        //     color: Colors.orange, size: screenWidth * 0.07),
                      ],
                    ),
                    SizedBox(width: screenWidth * 0.04),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${finalTime.inMinutes}:${(finalTime.inSeconds % 60).toString().padLeft(2, '0')}',
                          style: TextStyle(fontSize: screenWidth * 0.05),
                        ),
                        SizedBox(height: screenHeight * 0.015),
                        // Text("800 Cal",
                        //     style: TextStyle(fontSize: screenWidth * 0.05)),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: screenHeight * 0.02),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(3, (index) {
                    return Icon(
                      index < starCount ? Icons.star : Icons.star_border,
                      color: Colors.yellow,
                      size: screenWidth * 0.08,
                    );
                  }),
                ),
                Divider(color: Colors.orange),
                SizedBox(height: screenHeight * 0.015),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      t.workout.difficulty,
                      style: TextStyle(
                        fontSize: screenWidth * 0.055,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      t.workout.easy,
                      style: TextStyle(
                        fontSize: screenWidth * 0.055,
                        fontWeight: FontWeight.bold,
                        color: Colors.orange,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
