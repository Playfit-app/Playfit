import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:playfit/components/social/post_detail_page.dart';
import 'package:playfit/components/social/post_card/post_card.dart';
import 'package:playfit/i18n/strings.g.dart';

class PostFeed extends StatefulWidget {
  const PostFeed({super.key});

  @override
  State<PostFeed> createState() => _PostFeedState();
}

class _PostFeedState extends State<PostFeed> {
  final FlutterSecureStorage storage = const FlutterSecureStorage();
  List<Map<String, dynamic>> _posts = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadPosts();
  }

  Future<void> _loadPosts() async {
    setState(() {
      _loading = true;
    });
    final token = await storage.read(key: 'token');
    final url = Uri.parse("${dotenv.env['SERVER_BASE_URL']}/api/social/posts/");

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
        _posts = List<Map<String, dynamic>>.from(data);
        _loading = false;
      });
    } else {
      // Handle error
      print("Failed to load posts: ${response.statusCode}");
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_posts.isEmpty) {
      return Center(child: Text(t.social.no_posts_available));
    }

    return ListView.builder(
      itemCount: _posts.length,
      itemBuilder: (context, index) {
        final post = _posts[index];
        final userIdFuture = storage.read(key: 'userId');

        return FutureBuilder<String?>(
          future: userIdFuture,
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const SizedBox.shrink();
            }

            final bool isMine = post['user']['id'].toString() == snapshot.data;

            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        PostDetailPage(postId: post['id'], isOwner: isMine),
                  ),
                );
              },
              child: PostCard(post: post, isOwner: isMine),
            );
          },
        );
      },
    );
  }
}
