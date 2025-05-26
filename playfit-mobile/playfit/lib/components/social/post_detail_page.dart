import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:playfit/components/social/post_card/post_card.dart';

class PostDetailPage extends StatefulWidget {
  final int postId;
  final bool isOwner;

  const PostDetailPage({
    super.key,
    required this.postId,
    this.isOwner = false,
  });

  @override
  State<PostDetailPage> createState() => _PostDetailPageState();
}

class _PostDetailPageState extends State<PostDetailPage> {
  Map<String, dynamic>? post;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetchPost();
  }

  Future<void> _fetchPost() async {
    final url = Uri.parse(
        "${dotenv.env['SERVER_BASE_URL']}/api/social/posts/${widget.postId}/");
    final token = await const FlutterSecureStorage().read(key: 'token');

    final response = await http.get(
      url,
      headers: {
        "Authorization": "Token $token",
        "Content-Type": "application/json",
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        post = data;
        _loading = false;
      });
    } else {
      debugPrint("Failed to load post");
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Post Details")),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : post == null
              ? const Center(child: Text("Post not found"))
              : SingleChildScrollView(
                  child: PostCard(
                    post: post!,
                    showAllComments: true,
                    isOwner: widget.isOwner,
                  ),
                ),
    );
  }
}
