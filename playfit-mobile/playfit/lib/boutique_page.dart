import 'package:flutter/material.dart';
import 'package:playfit/i18n/strings.g.dart';

class BoutiquePage extends StatefulWidget {
  const BoutiquePage({super.key});

  @override
  State<BoutiquePage> createState() => _BoutiquePage();
}

class _BoutiquePage extends State<BoutiquePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              t.shop.title,
              style: TextStyle(fontSize: 24),
            ),
            SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
