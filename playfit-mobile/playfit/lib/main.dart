import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:playfit/i18n/strings.g.dart';
import 'package:provider/provider.dart';
import 'package:playfit/firebase_options.dart';
import 'package:playfit/providers/notification_provider.dart';
import 'package:playfit/providers/language_provider.dart';
import 'package:playfit/services/push_notification_service.dart';
import 'package:playfit/authentification/login_page.dart';
import 'package:playfit/authentification/auth_gate.dart';
import 'package:playfit/authentification/registration_page.dart';
import 'package:playfit/home_page.dart';
import 'package:playfit/profile_page.dart';
import 'package:playfit/notification_page.dart';
import 'package:playfit/route_observer.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  NotificationService().initFirebaseMessaging();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  // Initialize translations
  LocaleSettings.useDeviceLocale();

  runApp(
    // DevicesPreview is only enabled in debug mode
    // It allows you to preview your app on different devices and screen sizes
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => NotificationProvider()),
        ChangeNotifierProvider(create: (context) => LanguageProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<LanguageProvider>(
      builder: (context, languageProvider, child) {
        return TranslationProvider(
          child: MaterialApp(
            title: 'Playfit',
            locale: languageProvider.currentLocale.flutterLocale,
            supportedLocales: AppLocaleUtils.supportedLocales,
            localizationsDelegates: GlobalMaterialLocalizations.delegates,
            navigatorObservers: [routeObserver],
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
              useMaterial3: true,
            ),
            home: const AuthGate(),
            routes: {
              '/register': (context) =>
                  const CreateAccountPage(), // Route to registration page
              '/login': (context) => const LoginPage(), // Route to login page
              '/home': (context) => HomePage(), // Route to home page
              '/profile': (context) => const ProfilePage(), // Route to profile page
              '/notifications': (context) => const NotificationPage(),
            },
          ),
        );
      },
    );
  }
}
