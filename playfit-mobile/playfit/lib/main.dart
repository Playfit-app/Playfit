import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:device_preview/device_preview.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:playfit/i18n/strings.g.dart';
import 'package:provider/provider.dart';
import 'package:playfit/firebase_options.dart';
import 'package:playfit/providers/notification_provider.dart';
import 'package:playfit/services/push_notification_service.dart';
import 'package:playfit/services/language_service.dart';
import 'package:playfit/authentification/login_page.dart';
import 'package:playfit/authentification/registration_page.dart';
import 'package:playfit/home_page.dart';
import 'package:playfit/profile_page.dart';
import 'package:playfit/camera_page.dart';
import 'package:playfit/notification_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  NotificationService().initFirebaseMessaging();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  // Load the selected language in local storage and use it to set app language. Default to english if not set.
  var locale = await LanguageService.loadLocale();

  if (locale != null) {
    await LocaleSettings.setLocale(locale);
  } else {
    locale = await LocaleSettings.useDeviceLocale();
    await LanguageService.saveLocale(locale);
  }

  runApp(
    // DevicesPreview is only enabled in debug mode
    // It allows you to preview your app on different devices and screen sizes
    DevicePreview(
      enabled: !bool.fromEnvironment('dart.vm.product'),
      builder: (context) => MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (context) => NotificationProvider()),
        ],
        child: TranslationProvider(child: const MyApp()),
      ),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      useInheritedMediaQuery: true,
      builder: DevicePreview.appBuilder,
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
        '/home': (context) => HomePage(), // Route to home page
        '/profile': (context) => const ProfilePage(), // Route to profile page
        '/notifications': (context) => const NotificationPage(),
      },
      // Use the locale from DevicePreview in debug mode,
      // otherwise use the locale from the TranslationProvider
      locale: DevicePreview.locale(context) ?? TranslationProvider.of(context).flutterLocale,
      supportedLocales: AppLocaleUtils.instance.supportedLocales,
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
    );
  }
}
