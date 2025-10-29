// 1️⃣ Tous les imports avant tout code
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';

// 2️⃣ Annotation GenerateMocks avant toute classe/fonction
@GenerateMocks([http.Client])
import 'get_decoration_images_api_test.mocks.dart';

// 3️⃣ Ensuite, toutes tes classes/fonctions
class MockStorage {
  Future<String?> read({required String key}) async => 'fake_token';
}

// Fonction à tester (copie exacte)
Future<Map<String, dynamic>> getDecorationImages({
  required String country,
  required http.Client client,
  required MockStorage storage,
}) async {
  final String url =
      '${dotenv.env['SERVER_BASE_URL']}/api/social/get-decoration-images/$country/';
  final String? token = await storage.read(key: 'token');

  final response = await client.get(
    Uri.parse(url),
    headers: {
      'Authorization': 'Token $token',
    },
  );

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    return data;
  } else {
    throw Exception('Failed to load decoration images');
  }
}

// 4️⃣ Tests
void main() async {
  await dotenv.load(fileName: ".env");

  group('getDecorationImages API Tests', () {
    late MockClient mockClient;
    late MockStorage mockStorage;

    setUp(() {
      mockClient = MockClient();
      mockStorage = MockStorage();
    });

    test('should return decoration images on success', () async {
      final country = 'france';
      final mockData = {
        'images': ['image1.png', 'image2.png'],
        'count': 2,
      };

      when(mockClient.get(any, headers: anyNamed('headers')))
          .thenAnswer((_) async => http.Response(jsonEncode(mockData), 200));

      final result = await getDecorationImages(
        country: country,
        client: mockClient,
        storage: mockStorage,
      );

      expect(result['images'], ['image1.png', 'image2.png']);
      expect(result['count'], 2);
    });

    test('should throw exception when API fails', () async {
      final country = 'france';

      when(mockClient.get(any, headers: anyNamed('headers')))
          .thenAnswer((_) async => http.Response('Error', 500));

      expect(
        () async => await getDecorationImages(
          country: country,
          client: mockClient,
          storage: mockStorage,
        ),
        throwsException,
      );
    });
  });
}
