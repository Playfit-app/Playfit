import 'package:flutter/material.dart';

/// A widget that displays a left-aligned information box containing:
/// - The elapsed time with a timer icon.
/// - The current count and target count with a fitness icon.
/// - A mascot image at the bottom.
class LeftBoxWidget extends StatelessWidget {
  final Duration elapsedTime;
  final int count;
  final int targetCount;

  const LeftBoxWidget({super.key, required this.elapsedTime, required this.count, required this.targetCount});

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    
    // Responsive sizing based on screen dimensions
    final containerWidth = screenWidth * 0.22; // 22% of screen width
    final iconSize = screenHeight * 0.04; // 4% of screen height
    final fontSize = screenHeight * 0.022; // 2.2% of screen height
    final mascotHeight = screenHeight * 0.12; // 12% of screen height
    final verticalPadding = screenHeight * 0.05; // 5% of screen height
    final spacing = screenHeight * 0.03; // 3% of screen height
    
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        width: containerWidth.clamp(75.0, 100.0), // Min 75, Max 100
        padding: EdgeInsets.symmetric(vertical: verticalPadding),
        margin: const EdgeInsets.only(left: 0),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.horizontal(
            right: Radius.circular(20),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Column(
              children: [
                Icon(
                  Icons.timer,
                  color: Colors.orange,
                  size: iconSize.clamp(24.0, 36.0),
                ),
                SizedBox(height: spacing * 0.2),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Text(
                      '${elapsedTime.inMinutes}:${(elapsedTime.inSeconds % 60).toString().padLeft(2, '0')}',
                      style: TextStyle(
                        fontSize: fontSize.clamp(14.0, 20.0),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: spacing.clamp(16.0, 30.0)),
            Column(
              children: [
                Icon(
                  Icons.fitness_center,
                  color: Colors.orange,
                  size: iconSize.clamp(24.0, 36.0),
                ),
                SizedBox(height: spacing * 0.2),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Text(
                      '$count / $targetCount',
                      style: TextStyle(
                        fontSize: fontSize.clamp(14.0, 20.0),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: spacing.clamp(16.0, 30.0)),
            SizedBox(
              height: mascotHeight.clamp(70.0, 110.0),
              child: const Image(
                image: AssetImage("assets/images/mascot.png"),
                fit: BoxFit.contain,
              ),
            ),
          ],
        ),
      ),
    );
  }
}