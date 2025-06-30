import 'package:flutter/material.dart';
import 'package:playfit/i18n/strings.g.dart';
import 'package:playfit/utils/image.dart' as image_utils;
import 'dart:ui' as ui;

class AnecdoteDisplayer extends StatelessWidget {
  final String landmarkUrl;
  final VoidCallback? onClose;

  const AnecdoteDisplayer({Key? key, required this.landmarkUrl, this.onClose}) : super(key: key);

  String getLandmarkName() {
    // Extract the landmark name from the URL
    return landmarkUrl.split('/').last.split('.').first;
  }

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
          child: SingleChildScrollView(
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
                          child: FutureBuilder<ui.Image>(
                            future: image_utils.UIImageCacheManager().loadImage(landmarkUrl),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState == ConnectionState.done && snapshot.hasData) {
                                return RawImage(image: snapshot.data);
                              } else {
                                return CircularProgressIndicator();
                              }
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: screenHeight * 0.02),
                Text(
                  t.anecdotes[getLandmarkName()]!,
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
                ElevatedButton(
                  onPressed: () {
                    if (onClose != null) {
                      print("ICIIIIIIIIIIIIIII onClose called");
                      onClose!();

                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepOrangeAccent,
                    padding: EdgeInsets.symmetric(
                      horizontal: screenWidth * 0.05,
                      vertical: screenHeight * 0.01,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(screenWidth * 0.03),
                    ),
                  ),
                  child: Text(
                    t.customization.next_button,
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
      ),
    );
  }
}