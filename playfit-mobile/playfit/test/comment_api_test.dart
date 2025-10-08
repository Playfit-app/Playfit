import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

import 'comment_api_test.mocks.dart';

// Génération des mocks
@GenerateMocks([http.Client, FlutterSecureStorage])
void main() {
  late MockClient mockHttpClient;
  late MockFlutterSecureStorage mockStorage;
  late TextEditingController commentController;
  late Map<String, dynamic> post;

  // Version testable de _comment
  Future<void> commentFunction(
      {required Map<String, dynamic> post,
      required TextEditingController controller,
      required http.Client client,
      required FlutterSecureStorage storage}) async {
    final content = controller.text.trim();

    if (content.isEmpty) return;

    final newComment = {
      "id": -1,
      "content": content,
      "user": {"id": 0, "username": "Me"},
      "created_at": DateTime.now().toIso8601String(),
    };

    // Ajout local immédiat
    post['comments'].insert(0, newComment);
    controller.clear();

    final url =
        Uri.parse("https://mockapi.test/api/social/posts/${post['id']}/comment/");
    final token = await storage.read(key: "token");

    final response = await client.post(
      url,
      headers: {"Authorization": "Token $token"},
      body: {"post": post['id'].toString(), "content": content},
    );

    if (response.statusCode == 201) {
      final data = jsonDecode(response.body);
      final serverComment = {
        "id": data['id'],
        "content": content,
        "user": {
          "id": data['user']['id'],
          "username": data['user']['username']
        },
        "created_at": data['created_at'],
      };

      // Mise à jour du commentaire avec l’ID serveur
      post['comments'].removeWhere((c) => c['id'] == -1);
      post['comments'].insert(0, serverComment);
    } else {
      post['comments'].remove(newComment);
    }
  }

  setUp(() {
    mockHttpClient = MockClient();
    mockStorage = MockFlutterSecureStorage();
    commentController = TextEditingController();
    post = {
      "id": 123,
      "comments": [],
    };
  });

  group('Comment API Tests', () {
    test('should add comment successfully when server returns 201', () async {
      // Arrange
      commentController.text = "Hello world!";
      when(mockStorage.read(key: 'token')).thenAnswer((_) async => 'mockToken');
      when(mockHttpClient.post(
        Uri.parse('https://mockapi.test/api/social/posts/123/comment/'),
        headers: anyNamed('headers'),
        body: anyNamed('body'),
      )).thenAnswer((_) async => http.Response(jsonEncode({
            "id": 1,
            "content": "Hello world!",
            "user": {"id": 1, "username": "Me"},
            "created_at": DateTime.now().toIso8601String()
          }), 201));

      // Act
      await commentFunction(
          post: post,
          controller: commentController,
          client: mockHttpClient,
          storage: mockStorage);

      // Assert
      expect(post['comments'].length, 1);
      expect(post['comments'][0]['id'], 1);
      expect(post['comments'][0]['content'], 'Hello world!');
      expect(commentController.text, '');
    });

    test('should remove temporary comment if server returns error', () async {
      // Arrange
      commentController.text = "Hello error!";
      when(mockStorage.read(key: 'token')).thenAnswer((_) async => 'mockToken');
      when(mockHttpClient.post(
        Uri.parse('https://mockapi.test/api/social/posts/123/comment/'),
        headers: anyNamed('headers'),
        body: anyNamed('body'),
      )).thenAnswer((_) async => http.Response('Error', 400));

      // Act
      await commentFunction(
          post: post,
          controller: commentController,
          client: mockHttpClient,
          storage: mockStorage);

      // Assert
      expect(post['comments'].length, 0);
      expect(commentController.text, '');
    });

    test('should do nothing if comment is empty', () async {
      // Arrange
      commentController.text = "   ";

      // Act
      await commentFunction(
          post: post,
          controller: commentController,
          client: mockHttpClient,
          storage: mockStorage);

      // Assert
      expect(post['comments'].length, 0);
      expect(commentController.text, "   "); // still unchanged
    });
  });
}
