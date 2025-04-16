import 'package:flutter/material.dart';

class CelebrationOverlay extends StatelessWidget {
  const CelebrationOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    final double screenWidth = MediaQuery.of(context).size.width;

    return Container(
      color: Colors.black.withAlpha(153), // semi-transparent background
      child: Center(
        child: Container(
          width: 360,
          height: screenHeight * 0.7,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.deepOrangeAccent,
              width: 4,
            ),
            boxShadow: const [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 12,
                offset: Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Stage 1 - Level 1",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                height: 200,
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8E8E8), // <-- Added background color
                  border: Border.all(color: Colors.orange.shade200),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Stack(
                  children: [
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        child: Image.asset("assets/images/character.png"),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  const Icon(Icons.timer, color: Colors.orange, size: 28),
                  const SizedBox(width: 10),
                  const Text("1:30", style: TextStyle(fontSize: 20)),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  const Icon(Icons.local_fire_department,
                      color: Colors.orange, size: 28),
                  const SizedBox(width: 10),
                  const Text("800 Cal", style: TextStyle(fontSize: 20)),
                ],
              ),
              const SizedBox(height: 10),
              // Row(
              //   children: [
              //     const Icon(Icons.directions_run, color: Colors.orange, size: 28),
              //     const SizedBox(width: 10),
              //     const Text("30 mètres", style: TextStyle(fontSize: 20)),
              //   ],
              // ),
              const SizedBox(height: 16),
              const Divider(color: Colors.orange),
              const SizedBox(height: 10),
              const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Difficulté : ",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    "Facile",
                    style: TextStyle(
                      fontSize: 22,
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
    );
  }
}
