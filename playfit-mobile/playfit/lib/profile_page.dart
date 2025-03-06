import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:playfit/components/experience_circle.dart';
import 'package:playfit/components/success.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
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
              height: MediaQuery.of(context).size.height / 2,
              width: MediaQuery.of(context).size.width,
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
            top: MediaQuery.of(context).size.height * 0.3,
            bottom: 0,
            child: Container(
              width: MediaQuery.of(context).size.width,
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
                            Stack(
                              children: [
                                const ExperienceCircle(
                                  currentXP: 70,
                                  requiredXP: 100,
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(6),
                                  child: Container(
                                    height: 58,
                                    width: 58,
                                    decoration: const BoxDecoration(
                                      shape: BoxShape.circle,
                                      image: DecorationImage(
                                        image: AssetImage(
                                            'assets/images/mountains/mont_blanc.png'),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(
                              height: 50,
                              child: VerticalDivider(
                                color: Color(0XFFE57106),
                                thickness: 1,
                              ),
                            ),
                            const Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(Icons.local_fire_department,
                                    color: Color(0XFFFF7A00), size: 24),
                                Padding(
                                  padding: EdgeInsets.only(left: 8.0),
                                  child: Text(
                                    "5\nDay streak",
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Color(0XFF1D1B20),
                                      fontWeight: FontWeight.w400,
                                      height: 1.4,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(
                              height: 50,
                              child: VerticalDivider(
                                color: Color(0XFFE57106),
                                thickness: 1,
                              ),
                            ),
                            const Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(Icons.flag_rounded, size: 24),
                                Padding(
                                  padding: EdgeInsets.only(left: 8.0),
                                  child: Text(
                                    "2\nVilles finies",
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Color(0XFF1D1B20),
                                      fontWeight: FontWeight.w400,
                                      height: 1.4,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 30),
                        Container(
                          height: 165,
                          decoration: const BoxDecoration(
                            color: Color(0XFFFFE9CA),
                            borderRadius: BorderRadius.all(Radius.circular(20)),
                          ),
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
                                        width: 23,
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
                                        width: 23,
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
                            ),
                            Success(
                              image: "assets/images/mountains/kilimanjaro.png",
                              completed: false,
                            ),
                            Success(
                              image: "assets/images/mountains/everest.png",
                              completed: false,
                            ),
                          ],
                        )
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
}
