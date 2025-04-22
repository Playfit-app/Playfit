import 'package:flutter/material.dart';

class LeftBoxWidget extends StatelessWidget {
  final Duration elapsedTime;
  final int count;
  final int targetCount;

  const LeftBoxWidget({super.key, required this.elapsedTime, required this.count, required this.targetCount});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        width: 85,
        padding: const EdgeInsets.symmetric(vertical: 40),
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
                const Icon(Icons.timer, color: Colors.orange, size: 36),
                const SizedBox(height: 8),
                Text(
                  '${elapsedTime.inMinutes}:${(elapsedTime.inSeconds % 60).toString().padLeft(2, '0')}',
                  style: const TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),
            Column(
              children: [
                const Icon(Icons.fitness_center, color: Colors.orange, size: 36),
                const SizedBox(height: 8),
                Text(
                  '$count / $targetCount',
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),
            const SizedBox(
              height: 100,
              child: Image(
                image: AssetImage("assets/images/mascot.png"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
