import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:web_socket_channel/io.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class NotificationProvider extends ChangeNotifier {
  IOWebSocketChannel? _channel;
  final List<Map<String, dynamic>> _notifications = [];
  int _unreadCount = 0;

  List<Map<String, dynamic>> get notifications => _notifications;
  int get unreadCount => _unreadCount;

  /// Connects to the WebSocket server for notifications.
  /// This method initializes the WebSocket connection
  /// and listens for incoming messages.
  /// 
  /// `token` is the authentication token used for the WebSocket connection.
  void connect(String token) {
    if (_channel != null) return;

    final url = "${dotenv.env['SERVER_BASE_WS_URL']}/ws/notifications/";

    _channel = IOWebSocketChannel.connect(
      Uri.parse(url),
      headers: {
        'Authorization': 'Token $token',
      },
    );

    _channel!.stream.listen((message) {
      final data = jsonDecode(message)['data'];
      _notifications.insert(0, data);
      _unreadCount++;
      notifyListeners();
    }, onDone: () {
      _channel!.sink.close();
      _channel = null;
    }, onError: (error) {
      debugPrint('WebSocket error: $error');
      _channel!.sink.close();
      _channel = null;
    });
  }

  /// Disconnects from the WebSocket server.
  /// This method closes the WebSocket connection
  /// and sets the channel to null.
  void disconnect() {
    _channel?.sink.close();
    _channel = null;
  }

  /// Marks a specific notification as read.
  /// 
  /// `notificationId` is the ID of the notification to be marked as read.
  void markAllAsRead() async {
    _unreadCount = 0;
    final url =
        "${dotenv.env['SERVER_BASE_URL']}/api/social/notifications/read/all/";
    final token = await const FlutterSecureStorage().read(key: 'token');
    await http.patch(
      Uri.parse(url),
      headers: {
        'Authorization': 'Token $token',
      },
    );
    notifyListeners();
  }
}
