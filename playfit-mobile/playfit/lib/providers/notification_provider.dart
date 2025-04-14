import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:web_socket_channel/io.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class NotificationProvider extends ChangeNotifier {
  IOWebSocketChannel? _channel;
  final List<Map<String, dynamic>> _notifications = [];
  int _unreadCount = 0;

  List<Map<String, dynamic>> get notifications => _notifications;
  int get unreadCount => _unreadCount;

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
      debugPrint('Received notification: $data');
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

  void disconnect() {
    _channel?.sink.close();
    _channel = null;
  }
}
