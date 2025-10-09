import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

import 'delete_comment_api_test.mocks.dart';

@GenerateMocks([http.Client, FlutterSecureStorage])
void main() {
  late MockClient mockHttpClient;
  late MockFlutterSecureStorage mockStorage;
  late Map<String, dynamic> post;

  Future<void> deleteCommentFunction({
    required Map<String, dynamic> post,
    required int commentId,
    required http.Client client,
    required FlutterSecureStorage storage,
  }) async {
    final commentToDelete = post['comments'].firstWhere(
      (comment) => comment['id'] == commentId,
      orElse: () => <String, Object>{}, // type correct
    );

    if (commentToDelete.isEmpty) return;

    final index = post['comments'].indexOf(commentToDelete);
    if (index == -1) return;

    post['comments'].remove(commentToDelete);

    final url = Uri.parse('https://mockapi.test/api/social/comments/$commentId/delete/');
    final token = await storage.read(key: "token");

    final response = await client.delete(
      url,
      headers: {"Authorization": "Token $token"},
      body: {"comment": commentId.toString()},
    );

    if (response.statusCode != 204) {
      post['comments'].insert(index, commentToDelete);
    }
  }

  setUp(() {
    mockHttpClient = MockClient();
    mockStorage = MockFlutterSecureStorage();
    post = {
      "id": 1,
      "comments": [
        {"id": 101, "content": "First comment"},
        {"id": 102, "content": "Second comment"},
      ]
    };
  });

  group('Delete Comment API Tests', () {
    test('should delete comment successfully when server returns 204', () async {
      when(mockStorage.read(key: 'token')).thenAnswer((_) async => 'mockToken');
      when(mockHttpClient.delete(
        Uri.parse('https://mockapi.test/api/social/comments/101/delete/'),
        headers: anyNamed('headers'),
        body: anyNamed('body'),
      )).thenAnswer((_) async => http.Response('', 204));

      await deleteCommentFunction(
        post: post,
        commentId: 101,
        client: mockHttpClient,
        storage: mockStorage,
      );

      expect(post['comments'].length, 1);
      expect(post['comments'][0]['id'], 102);
    });

    test('should restore comment if server returns error', () async {
      when(mockStorage.read(key: 'token')).thenAnswer((_) async => 'mockToken');
      when(mockHttpClient.delete(
        Uri.parse('https://mockapi.test/api/social/comments/101/delete/'),
        headers: anyNamed('headers'),
        body: anyNamed('body'),
      )).thenAnswer((_) async => http.Response('Error', 400));

      await deleteCommentFunction(
        post: post,
        commentId: 101,
        client: mockHttpClient,
        storage: mockStorage,
      );

      expect(post['comments'].length, 2);
      expect(post['comments'][0]['id'], 101);
    });

    test('should do nothing if commentId does not exist', () async {
      final initialComments = List.from(post['comments']);

      await deleteCommentFunction(
        post: post,
        commentId: 999,
        client: mockHttpClient,
        storage: mockStorage,
      );

      expect(post['comments'], initialComments);
    });
  });
}
