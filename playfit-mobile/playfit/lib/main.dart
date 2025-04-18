import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:playfit/firebase_options.dart';
import 'package:playfit/providers/notification_provider.dart';
import 'package:playfit/services/push_notification_service.dart';
import 'package:playfit/authentification/login_page.dart';
import 'package:playfit/authentification/registration_page.dart';
import 'package:playfit/home_page.dart';
import 'package:playfit/profile_page.dart';
import 'package:playfit/camera_page.dart';
import 'package:playfit/notification_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  NotificationService().initFirebaseMessaging();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => NotificationProvider()),
      ],
      child: const MyApp(),
    ),
  );
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
      routes: {
        '/register': (context) =>
            const CreateAccountPage(), // Route to registration page
        '/login': (context) => const LoginPage(), // Route to login page
        '/home': (context) => const HomePage(), // Route to home page
        '/profile': (context) => const ProfilePage(), // Route to profile page
        '/notifications': (context) => const NotificationPage(),
      },
    );
  }
}
