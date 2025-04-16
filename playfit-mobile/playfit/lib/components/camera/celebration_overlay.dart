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
          width: screenWidth * 0.9,
          height: screenHeight * 0.6,
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
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              Text(
                "Stage 1 - Level 1",
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
                        child: Image.asset("assets/images/character.png"),
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
                      Icon(Icons.local_fire_department,
                          color: Colors.orange, size: screenWidth * 0.07),
                    ],
                  ),
                  SizedBox(width: screenWidth * 0.04),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("1:30",
                          style: TextStyle(fontSize: screenWidth * 0.05)),
                      SizedBox(height: screenHeight * 0.015),
                      Text("800 Cal",
                          style: TextStyle(fontSize: screenWidth * 0.05)),
                    ],
                  ),
                ],
              ),
              SizedBox(height: screenHeight * 0.015),
              // Uncomment and update if needed
              // Row(
              //   children: [
              //     Icon(Icons.directions_run, color: Colors.orange, size: screenWidth * 0.07),
              //     SizedBox(width: screenWidth * 0.03),
              //     Text("30 mètres", style: TextStyle(fontSize: screenWidth * 0.05)),
              //   ],
              // ),
              SizedBox(height: screenHeight * 0.02),
              Divider(color: Colors.orange),
              SizedBox(height: screenHeight * 0.015),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Difficulté : ",
                    style: TextStyle(
                      fontSize: screenWidth * 0.055,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    "Facile",
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
    );
  }
}
