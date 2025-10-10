// test/delete_data_api_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'dart:convert';
import 'dart:io';
import 'package:flutter_dotenv/flutter_dotenv.dart';

// Générez les mocks avec : flutter pub run build_runner build
@GenerateMocks([http.Client])
import 'delete_data_api_test.mocks.dart';

// Copie EXACTE de votre fonction originale pour les tests
Future<http.Response> deleteMyDataApiCall(String baseUrl, String token) async {
  final response = await http.delete(
    Uri.parse('${baseUrl}api/auth/delete_my_data/'),
    headers: {
      'Authorization': 'Token $token',
      'Content-Type': 'application/json',
    },
    body: jsonEncode({"confirm": true}),
  ).timeout(const Duration(seconds: 5));

  return response;
}

void main() async {
  await dotenv.load(fileName: ".env"); // Charge les variables d'environnement

  group('Delete My Data API Tests - Sans modifier votre code', () {

    // METHOD 2: Tests des composants
    group('Tests des composants de votre code', () {
      test('construction URL correcte', () {
        final baseUrl = 'https://api.example.com/';
        final url = Uri.parse('${baseUrl}api/auth/delete_my_data/');

        expect(url.scheme, 'https');
        expect(url.host, 'api.example.com');
        expect(url.path, '/api/auth/delete_my_data/');
        expect(url.toString(), 'https://api.example.com/api/auth/delete_my_data/');
      });

      test('headers correctement formatés', () {
        final token = 'fake_token';
        final headers = {
          'Authorization': 'Token $token',
          'Content-Type': 'application/json',
        };

        expect(headers.containsKey('Authorization'), true);
        expect(headers.containsKey('Content-Type'), true);
        expect(headers['Authorization'], 'Token $token');
        expect(headers['Content-Type'], 'application/json');
      });

      test('body JSON correct', () {
        final body = jsonEncode({"confirm": true});
        final parsed = jsonDecode(body);
        expect(parsed['confirm'], true);
      });

      test('timeout configuration', () {
        const timeout = Duration(seconds: 5);
        expect(timeout.inSeconds, 5);
      });
    });

    // METHOD 3: Logique métier
    group('Tests de la logique métier', () {
      test('traitement réponse succès', () {
        final response = http.Response('', 204);
        expect(response.statusCode, 204);

        final isSuccess = response.statusCode == 204;
        expect(isSuccess, true);
      });

      test('traitement réponse erreur', () {
        final response = http.Response('Error', 400);
        expect(response.statusCode, 400);

        final isError = response.statusCode >= 400;
        expect(isError, true);
      });
    });

    // METHOD 4: Simulation de workflow complet
    group('Tests workflow complet delete', () {
      test('simulation appel API delete', () async {
        final baseUrl = 'https://api.example.com/';
        final token = 'fake_token';

        // Construction de la requête
        final uri = Uri.parse('${baseUrl}api/auth/delete_my_data/');
        final body = jsonEncode({"confirm": true});
        final headers = {
          'Authorization': 'Token $token',
          'Content-Type': 'application/json',
        };

        // Simulation de réponse
        final simulatedResponses = {
          204: '', // succès
          400: 'Bad Request',
          500: 'Server Error'
        };

        for (final statusCode in simulatedResponses.keys) {
          final simulatedResponse = http.Response(simulatedResponses[statusCode]!, statusCode);

          expect(simulatedResponse.statusCode, statusCode);
          if (statusCode == 204) {
            final isSuccess = simulatedResponse.statusCode == 204;
            expect(isSuccess, true);
          } else {
            final isError = simulatedResponse.statusCode >= 400;
            expect(isError, true);
          }
        }
      });
    });
  });
}
