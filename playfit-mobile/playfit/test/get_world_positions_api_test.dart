import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';

// 1️⃣ Place l'annotation @GenerateMocks ici, AVANT toute déclaration
@GenerateMocks([http.Client])
import 'get_world_positions_api_test.mocks.dart';

// 2️⃣ Ensuite, toutes les autres classes/fonctions
class MockStorage {
  Future<String?> read({required String key}) async => 'fake_token';
}

// Fonction à tester (copie exacte pour le test)
Future<List<dynamic>> getWorldPositions({
  required http.Client client,
  required MockStorage storage,
}) async {
  final String baseUrl = '${dotenv.env['SERVER_BASE_URL']}/api/social';
  final String? token = await storage.read(key: 'token');

  final response = await client.get(
    Uri.parse('$baseUrl/get-world-positions/'),
    headers: {
      'Authorization': 'Token $token',
    },
  );

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);

    for (var i = 0; i < data.length; i++) {
      var d = data[i];

      if (d['status'] == 'in_city') {
        final int level = d['level'] - 1;
        final int offsetTransition = (d['city'] - 1) * 4;
        final int offsetCity = (d['city'] - 1) * 6;
        d['current_checkpoint'] = level + offsetTransition + offsetCity;
      } else {
        final int level = d['level'] - 1;
        final int offsetTransition = (d['city_from'] - 1) * 4;
        final int offsetCity = d['city_from'] * 6;
        d['current_checkpoint'] = level + offsetTransition + offsetCity;
      }
    }

    return data;
  } else {
    throw Exception('Failed to load world positions');
  }
}

void main() async {
  await dotenv.load(fileName: ".env");

  group('getWorldPositions API Tests', () {
    late MockClient mockClient;
    late MockStorage mockStorage;

    setUp(() {
      mockClient = MockClient();
      mockStorage = MockStorage();
    });

    test('should return data with correct current_checkpoint for in_city', () async {
      final responseData = [
        {'status': 'in_city', 'level': 2, 'city': 2},
      ];

      when(mockClient.get(
        any,
        headers: anyNamed('headers'),
      )).thenAnswer(
        (_) async => http.Response(jsonEncode(responseData), 200),
      );

      final result = await getWorldPositions(client: mockClient, storage: mockStorage);

      expect(result, isA<List<dynamic>>());
      expect(result[0]['current_checkpoint'], 1 + (2 - 1) * 4 + (2 - 1) * 6); // level + offsetTransition + offsetCity
    });

    test('should return data with correct current_checkpoint for not in_city', () async {
      final responseData = [
        {'status': 'transition', 'level': 3, 'city_from': 1},
      ];

      when(mockClient.get(
        any,
        headers: anyNamed('headers'),
      )).thenAnswer(
        (_) async => http.Response(jsonEncode(responseData), 200),
      );

      final result = await getWorldPositions(client: mockClient, storage: mockStorage);

      expect(result[0]['current_checkpoint'], (3 - 1) + (1 - 1) * 4 + 1 * 6); // level + offsetTransition + offsetCity
    });

    test('should throw exception when API fails', () async {
      when(mockClient.get(any, headers: anyNamed('headers')))
          .thenAnswer((_) async => http.Response('Error', 500));

      expect(
        () async => await getWorldPositions(client: mockClient, storage: mockStorage),
        throwsException,
      );
    });
  });
}
