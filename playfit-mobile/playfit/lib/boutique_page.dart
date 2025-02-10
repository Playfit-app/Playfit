import 'package:flutter/material.dart';

class BoutiquePage extends StatefulWidget {
  const BoutiquePage({super.key});

  @override
  State<BoutiquePage> createState() => _BoutiquePage();
}

class _BoutiquePage extends State<BoutiquePage> {

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Boutique page',
              style: TextStyle(fontSize: 24),
            ),
            SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
