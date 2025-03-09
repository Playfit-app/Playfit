import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';

class RegistrationStep3 extends StatefulWidget {

  // final TextEditingController _objectiveController;

  const RegistrationStep3({
    super.key,

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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40.0),
      child: Column(
        children: [
          const SizedBox(height: 10),
          // Consent form as dialog
          const Text(
          "Choisi ton avatar",
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 20),
        CarouselSlider(
          options: CarouselOptions(
            height: 250,
            enlargeCenterPage: true,
            enableInfiniteScroll: true,
            onPageChanged: (index, reason) {
              setState(() {
                _currentIndex = index;
              });
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
