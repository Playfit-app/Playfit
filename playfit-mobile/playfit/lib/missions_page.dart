import 'package:flutter/material.dart';

class MissionsPage extends StatefulWidget {
  const MissionsPage({super.key});

  @override
  State<MissionsPage> createState() => _MissionsPage();
}

class _MissionsPage extends State<MissionsPage> {

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Missions page',
              style: TextStyle(fontSize: 24),
            ),
            SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
