import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:playfit/components/experience_circle.dart';
import 'package:playfit/components/success.dart';
import 'package:playfit/components/historic_chart.dart';
import 'package:playfit/components/level_progression_dialog.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;

    void _showLevelProgressionPopup(BuildContext context) {
      showDialog(
        context: context,
        barrierDismissible: true,
        builder: (_) => const LevelProgressionDialog(),
      );
    }

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            color: Colors.black,
            onPressed: () {},
          ),
        ],
      ),
      body: Stack(
        children: <Widget>[
          Positioned(
            left: 0,
            top: 0,
            child: Container(
              height: screenHeight / 2,
              width: screenWidth,
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/mountains/mont_blanc.png'),
                  fit: BoxFit.fill,
                ),
              ),
              child: Align(
                alignment: const Alignment(0, -0.3),
                child: Container(
                  height: 100,
                  width: 100,
                  decoration: const BoxDecoration(
                    color: Color.fromARGB(255, 204, 255, 178),
                    shape: BoxShape.circle,
                  ),
                  child: Image.asset(
                    'assets/images/characterMapFlip.png',
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            left: 0,
            top: screenHeight * 0.3,
            bottom: 0,
            child: Container(
              width: screenWidth,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(50),
                  topRight: Radius.circular(50),
                ),
              ),
              child: Scrollbar(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(28.0),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Text(
                              "Prénom",
                              style: GoogleFonts.amaranth(fontSize: 36),
                            ),
                            const Padding(
                              padding: EdgeInsets.only(left: 8.0, top: 14.0),
                              child: Text(
                                "@identifiant",
                                style: TextStyle(fontSize: 14),
                              ),
                            ),
                          ],
                        ),
                        const Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "Membre depuis Septembre 2024",
                            style: TextStyle(
                              fontSize: 14,
                              color: Color.fromARGB(255, 120, 119, 111),
                            ),
                          ),
                        ),
                        const Row(
                          children: [
                            Text("1", style: TextStyle(fontSize: 14)),
                            Padding(
                              padding: EdgeInsets.only(left: 4.0),
                              child: Text(
                                "abonnés",
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Color.fromARGB(255, 120, 119, 111),
                                ),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.only(left: 8.0),
                              child: Text("5", style: TextStyle(fontSize: 14)),
                            ),
                            Padding(
                              padding: EdgeInsets.only(left: 4.0),
                              child: Text(
                                "abonnements",
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Color.fromARGB(255, 120, 119, 111),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            GestureDetector(
                              onTap: () {
                                _showLevelProgressionPopup(context);
                              },
                              child: ExperienceCircle(
                                currentXP: 70,
                                requiredXP: 100,
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Container(
                                    height: screenWidth * 0.1,
                                    width: screenWidth * 0.1,
                                    decoration: const BoxDecoration(
                                      shape: BoxShape.circle,
                                      image: DecorationImage(
                                        image: AssetImage(
                                            'assets/images/mountains/mont_blanc.png'),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            _buildDivider(),
                            _buildInfoSection(
                              const Icon(Icons.local_fire_department,
                                  color: Color(0XFFFF7A00), size: 24),
                              "5\nDay streak",
                            ),
                            _buildDivider(),
                            _buildInfoSection(
                              const Icon(Icons.flag_rounded, size: 24),
                              "2\nVilles finies",
                            ),
                          ],
                        ),
                        const SizedBox(height: 30),
                        Container(
                          height: screenHeight * 0.2,
                          decoration: const BoxDecoration(
                            color: Color(0XFFFFE9CA),
                            borderRadius: BorderRadius.all(Radius.circular(20)),
                          ),
                          child: HistoricChart(),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        height: 1.5,
                                        width: screenWidth * 0.1,
                                        decoration: const BoxDecoration(
                                          shape: BoxShape.rectangle,
                                          color: Color(0XFF7391FD),
                                        ),
                                      ),
                                      const Padding(
                                        padding: EdgeInsets.only(left: 8.0),
                                        child: Text(
                                          "Nombre d'exercices faits",
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Color(0XFF1D1B20),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  Row(
                                    children: [
                                      Container(
                                        height: 1.5,
                                        width: screenWidth * 0.1,
                                        decoration: const BoxDecoration(
                                          shape: BoxShape.rectangle,
                                          color: Color(0XFFFF0000),
                                        ),
                                      ),
                                      const Padding(
                                        padding: EdgeInsets.only(left: 8.0),
                                        child: Text(
                                          "BPM (Battements par minute)",
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Color(0XFF1D1B20),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            TextButton(
                              onPressed: () {},
                              style: ButtonStyle(
                                backgroundColor: WidgetStateProperty.all(
                                  const Color(0Xffff8871f),
                                ),
                                shape: WidgetStateProperty.all(
                                  RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                ),
                              ),
                              child: const Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 10,
                                ),
                                child: Text(
                                  "Voir plus",
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "Succès",
                            style: GoogleFonts.amaranth(fontSize: 36),
                          ),
                        ),
                        const SizedBox(height: 20),
                        const Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Success(
                              image: "assets/images/mountains/mont_blanc.png",
                              completed: true,
                              title: "Mont Blanc",
                              meters: 4806,
                            ),
                            Success(
                              image: "assets/images/mountains/kilimanjaro.png",
                              completed: false,
                              title: "Kilimanjaro",
                              meters: 5895,
                            ),
                            Success(
                              image: "assets/images/mountains/everest.png",
                              completed: false,
                              title: "Everest",
                              meters: 8849,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return const SizedBox(
      height: 50,
      child: VerticalDivider(
        color: Color(0XFFE57106),
        thickness: 1,
      ),
    );
  }

  Widget _buildInfoSection(Icon icon, String content) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        icon,
        Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: Text(
            content,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0XFF1D1B20),
              fontWeight: FontWeight.w400,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }
}
