import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart';
import 'package:playfit/authentification/login_page.dart';
import 'package:playfit/home_page.dart';
import 'package:playfit/providers/notification_provider.dart';

/// Resolves the appropriate initial screen based on the persisted
/// stay-connected preference and existing authentication token.
class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  late Future<String?> _tokenFuture;

  @override
  void initState() {
    super.initState();
    _tokenFuture = _resolveToken();
  }

  Future<String?> _resolveToken() async {
    final stayConnected = await _storage.read(key: 'stayConnected');
    if (stayConnected == 'true') {
      final token = await _storage.read(key: 'token');
      if (token != null && token.isNotEmpty) {
        return token;
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
      future: _tokenFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final token = snapshot.data;
        if (token != null) {
          Provider.of<NotificationProvider>(context, listen: false)
              .connect(token);
          return HomePage();
        }

        return const LoginPage();
      },
    );
  }
}
