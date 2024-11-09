import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final String? baseUrl = '${dotenv.env['SERVER_BASE_URL']}api/auth/';
  final FlutterSecureStorage storage = const FlutterSecureStorage();
  final GoogleSignIn googleSignIn = GoogleSignIn(
    scopes: <String>[
      'email',
      'openid',
      'profile',
      'https://www.googleapis.com/auth/user.birthday.read',
    ],
    serverClientId: dotenv.env['GOOGLE_CLIENT_ID'],
  );

  Future<Map<String, String>> login(
      BuildContext context, String username, String password) async {
    try {
      final data = <String, String>{
        'username': username,
        'password': password,
      };
      final response = await http
          .post(
            Uri.parse('${baseUrl}login/'),
            body: data,
          )
          .timeout(const Duration(seconds: 5));

      var body = jsonDecode(response.body);
      if (response.statusCode == 200 || response.statusCode == 201) {
        String token = body['token'];
        await storage.write(key: 'token', value: token);

        if (context.mounted) {
          return {'status': 'success', 'message': 'Login successful'};
        }
      } else {
        return {'status': 'error', 'message': body["error"]};
      }
    } catch (error) {
      return {'status': 'error', 'message': error.toString()};
    }
    return {'status': 'error', 'message': 'Unexpected error'};
  }

  Future<Map<String, String>> register(
      BuildContext context,
      String email,
      String username,
      String password,
      String dateOfBirth,
      double height,
      double weight) async {
    try {
      final data = <String, dynamic>{
        'email': email,
        'username': username,
        'password': password,
        'date_of_birth': dateOfBirth,
        'height': height,
        'weight': weight,
      };
      final response = await http.post(
        Uri.parse('${baseUrl}register/'),
        body: jsonEncode(data),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 5));

      var body = jsonDecode(response.body);
      if (response.statusCode == 201) {
        String token = body['token'];
        await storage.write(key: 'token', value: token);

        if (context.mounted) {
          return {'status': 'success', 'message': 'Register successful'};
        }
      } else {
        return {'status': 'error', 'message': body};
      }
    } catch (error) {
      return {'status': 'error', 'message': error.toString()};
    }
    return {'status': 'error', 'message': 'Unexpected error'};
  }

  Future<Map<String, String>> loginWithGoogle(BuildContext context) async {
    try {
      // Sign in with Google
      GoogleSignInAccount? account = await googleSignIn.signIn();
      if (account != null) {
        GoogleSignInAuthentication googleAuth = await account.authentication;
        print(
            'Google Auth: ${googleAuth.accessToken}, ID Token: ${googleAuth.idToken}');
        final String? idToken = googleAuth.accessToken;

        if (idToken != null) {
          // Send the ID token to your backend for verification
          final response = await http.post(
            Uri.parse('${baseUrl}google-login/'),
            body: jsonEncode({'token': idToken}),
            headers: {'Content-Type': 'application/json'},
          ).timeout(const Duration(seconds: 5));

          var body = jsonDecode(response.body);
          if (response.statusCode == 200) {
            String token = body['token'];
            await storage.write(key: 'token', value: token);

            if (context.mounted) {
              return {
                'status': 'success',
                'message': 'Google login successful'
              };
            }
          } else {
            return {
              'status': 'error',
              'message': body["error"] ?? 'Google login failed'
            };
          }
        } else {
          return {'status': 'error', 'message': 'Google ID token is null'};
        }
      } else {
        return {'status': 'error', 'message': 'Google sign-in canceled'};
      }
    } catch (error) {
      return {'status': 'error', 'message': error.toString()};
    }
    return {
      'status': 'error',
      'message': 'Unexpected error during Google login'
    };
  }
}
