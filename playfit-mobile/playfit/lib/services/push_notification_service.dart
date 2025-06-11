import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print("Handling a background message: ${message.messageId}");
}

class NotificationService {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  /// Send the FCM token to the backend server.
  /// 
  /// `token` is the FCM token to be sent.
  /// 
  /// Returns a [Future] that completes when the token is sent.
  static Future<void> sendTokenToBackend(String token) async {
    final url = Uri.parse(
        "${dotenv.env['SERVER_BASE_URL']}/api/social/store-device-token/");
    final userToken = await const FlutterSecureStorage().read(key: "token");
    final response = await http.post(
      url,
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Token $userToken",
      },
      body: jsonEncode({
        "registration_id": token,
      }),
    );

    if (response.statusCode == 201) {
      print("FCM Token sent successfully!");
    } else {
      print("Failed to send FCM Token");
    }
  }

  /// Initializes Firebase Messaging and sets up notification listeners.
  /// 
  /// This method configures the Firebase Messaging service to handle incoming messages,
  /// requests notification permissions, and initializes local notifications.
  /// 
  /// Returns a [Future] that completes when the initialization is done.
  Future<void> initFirebaseMessaging() async {
    // await getToken();

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;

      if (notification != null && android != null) {
        _showNotification(notification.title!, notification.body!);
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print("A new onMessageOpenedApp event was published!");
    });

    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    // Configure local notifications
    var androidSettings =
        const AndroidInitializationSettings('@mipmap/ic_launcher');
    var initializationSettings =
        InitializationSettings(android: androidSettings);
    await _flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  /// Requests notification permissions from the user.
  /// 
  /// This method prompts the user to allow notifications,
  /// and checks the authorization status.
  /// 
  /// Returns a [Future] that completes when the permission request is done.
  Future<void> requestNotificationPermission() async {
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print("User granted notification permission.");
    } else {
      print("User denied notification permission.");
    }
  }

  /// Retrieves the FCM token and sends it to the backend.
  /// 
  /// This method fetches the FCM token from Firebase Messaging
  /// and sends it to the backend server for registration.
  /// 
  /// Returns a [Future] that completes when the token is retrieved and sent.
  Future<void> getToken() async {
    String? token = await _firebaseMessaging.getToken();

    if (token != null) {
      await sendTokenToBackend(token);
    }
  }

  /// Shows a local notification with the given title and body.
  /// 
  /// `title` is the title of the notification.
  /// `body` is the body text of the notification.
  /// 
  /// Returns a [Future] that completes when the notification is shown.
  Future<void> _showNotification(String title, String body) async {
    var androidDetails = const AndroidNotificationDetails(
      'high_importance_channel',
      'High Importance Notifications',
      importance: Importance.max,
      priority: Priority.high,
    );
    var notificationDetails = NotificationDetails(android: androidDetails);

    await _flutterLocalNotificationsPlugin.show(
        0, title, body, notificationDetails);
  }
}
