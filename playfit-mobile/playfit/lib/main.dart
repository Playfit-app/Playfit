import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:playfit/authentification/login_page.dart';
import 'package:playfit/authentification/registration_page.dart';
import 'package:playfit/home_page.dart';
import 'package:playfit/profile_page.dart';
import 'package:playfit/reset_password_page.dart';

void main() async {
  await dotenv.load(fileName: ".env");

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const LoginPage(),
      initialRoute: '/login',
      routes: {
        '/register': (context) => const CreateAccountPage(),
        '/login': (context) => const LoginPage(),
        '/home': (context) => const HomePage(),
        '/profile': (context) => const ProfilePage(),
        '/reset-password-request': (context) => ResetPasswordRequestPage(),
      },
    );
  }
}
