import 'package:flutter/material.dart';

class AnecdoteDisplayer extends StatelessWidget {
  final String anecdote;
  final String anecdoteMonument;

  const AnecdoteDisplayer({Key? key, required this.anecdote, required this.anecdoteMonument}) : super(key: key);

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
                        child: Image.asset("assets/images/monument_${anecdoteMonument}.png"), // Have to get the monument name or number to update the path following the user's level
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: screenHeight * 0.02),
              Text(
                anecdote,
                style: TextStyle(
                  fontSize: screenWidth * 0.05,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: screenHeight * 0.02),
              Divider(
                color: Colors.deepOrangeAccent,
                thickness: screenWidth * 0.005,
              ),
              SizedBox(height: screenHeight * 0.02),
              // Add a next button
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close the displayer
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepOrangeAccent,
                  padding: EdgeInsets.symmetric(
                    horizontal: screenWidth * 0.1,
                    vertical: screenHeight * 0.02,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(screenWidth * 0.03),
                  ),
                ),
                child: Text(
                  "Next",
                  style: TextStyle(
                    fontSize: screenWidth * 0.05,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}