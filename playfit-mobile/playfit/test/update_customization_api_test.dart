// test/update_customization_api_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';


// Générez les mocks avec : dart run build_runner build --delete-conflicting-outputs
@GenerateMocks([http.Client])
import 'update_customization_api_test.mocks.dart';

// Mock du storage
class MockStorage {
  Future<String?> read({required String key}) async => 'fake_token';
}
// Copie exacte de la fonction pour les tests
Future<void> updateCustomization({
  required String image,
  required http.Client client,
  required MockStorage storage,
}) async {
  final String url =
      '${dotenv.env['SERVER_BASE_URL']}/api/social/update-customization/';
  final String? token = await storage.read(key: 'token');

  final response = await client.patch(
    Uri.parse(url),
    headers: {
      'Authorization': 'Token $token',
      'Content-Type': 'application/json',
    },
    body: json.encode({'base_character': image}),
  );

  if (response.statusCode != 200) {
    throw Exception('Failed to update customization: ${response.statusCode}');
  }
}

void main() async {
  await dotenv.load(fileName: ".env");

  group('updateCustomization API Tests', () {
    late MockClient mockClient;
    late MockStorage mockStorage;

    setUp(() {
      mockClient = MockClient();
      mockStorage = MockStorage();
    });

    test('should call PATCH with correct URL, headers and body', () async {
      final image = 'char1.png';

      when(mockClient.patch(any,
              headers: anyNamed('headers'), body: anyNamed('body')))
          .thenAnswer((_) async => http.Response('', 200));

      await updateCustomization(image: image, client: mockClient, storage: mockStorage);

      verify(mockClient.patch(
        Uri.parse('${dotenv.env['SERVER_BASE_URL']}/api/social/update-customization/'),
        headers: {
          'Authorization': 'Token fake_token',
          'Content-Type': 'application/json',
        },
        body: json.encode({'base_character': image}),
      )).called(1);
    });

    test('should throw exception when API fails', () async {
      final image = 'char1.png';

      when(mockClient.patch(any,
              headers: anyNamed('headers'), body: anyNamed('body')))
          .thenAnswer((_) async => http.Response('Error', 500));

      expect(
        () async => await updateCustomization(image: image, client: mockClient, storage: mockStorage),
        throwsException,
      );
    });
  });
}
