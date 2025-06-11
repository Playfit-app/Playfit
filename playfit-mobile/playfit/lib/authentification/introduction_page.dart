import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:playfit/home_page.dart';
import 'package:playfit/i18n/strings.g.dart';

class _CustomRadialTransform extends GradientTransform {
  final double scaleX;
  final double scaleY;

  const _CustomRadialTransform(this.scaleX, this.scaleY);

  @override
  Matrix4 transform(Rect bounds, {TextDirection? textDirection}) {
    final Matrix4 matrix = Matrix4.identity();
    matrix.scale(scaleX, scaleY);
    return matrix;
  }
}

class SpeechBubbleClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    const double radius = 70.0;
    const double pointerWidth = 20.0;
    const double pointerHeight = 10.0;

    final Path path = Path();
    // Start at top-left (below pointer)
    path.moveTo(radius, pointerHeight);

    // Top-left corner
    path.quadraticBezierTo(0, pointerHeight, 0, pointerHeight + radius);

    // Left edge
    path.lineTo(0, size.height - radius);
    // Bottom-left corner
    path.quadraticBezierTo(0, size.height, radius, size.height);

    // Bottom edge
    path.lineTo(size.width - radius, size.height);
    // Bottom-right corner
    path.quadraticBezierTo(
        size.width, size.height, size.width, size.height - radius);

    // Right edge
    path.lineTo(size.width, pointerHeight + radius);
    // Top-right corner
    path.quadraticBezierTo(
        size.width, pointerHeight, size.width - radius, pointerHeight);

    // Draw triangle in center
    final double center = size.width / 2;
    path.lineTo(center + pointerWidth / 2, pointerHeight);
    path.lineTo(center, 0);
    path.lineTo(center - pointerWidth / 2, pointerHeight);

    // Close top edge
    path.lineTo(radius, pointerHeight);

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

class SpeechBubblePainter extends CustomPainter {
  final Color borderColor;
  final double strokeWidth;

  SpeechBubblePainter({required this.borderColor, this.strokeWidth = 2.0});

  @override
  void paint(Canvas canvas, Size size) {
    final Path path = SpeechBubbleClipper().getClip(size);

    final Paint paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final Paint borderPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    canvas.drawPath(path, paint);
    canvas.drawPath(path, borderPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class IntroductionPage extends StatefulWidget {
  final List<String> images;

  const IntroductionPage({
    super.key,
    required this.images,
  });

  @override
  State<IntroductionPage> createState() => _IntroductionPageState();
}

class _IntroductionPageState extends State<IntroductionPage> {
  int _imageIndex = 0;
  int _textIndex = 0;
  List<String> texts = [
    t.introduction.text_1,
    t.introduction.text_2,
    t.introduction.text_3,
    t.introduction.text_4,
    t.introduction.text_5,
    t.introduction.text_6,
    t.introduction.text_7,
    t.introduction.text_8,
    t.introduction.text_9,
  ];

  void _navigateToHome(BuildContext context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => HomePage(firstLogin: true)),
    );
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;

    return Stack(
      children: [
        // Background image
        Positioned.fill(
          child: Image.network(
            widget.images[_imageIndex],
            fit: BoxFit.cover,
          ),
        ),
        // Gradient overlay with a radial gradient and text
        Positioned(
          top: screenHeight * 0.15,
          child: Container(
            height: screenHeight * 0.2,
            width: screenWidth,
            // clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: const Alignment(-0.66, 0),
                radius: 0.5,
                colors: [
                  Colors.white,
                  const Color(0xD4EDEDED),
                  Colors.white.withAlpha(0),
                ],
                transform: _CustomRadialTransform(3, 1.0),
              ),
            ),
          ),
        ),
        if (_textIndex <= 4)
          Positioned(
            top: screenHeight * 0.23,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.1),
              child: Container(
                width: screenWidth * 0.8,
                child: Center(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _textIndex += 1;
                        if (_textIndex >= texts.length - 1) {
                          _navigateToHome(context);
                          return;
                        }
                        if (_textIndex >= 3 && _imageIndex == 0) {
                          _imageIndex = 1;
                        }
                      });
                    },
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          texts[_textIndex],
                          style: TextStyle(
                            fontSize: 17,
                            color: Colors.black,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),
                        Align(
                          alignment: Alignment.bottomRight,
                          child: Icon(
                            Icons.arrow_forward_ios_rounded,
                            size: 20,
                            color: Colors.black.withValues(alpha: 0.6),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          )
        else ...[
          Positioned.fill(
            child: BackdropFilter(
              filter: ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                color: Colors.transparent,
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(
              top: screenHeight * 0.1,
              left: screenWidth * 0.1,
              right: screenWidth * 0.1,
            ),
            child: Image.asset(
              'assets/images/mascot.png',
              height: screenHeight * 0.5,
              fit: BoxFit.cover,
            ),
          ),
          Positioned(
            bottom: screenHeight * 0.2,
            left: 0,
            right: 0,
            child: Center(
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _textIndex += 1;
                    if (_textIndex >= texts.length - 1) {
                      _navigateToHome(context);
                      return;
                    }
                    if (_textIndex >= 3 && _imageIndex == 0) {
                      _imageIndex = 1;
                    }
                  });
                },
                child: CustomPaint(
                  painter: SpeechBubblePainter(borderColor: Colors.orange),
                  child: ClipPath(
                    clipper: SpeechBubbleClipper(),
                    child: Container(
                      width: screenWidth * 0.8,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 30),
                      child: Stack(
                        children: [
                          Align(
                            alignment: Alignment.center,
                            child: Text(
                              texts[_textIndex],
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.black,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Icon(
                              Icons.arrow_forward_ios_rounded,
                              size: 20,
                              color: Colors.black.withValues(alpha: 0.6),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          )
        ]
      ],
    );
  }
}
