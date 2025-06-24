import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:playfit/i18n/strings.g.dart';
import 'package:playfit/components/adventure/custom_tab_bar.dart';
import 'package:playfit/camera_page.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class WorkoutSessionDialog extends StatefulWidget {
  final Map<String, List<dynamic>> workoutSessionExercises;
  final String landmarkImageUrl;
  final int sessionLevel;
  final Map<String, String?> characterImages;
  final int city;
  final int level;

  const WorkoutSessionDialog({
    super.key,
    required this.workoutSessionExercises,
    required this.landmarkImageUrl,
    required this.sessionLevel,
    required this.characterImages,
    required this.city,
    required this.level,});

  @override
  State<WorkoutSessionDialog> createState() => _WorkoutSessionDialogState();
}

/// State class for the [WorkoutSessionDialog] widget.
///
/// This state manages the UI and logic for displaying a workout session dialog,
/// allowing users to select a workout difficulty and start a session.
///
/// Features:
/// - Displays a dialog with a close button, a centered title, a custom tab menu for difficulty selection,
///   and a start button.
/// - The selected difficulty is managed by the [difficulty] state variable and updated via the [CustomTabBar].
/// - On pressing the start button, navigates to the [CameraView] screen, passing the selected difficulty
///   and other relevant session data.

class _WorkoutSessionDialogState extends State<WorkoutSessionDialog> {
  String difficulty = 'beginner';
  final FlutterSecureStorage storage = const FlutterSecureStorage();

  Future<BoxType> _getUserBoxType() async {
    String? boxTypeStr = await storage.read(key: 'boxType');
    return boxTypeStr == 'bottom' ? BoxType.bottom : BoxType.left;
  }

  @override
  Widget build(BuildContext context) {
    // Dialog content
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 40, vertical: 60),
      alignment: Alignment.topCenter,
      elevation: 1,
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(5),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
        ),
        // Cross to close dialog on top left. Title centered on top. Custom tab menu. Content.
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                Text(
                  t.workout_session_dialog.session_title(
                      session_number: widget.sessionLevel.toString()),
                  style: GoogleFonts.amaranth(
                    fontSize: 32,
                  ),
                ),
                const SizedBox(width: 40),
              ],
            ),
            const SizedBox(height: 20),
            // Tab menu
            CustomTabBar(
              workoutSessionExercises: widget.workoutSessionExercises,
              onTabChanged: (difficulty) {
                setState(() {
                  this.difficulty = difficulty;
                });
              },
            ),
            ElevatedButton(
              onPressed: () async {
                BoxType boxType = await _getUserBoxType();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CameraView(
                      workoutSessionExercises: widget.workoutSessionExercises,
                      difficulty: difficulty,
                      currentExerciseIndex: 0,
                      landmarkImageUrl: widget.landmarkImageUrl,
                      boxType: boxType,
                      characterImages: widget.characterImages,
                      city: widget.city,
                      level: widget.level,
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF8871F),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: Text(t.workout_session_dialog.start_button,
                  style: TextStyle(
                    color: Colors.white,
                  )),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
