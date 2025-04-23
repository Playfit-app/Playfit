import 'package:flutter/material.dart';

class BottomBoxWidget extends StatelessWidget {
  final Duration elapsedTime;
  final int count;
  final int targetCount;

  const BottomBoxWidget({super.key, required this.elapsedTime, required this.count, required this.targetCount});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        height: 100,
        padding: const EdgeInsets.symmetric(horizontal: 50),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Icon(Icons.timer, color: Colors.orange, size: 30),
                const SizedBox(width: 5),
                Text(
                  '${elapsedTime.inMinutes}:${(elapsedTime.inSeconds % 60).toString().padLeft(2, '0')}',
                  style: const TextStyle(
                    fontSize: 34,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            Row(
              children: [
                const Icon(Icons.fitness_center, color: Colors.orange, size: 30),
                const SizedBox(width: 5),
                Text(
                  '$count / $targetCount',
                  style: TextStyle(
                    fontSize: 34,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 80,
              child: Image.asset("assets/images/mascot.png"),
            ),
          ],
        ),
      ),
    );
  }
}
