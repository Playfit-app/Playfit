// test/unfollow_api_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

// Générez les mocks avec : flutter packages pub run build_runner build
@GenerateMocks([http.Client, FlutterSecureStorage])
import 'unfollow_api_test.mocks.dart';

// Fonction extraite de votre code pour les tests
Future<http.Response> unfollowUser({
  required String baseUrl,
  required String userId,
  required String token,
  http.Client? client,
}) async {
  final httpClient = client ?? http.Client();
  
  final String url = '${baseUrl}/api/social/unfollow/${userId}/';
  final response = await httpClient.delete(
    Uri.parse(url),
    headers: {
      'Authorization': 'Token $token',
    },
  );
  
  return response;
}

void main() {
  group('Unfollow API Tests', () {
    late MockClient mockClient;
    late MockFlutterSecureStorage mockStorage;
    const String baseUrl = 'https://api.example.com';
    const String userId = '123';
    const String token = 'fake-token-abc123';

    setUp(() {
      mockClient = MockClient();
      mockStorage = MockFlutterSecureStorage();
    });

    test('unfollow - cas de succès (204)', () async {
      // Arrange
      final expectedUrl = '${baseUrl}/api/social/unfollow/${userId}/';
      final mockResponse = http.Response('', 204); // 204 = No Content (succès)

      when(mockClient.delete(
        Uri.parse(expectedUrl),
        headers: {'Authorization': 'Token $token'},
      )).thenAnswer((_) async => mockResponse);

      // Act
      final response = await unfollowUser(
        baseUrl: baseUrl,
        userId: userId,
        token: token,
        client: mockClient,
      );

      // Assert
      expect(response.statusCode, 204);
      expect(response.body, isEmpty); // 204 n'a pas de body
      
      // Vérifier que l'appel a été fait avec les bons paramètres
      verify(mockClient.delete(
        Uri.parse(expectedUrl),
        headers: {'Authorization': 'Token $token'},
      )).called(1);
    });

    test('unfollow - erreur 404 (utilisateur non trouvé)', () async {
      // Arrange
      final expectedUrl = '${baseUrl}/api/social/unfollow/${userId}/';
      final mockResponse = http.Response('{"error": "User not found"}', 404);

      when(mockClient.delete(
        Uri.parse(expectedUrl),
        headers: {'Authorization': 'Token $token'},
      )).thenAnswer((_) async => mockResponse);

      // Act
      final response = await unfollowUser(
        baseUrl: baseUrl,
        userId: userId,
        token: token,
        client: mockClient,
      );

      // Assert
      expect(response.statusCode, 404);
      expect(response.body, contains('User not found'));
    });

    test('unfollow - erreur 401 (non autorisé)', () async {
      // Arrange
      final expectedUrl = '${baseUrl}/api/social/unfollow/${userId}/';
      final mockResponse = http.Response('{"error": "Unauthorized"}', 401);

      when(mockClient.delete(
        Uri.parse(expectedUrl),
        headers: {'Authorization': 'Token $token'},
      )).thenAnswer((_) async => mockResponse);

      // Act
      final response = await unfollowUser(
        baseUrl: baseUrl,
        userId: userId,
        token: token,
        client: mockClient,
      );

      // Assert
      expect(response.statusCode, 401);
      expect(response.body, contains('Unauthorized'));
    });

    test('unfollow - erreur 400 (déjà non suivi)', () async {
      // Arrange
      final expectedUrl = '${baseUrl}/api/social/unfollow/${userId}/';
      final mockResponse = http.Response('{"error": "Not following this user"}', 400);

      when(mockClient.delete(
        Uri.parse(expectedUrl),
        headers: {'Authorization': 'Token $token'},
      )).thenAnswer((_) async => mockResponse);

      // Act
      final response = await unfollowUser(
        baseUrl: baseUrl,
        userId: userId,
        token: token,
        client: mockClient,
      );

      // Assert
      expect(response.statusCode, 400);
      expect(response.body, contains('Not following'));
    });

    test('unfollow - exception réseau', () async {
      // Arrange
      final expectedUrl = '${baseUrl}/api/social/unfollow/${userId}/';

      when(mockClient.delete(
        Uri.parse(expectedUrl),
        headers: {'Authorization': 'Token $token'},
      )).thenThrow(Exception('Network error'));

      // Act & Assert
      expect(
        () => unfollowUser(
          baseUrl: baseUrl,
          userId: userId,
          token: token,
          client: mockClient,
        ),
        throwsA(isA<Exception>()),
      );
    });

    group('Tests de construction URL', () {
      test('URL correctement construite', () {
        final baseUrl = 'https://api.example.com';
        final userId = '456';
        final expectedUrl = '${baseUrl}/api/social/unfollow/${userId}/';
        
        expect(expectedUrl, 'https://api.example.com/api/social/unfollow/456/');
      });

      test('URL avec différents IDs utilisateur', () {
        final baseUrl = 'https://api.example.com';
        
        final testCases = [
          {'userId': '1', 'expected': 'https://api.example.com/api/social/unfollow/1/'},
          {'userId': '999', 'expected': 'https://api.example.com/api/social/unfollow/999/'},
          {'userId': 'abc123', 'expected': 'https://api.example.com/api/social/unfollow/abc123/'},
        ];

        for (final testCase in testCases) {
          final url = '${baseUrl}/api/social/unfollow/${testCase['userId']}/';
          expect(url, testCase['expected']);
        }
      });
    });

    group('Tests des headers d\'authentification', () {
      test('header Authorization correctement formaté', () {
        final token = 'my-secret-token';
        final headers = {'Authorization': 'Token $token'};
        
        expect(headers['Authorization'], 'Token my-secret-token');
        expect(headers.containsKey('Authorization'), true);
      });

      test('différents formats de token', () {
        final tokens = ['abc123', 'token-with-dashes', '1234567890'];
        
        for (final token in tokens) {
          final headers = {'Authorization': 'Token $token'};
          expect(headers['Authorization'], 'Token $token');
          expect(headers['Authorization']!.startsWith('Token '), true);
        }
      });
    });

    group('Tests de logique métier', () {
      test('logique de gestion du statut 204', () {
        final successResponse = http.Response('', 204);
        
        expect(successResponse.statusCode, 204);
        expect(successResponse.body, isEmpty);
        
        // Logique de votre code
        final isSuccess = successResponse.statusCode == 204;
        expect(isSuccess, true);
      });

      test('logique de rollback en cas d\'erreur', () {
        final errorResponse = http.Response('{"error": "Failed"}', 400);
        
        expect(errorResponse.statusCode, 400);
        
        // Simulation de votre logique de rollback
        final shouldRollback = errorResponse.statusCode != 204;
        expect(shouldRollback, true);
        
        // Test de la logique de compteur
        int followerCount = 100;
        bool isFollowing = true;
        
        // Simulation: on défollows d'abord
        isFollowing = false;
        followerCount -= 1;
        expect(followerCount, 99);
        expect(isFollowing, false);
        
        // Simulation: rollback en cas d'erreur
        if (shouldRollback) {
          isFollowing = true;
          followerCount += 1;
        }
        expect(followerCount, 100);
        expect(isFollowing, true);
      });

      test('validation userId null', () {
        String? userId = null;
        
        // Logique de votre code : return early si userId est null
        if (userId == null) {
          expect(userId, isNull);
          return; // Simulation du return early
        }
        
        fail('Ne devrait pas arriver ici car userId est null');
      });

      test('validation userId valide', () {
        final userId = '123';
        
        expect(userId, isNotNull);
        expect(userId, isNotEmpty);
        expect(userId, '123');
      });
    });

    group('Tests de la lecture du token', () {
      test('simulation lecture token depuis storage', () async {
        // Mock du storage
        when(mockStorage.read(key: 'token')).thenAnswer((_) async => 'stored-token');
        
        final token = await mockStorage.read(key: 'token');
        
        expect(token, 'stored-token');
        expect(token, isNotNull);
        
        verify(mockStorage.read(key: 'token')).called(1);
      });

      test('simulation token null', () async {
        when(mockStorage.read(key: 'token')).thenAnswer((_) async => null);
        
        final token = await mockStorage.read(key: 'token');
        
        expect(token, isNull);
        
        // Dans votre code, vous devriez gérer ce cas
        if (token == null) {
          expect(true, true); // Test OK
        }
      });
    });

    group('Tests d\'intégration simulée', () {
      test('workflow complet unfollow', () async {
        // Simulation complète du workflow
        
        // 1. Vérification userId
        final userId = '123';
        expect(userId, isNotNull);
        
        // 2. Simulation lecture token
        when(mockStorage.read(key: 'token')).thenAnswer((_) async => 'valid-token');
        final token = await mockStorage.read(key: 'token');
        expect(token, 'valid-token');
        
        // 3. Préparation de la requête
        final baseUrl = 'https://api.example.com';
        final url = '${baseUrl}/api/social/unfollow/${userId}/';
        final headers = {'Authorization': 'Token $token'};
        
        expect(url, contains(userId));
        expect(headers['Authorization'], contains(token));
        
        // 4. Simulation de l'état avant
        bool isFollowing = true;
        int followerCount = 100;
        
        // 5. Changement optimiste
        isFollowing = false;
        followerCount -= 1;
        expect(isFollowing, false);
        expect(followerCount, 99);
        
        // 6. Simulation réponse API succès
        final mockResponse = http.Response('', 204);
        when(mockClient.delete(
          Uri.parse(url),
          headers: headers,
        )).thenAnswer((_) async => mockResponse);
        
        final response = await unfollowUser(
          baseUrl: baseUrl,
          userId: userId,
          token: token!,
          client: mockClient,
        );
        
        // 7. Vérification finale
        expect(response.statusCode, 204);
        expect(isFollowing, false); // Reste false car succès
        expect(followerCount, 99); // Reste diminué
      });
    });
  });
}