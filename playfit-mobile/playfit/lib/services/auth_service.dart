import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';
import 'package:playfit/providers/notification_provider.dart';

/// This class provides methods for user authentication, including login functionality,
/// and manages secure storage of authentication tokens. It also integrates with Google Sign-In
/// and notifies the application of authentication state changes.
class AuthService {
  final String? baseUrl = '${dotenv.env['SERVER_BASE_URL']}/api/auth/';
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

  /// Logs in a user with [username] and [password], stores the token, and connects notifications.
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
        await storage.write(
            key: 'userId', value: body['user']['id'].toString());

        if (context.mounted) {
          Provider.of<NotificationProvider>(context, listen: false)
              .connect(token);
          return {'status': 'success', 'message': 'Login successful'};
        }
      } else {
        return {'status': 'error', 'message': body.toString()};
      }
    } catch (error) {
      return {'status': 'error', 'message': error.toString()};
    }
    return {'status': 'error', 'message': 'Unexpected error'};
  }

  /// Registers a new user with the provided details.
  /// Validates input, sends a POST request, and stores the token on success.
  /// Returns a map with 'status' and 'message'.
  Future<Map<String, String>> register(
    BuildContext context,
    String email,
    String username,
    String password,
    String dateOfBirth,
    double height,
    double weight,
    bool isConsentGiven,
    bool isMarketingConsentGiven,
    String? characterImage,
  ) async {
    try {
      if (characterImage == null || characterImage.isEmpty) {
        return {'status': 'error', 'message': 'A valid character image is required'};
      }
      /// Validates the user registration input fields.
      ///
      /// Checks if any of the required fields are empty or equal to zero, or if
      /// user consent has not been provided.
      ///
      /// Returns an error map with a status and message if any validation fails.
      if (email.isEmpty ||
          username.isEmpty ||
          password.isEmpty ||
          dateOfBirth.isEmpty ||
          height <= 0 ||
          weight <= 0 ||
          !isConsentGiven) {
        return {'status': 'error', 'message': 'All fields are required'};
      }
      final data = <String, dynamic>{
        'email': email,
        'username': username,
        'password': password,
        'date_of_birth': dateOfBirth,
        'height': height,
        'weight': weight,
        'terms_and_conditions': isConsentGiven,
        'privacy_policy': isConsentGiven,
        'marketing': isMarketingConsentGiven,
        'character_image': characterImage,
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
        await storage.write(
            key: 'userId', value: body['user']['id'].toString());

        if (context.mounted) {
          Provider.of<NotificationProvider>(context, listen: false)
              .connect(token);
          return {'status': 'success', 'message': 'Register successful'};
        }
      } else {
        return {'status': 'error', 'message': body.toString()};
      }
    } catch (error) {
      return {'status': 'error', 'message': error.toString()};
    }
    return {'status': 'error', 'message': 'Unexpected error'};
  }

  /// Signs in the user with Google and authenticates with the backend.
  /// Stores token and user ID on success, or returns an error message.
  Future<Map<String, String>> loginWithGoogle(BuildContext context) async {
    try {
      // Sign in with Google
      GoogleSignInAccount? account = await googleSignIn.signIn();
      if (account != null) {
        GoogleSignInAuthentication googleAuth = await account.authentication;
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
            await storage.write(
                key: 'userId', value: body['user']['id'].toString());

            if (context.mounted) {
              Provider.of<NotificationProvider>(context, listen: false)
                  .connect(token);
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
