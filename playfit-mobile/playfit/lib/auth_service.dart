import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AuthService {
  final String? baseUrl = '${dotenv.env['SERVER_BASE_URL']}api/auth/';
  final FlutterSecureStorage storage = const FlutterSecureStorage();

  Future<void> login(
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

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        String token = data['token'];
        await storage.write(key: 'token', value: token);

        if (context.mounted) {
          Navigator.pushReplacementNamed(context, '/home');
        }
      } else {
        // Show error message
      }
    } catch (error) {
      // Show error message
    }
  }

  Future<void> register(
      BuildContext context,
      String email,
      String username,
      String password,
      String firstName,
      String lastName,
      String dateOfBirth,
      String height,
      String weight) async {
    try {
      final data = <String, String>{
        'email': email,
        'username': username,
        'password': password,
        'first_name': firstName,
        'last_name': lastName,
        'date_of_birth': dateOfBirth,
        'height': height,
        'weight': weight,
      };
      final response = await http
          .post(
            Uri.parse('${baseUrl}register/'),
            body: data,
          )
          .timeout(const Duration(seconds: 5));

      if (response.statusCode == 201) {
        if (context.mounted) {
          Navigator.pushReplacementNamed(context, '/login');
        }
      } else {
        // Show error message
      }
    } catch (error) {
      // Show error message
    }
  }
}
