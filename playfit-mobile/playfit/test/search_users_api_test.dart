import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

import 'search_users_api_test.mocks.dart';

@GenerateMocks([http.Client, FlutterSecureStorage])
void main() {
  late MockClient mockHttpClient;
  late MockFlutterSecureStorage mockStorage;
  late List<Map<String, dynamic>> results;
  String? nextPageUrl;
  bool loading = false;

  // Fonction testable séparée pour faciliter les tests
  Future<void> searchUsersFunction(
    String query, {
    required http.Client client,
    required FlutterSecureStorage storage,
  }) async {
    loading = true;
    final token = await storage.read(key: 'token');
    final url = Uri.parse("https://mockapi.test/api/social/search-users/?search=$query");

    final response = await client.get(
      url,
      headers: {
        "Authorization": "Token $token",
        "Content-Type": "application/json",
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      results = List<Map<String, dynamic>>.from(data['results']);
      nextPageUrl = data['next'];
      loading = false;
    } else {
      loading = false;
      nextPageUrl = null;
      results.clear();
    }
  }

  setUp(() {
    mockHttpClient = MockClient();
    mockStorage = MockFlutterSecureStorage();
    results = [];
    nextPageUrl = null;
    loading = false;
  });

  group('Search Users API Tests', () {
    test('should populate results when API returns 200', () async {
      final query = "john";

      when(mockStorage.read(key: 'token')).thenAnswer((_) async => 'mockToken');

      when(mockHttpClient.get(
        Uri.parse("https://mockapi.test/api/social/search-users/?search=$query"),
        headers: anyNamed('headers'),
      )).thenAnswer(
        (_) async => http.Response(
          jsonEncode({
            "results": [
              {"id": 1, "username": "john_doe"},
              {"id": 2, "username": "john_smith"},
            ],
            "next": null,
          }),
          200,
        ),
      );

      await searchUsersFunction(query, client: mockHttpClient, storage: mockStorage);

      expect(loading, false);
      expect(results.length, 2);
      expect(results[0]['username'], 'john_doe');
      expect(nextPageUrl, null);
    });

    test('should clear results when API returns error', () async {
      final query = "invalid";

      when(mockStorage.read(key: 'token')).thenAnswer((_) async => 'mockToken');

      when(mockHttpClient.get(
        Uri.parse("https://mockapi.test/api/social/search-users/?search=$query"),
        headers: anyNamed('headers'),
      )).thenAnswer((_) async => http.Response('Error', 400));

      // Pré-remplir results pour vérifier qu'elles sont bien vidées
      results = [{"id": 99, "username": "temp"}];
      nextPageUrl = "some_url";

      await searchUsersFunction(query, client: mockHttpClient, storage: mockStorage);

      expect(loading, false);
      expect(results.isEmpty, true);
      expect(nextPageUrl, null);
    });
  });
}
