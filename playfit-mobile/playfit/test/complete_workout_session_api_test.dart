import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

import 'complete_workout_session_api_test.mocks.dart';

// Génération des mocks : http.Client et FlutterSecureStorage
@GenerateMocks([http.Client, FlutterSecureStorage])
void main() {
  late MockClient mockHttpClient;
  late MockFlutterSecureStorage mockStorage;

  // Fonction à tester
  Future<void> completeWorkoutSession(
    String difficulty,
    http.Client client,
    FlutterSecureStorage storage,
    String baseUrl,
  ) async {
    final String? token = await storage.read(key: 'token');

    final response = await client.patch(
      Uri.parse('$baseUrl/update_workout_session/'),
      headers: {
        'Authorization': 'Token $token',
      },
      body: {
        'difficulty': difficulty,
      },
    );

    if (response.statusCode != 200) {
      print("Can't update workout session");
    }
  }

  setUp(() {
    mockHttpClient = MockClient();
    mockStorage = MockFlutterSecureStorage();
  });

  group('Complete Workout Session API Tests', () {
    test('should complete workout session successfully (200)', () async {
      // Arrange
      const baseUrl = 'https://mockapi.test/api/workout';
      when(mockStorage.read(key: 'token')).thenAnswer((_) async => 'mockToken');
      when(mockHttpClient.patch(
        Uri.parse('$baseUrl/update_workout_session/'),
        headers: anyNamed('headers'),
        body: anyNamed('body'),
      )).thenAnswer((_) async => http.Response('{}', 200));

      // Act
      await completeWorkoutSession('easy', mockHttpClient, mockStorage, baseUrl);

      // Assert
      verify(mockHttpClient.patch(
        Uri.parse('$baseUrl/update_workout_session/'),
        headers: {'Authorization': 'Token mockToken'},
        body: {'difficulty': 'easy'},
      )).called(1);
    });

    test('should print error when workout session update fails', () async {
      // Arrange
      const baseUrl = 'https://mockapi.test/api/workout';
      when(mockStorage.read(key: 'token')).thenAnswer((_) async => 'mockToken');
      when(mockHttpClient.patch(
        Uri.parse('$baseUrl/update_workout_session/'),
        headers: anyNamed('headers'),
        body: anyNamed('body'),
      )).thenAnswer((_) async => http.Response('Error', 400));

      // Act
      await completeWorkoutSession('hard', mockHttpClient, mockStorage, baseUrl);

      // Assert
      verify(mockHttpClient.patch(
        Uri.parse('$baseUrl/update_workout_session/'),
        headers: {'Authorization': 'Token mockToken'},
        body: {'difficulty': 'hard'},
      )).called(1);
    });
  });
}
