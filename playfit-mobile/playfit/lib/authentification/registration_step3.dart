import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';

class RegistrationStep3 extends StatefulWidget {
  // final TextEditingController _objectiveController;
  final Function(int) onPageChanged;

  const RegistrationStep3({
    super.key,
    required this.onPageChanged,
    // required this._objectiveController,
  });

  @override
  State<RegistrationStep3> createState() => _RegistrationStep3State();
}

class _RegistrationStep3State extends State<RegistrationStep3> {
  int _currentIndex = 0;
  final List<String> _characterImages = [
    'assets/images/character1.png',
    'assets/images/character2.png',
    'assets/images/character3.png',
    'assets/images/character4.png',
  ];

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40.0),
      child: Column(
        children: [
          const SizedBox(height: 5),
          // Consent form as dialog
          const Text(
            "Choisi ton avatar",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: screenHeight * 0.02),
          CarouselSlider(
            options: CarouselOptions(
              height: 250,
              enlargeCenterPage: true,
              enableInfiniteScroll: true,
              onPageChanged: (index, reason) {
                setState(() {
                  _currentIndex = index;
                });
                widget.onPageChanged(index);
              },
            ),
            items: _characterImages.map((imagePath) {
              return ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.asset(
                  imagePath,
                  fit: BoxFit.contain,
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
