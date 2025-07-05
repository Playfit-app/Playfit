import 'package:flutter/material.dart';
import 'package:playfit/i18n/strings.g.dart';

class MissionsPage extends StatefulWidget {
  const MissionsPage({super.key});

  @override
  State<MissionsPage> createState() => _MissionsPage();
}

class _MissionsPage extends State<MissionsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              t.mission.title,
              style: TextStyle(fontSize: 24),
            ),
            SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
