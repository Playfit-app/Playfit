// test/fetch_images_api_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';


// Générez les mocks avec : dart run build_runner build --delete-conflicting-outputs
@GenerateMocks([http.Client])
import 'fetch_images_api_test.mocks.dart';

// Mock du storage
class MockStorage {
  Future<String?> read({required String key}) async => 'fake_token';
}
// Copie exacte de la fonction pour les tests
Future<Map<String, dynamic>> fetchImages({required http.Client client, required MockStorage storage}) async {
  final String url = '${dotenv.env['SERVER_BASE_URL']}/api/social/get-character-images/';
  final String? token = await storage.read(key: 'token');

  final response = await client.get(
    Uri.parse(url),
    headers: {
      'Authorization': 'Token $token',
    },
  );

  if (response.statusCode == 200) {
    return json.decode(response.body);
  } else {
    throw Exception('Failed to load images: ${response.statusCode}');
  }
}

void main() async {
  await dotenv.load(fileName: ".env");

  group('fetchImages API Tests', () {
    late MockClient mockClient;
    late MockStorage mockStorage;

    setUp(() {
      mockClient = MockClient();
      mockStorage = MockStorage();
    });

    test('should return images on success', () async {
      final mockData = {
        'characters': ['char1.png', 'char2.png'],
        'count': 2,
      };

      when(mockClient.get(any, headers: anyNamed('headers')))
          .thenAnswer((_) async => http.Response(jsonEncode(mockData), 200));

      final result = await fetchImages(client: mockClient, storage: mockStorage);

      expect(result, isA<Map<String, dynamic>>());
      expect(result['characters'], ['char1.png', 'char2.png']);
      expect(result['count'], 2);

      verify(mockClient.get(
        Uri.parse('${dotenv.env['SERVER_BASE_URL']}/api/social/get-character-images/'),
        headers: {'Authorization': 'Token fake_token'},
      )).called(1);
    });

    test('should throw exception when API fails', () async {
      when(mockClient.get(any, headers: anyNamed('headers')))
          .thenAnswer((_) async => http.Response('Error', 500));

      expect(
        () async => await fetchImages(client: mockClient, storage: mockStorage),
        throwsException,
      );
    });
  });
}
