import 'package:flutter/material.dart';
import 'package:playfit/components/statistic_bar.dart';
import 'package:playfit/styles/styles.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppStyles.grey,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              Text(
                'PROFIL',
                style: AppStyles.usernameRegular,
              ),
              const SizedBox(height: 40),
              Image.asset(
                'assets/images/character.png',
                width: 151,
                height: 297,
              ),
              Text(
                'Hugo',
                style: AppStyles.usernameRegular,
              ),
              const SizedBox(height: 40),
              const StatisticBar(),
            ],
          ),
        ),
      ),
    );
  }
}