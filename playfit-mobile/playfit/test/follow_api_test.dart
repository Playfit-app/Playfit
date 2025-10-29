import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

@GenerateMocks([http.Client, FlutterSecureStorage])
import 'follow_api_test.mocks.dart';

// Version testable de la logique API
Future<int> followUser({
  required String userId,
  required http.Client client,
  required FlutterSecureStorage storage,
}) async {
  final String url = '${dotenv.env['SERVER_BASE_URL']}/api/social/follow/';
  final String? token = await storage.read(key: 'token');

  final response = await client.post(
    Uri.parse(url),
    headers: {
      'Authorization': 'Token $token',
      'Content-Type': 'application/json',
    },
    body: json.encode({'id': userId}),
  );

  return response.statusCode;
}

void main() async {
  // Charger les variables d'environnement (.env)
  await dotenv.load(fileName: ".env");

  group('Follow API Tests', () {
    late MockClient mockClient;
    late MockFlutterSecureStorage mockStorage;

    setUp(() {
      mockClient = MockClient();
      mockStorage = MockFlutterSecureStorage();
    });

    tearDown(() {
      reset(mockClient);
      reset(mockStorage);
    });

    test('should return 201 when follow is successful', () async {
      // Stub pour le token
      when(mockStorage.read(key: anyNamed('key')))
          .thenAnswer((_) async => 'fake_token');

      // Stub pour la requête HTTP
      when(mockClient.post(
        any,
        headers: anyNamed('headers'),
        body: anyNamed('body'),
      )).thenAnswer((_) async => http.Response('', 201));

      // Appel de la fonction
      final statusCode = await followUser(
        userId: '123',
        client: mockClient,
        storage: mockStorage,
      );

      // Vérifications
      expect(statusCode, 201);

      verify(mockClient.post(
        Uri.parse('${dotenv.env['SERVER_BASE_URL']}/api/social/follow/'),
        headers: {
          'Authorization': 'Token fake_token',
          'Content-Type': 'application/json',
        },
        body: json.encode({'id': '123'}),
      )).called(1);
    });

    test('should return error code when follow fails', () async {
      when(mockStorage.read(key: anyNamed('key')))
          .thenAnswer((_) async => 'fake_token');

      when(mockClient.post(
        any,
        headers: anyNamed('headers'),
        body: anyNamed('body'),
      )).thenAnswer((_) async => http.Response('Error', 400));

      final statusCode = await followUser(
        userId: '123',
        client: mockClient,
        storage: mockStorage,
      );

      expect(statusCode, 400);
    });
  });
}
