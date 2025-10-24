import 'package:flutter/material.dart';

/// A widget that displays a bottom-aligned box containing workout information.
///
/// The widget features:
/// - A timer icon and formatted elapsed time (MM:SS).
/// - A fitness icon and the current/target count.
/// - A mascot image displayed on the right side.
class BottomBoxWidget extends StatelessWidget {
  final Duration elapsedTime;
  final int count;
  final int targetCount;

  const BottomBoxWidget({super.key, required this.elapsedTime, required this.count, required this.targetCount});

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    
    // Responsive sizing based on screen dimensions
    final containerHeight = screenHeight * 0.12; // 12% of screen height
    final horizontalPadding = screenWidth * 0.08; // 8% of screen width
    final iconSize = screenHeight * 0.035; // 3.5% of screen height
    final fontSize = screenHeight * 0.028; // 2.8% of screen height
    final mascotHeight = containerHeight * 0.7; // 70% of container height
    final iconSpacing = screenWidth * 0.02; // 2% of screen width
    
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        height: containerHeight.clamp(90.0, 120.0), // Min 90, Max 120
        padding: EdgeInsets.symmetric(horizontal: horizontalPadding.clamp(20.0, 60.0)),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              flex: 2,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.timer,
                    color: Colors.orange,
                    size: iconSize.clamp(24.0, 32.0),
                  ),
                  SizedBox(width: iconSpacing.clamp(6.0, 10.0)),
                  Flexible(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        '${elapsedTime.inMinutes}:${(elapsedTime.inSeconds % 60).toString().padLeft(2, '0')}',
                        style: TextStyle(
                          fontSize: fontSize.clamp(18.0, 28.0),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Flexible(
              flex: 2,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.fitness_center,
                    color: Colors.orange,
                    size: iconSize.clamp(24.0, 32.0),
                  ),
                  SizedBox(width: iconSpacing.clamp(6.0, 10.0)),
                  Flexible(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        '$count / $targetCount',
                        style: TextStyle(
                          fontSize: fontSize.clamp(18.0, 28.0),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Flexible(
              flex: 1,
              child: SizedBox(
                height: mascotHeight.clamp(60.0, 85.0),
                child: Image.asset(
                  "assets/images/mascot.png",
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}