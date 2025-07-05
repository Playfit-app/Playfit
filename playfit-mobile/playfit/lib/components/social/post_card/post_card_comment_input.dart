import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class PostCardCommentInput extends StatefulWidget {
  final FlutterSecureStorage storage;
  final Map<String, dynamic> post;

  const PostCardCommentInput({
    super.key,
    required this.storage,
    required this.post,
  });

  @override
  State<PostCardCommentInput> createState() => _PostCardCommentInputState();
}


/// This class manages the comment input field, submission state, and interaction
/// with the backend API to post new comments. It updates the UI to reflect the
/// submission process and adds new comments to the post's comment list upon success.
///
/// The build method renders a styled input area with a text field and a send button.
/// While submitting, a loading indicator is shown in place of the send button.
class _PostCardCommentInputState extends State<PostCardCommentInput> {
  final TextEditingController _commentController = TextEditingController();
  bool _isSubmitting = false;

  Future<void> _comment() async {
    final content = _commentController.text.trim();

    if (content.isEmpty) return;
    setState(() => _isSubmitting = true);
    final url = Uri.parse(
        "${dotenv.env['SERVER_BASE_URL']}/api/social/posts/${widget.post['id']}/comment/");
    final token = await widget.storage.read(key: "token");
    final response = await http.post(
      url,
      headers: {
        "Authorization": "Token $token",
      },
      body: {
        "post": widget.post['id'].toString(),
        "content": content,
      },
    );

    if (response.statusCode == 201) {
      final data = jsonDecode(response.body);
      final newComment = {
        "id": data['id'],
        "content": content,
        "user": {
          "id": data['user']['id'],
          "username": data['user']['username'],
        },
        "created_at": data['created_at'],
      };

      setState(() {
        widget.post['comments'].insert(0, newComment);
        _commentController.clear();
        _isSubmitting = false;
      });
    } else {
      print("Failed to comment: ${response.statusCode}");
      setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Container(
      color: const Color(0xFFFFE9CA),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: screenWidth * 0.03,
          vertical: screenHeight * 0.01,
        ),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _commentController,
                    decoration: const InputDecoration(
                      hintText: "Add a comment...",
                      border: InputBorder.none,
                    ),
                    onSubmitted: (value) {
                      if (!_isSubmitting) _comment();
                    },
                    onChanged: (value) {
                      if (value.isEmpty) {
                        setState(() => _isSubmitting = false);
                      }
                    },
                    enabled: !_isSubmitting,
                  ),
                ),
                const SizedBox(width: 8),
                _isSubmitting
                    ? SizedBox(
                        width: screenHeight * 0.03,
                        height: screenHeight * 0.03,
                        child: CircularProgressIndicator(strokeWidth: 2))
                    : IconButton(
                        icon: const Icon(Icons.send),
                        onPressed: _comment,
                      ),
              ],
            ),
            const Divider(height: 1, color: const Color(0xFFE57207)),
          ],
        ),
      ),
    );
  }
}
