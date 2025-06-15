import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:timeago/timeago.dart' as timeago;
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:playfit/profile_page.dart';
import 'package:playfit/i18n/strings.g.dart';

class PostCard extends StatefulWidget {
  final Map<String, dynamic> post;
  final bool showAllComments;
  final bool isOwner;

  const PostCard({
    super.key,
    required this.post,
    this.showAllComments = false,
    this.isOwner = false,
  });

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  final FlutterSecureStorage storage = const FlutterSecureStorage();
  final TextEditingController _commentController = TextEditingController();
  bool _isSubmitting = false;

  Future<void> _like() async {
    setState(() {
      widget.post['is_liked'] = true;
      widget.post['nb_likes'] += 1;
    });

    final url = Uri.parse(
        "${dotenv.env['SERVER_BASE_URL']}/api/social/posts/${widget.post['id']}/like/");
    final token = await storage.read(key: "token");
    final response = await http.post(
      url,
      headers: {
        "Authorization": "Token $token",
      },
      body: {
        "post": widget.post['id'].toString(),
      },
    );

    if (response.statusCode == 201) {
    } else {
      setState(() {
        widget.post['is_liked'] = false;
        widget.post['nb_likes'] -= 1;
      });
    }
  }

  Future<void> _unlike() async {
    setState(() {
      widget.post['is_liked'] = false;
      widget.post['nb_likes'] -= 1;
    });

    final url = Uri.parse(
        "${dotenv.env['SERVER_BASE_URL']}/api/social/posts/${widget.post['id']}/unlike/");
    final token = await storage.read(key: "token");
    final response = await http.delete(
      url,
      headers: {
        "Authorization": "Token $token",
      },
      body: {
        "post": widget.post['id'].toString(),
      },
    );

    if (response.statusCode == 204) {
    } else {
      setState(() {
        widget.post['is_liked'] = true;
        widget.post['nb_likes'] += 1;
      });
    }
  }

  Future<void> _comment() async {
    final content = _commentController.text.trim();

    if (content.isEmpty) return;
    setState(() => _isSubmitting = true);

    final newComment = {
      "id": -1,
      "content": content,
      "user": {
        "id": 0,
        "username": "Me",
      },
      "created_at": DateTime.now().toIso8601String(),
    };

    setState(() {
      widget.post['comments'].insert(0, newComment);
      _commentController.clear();
    });

    final url = Uri.parse(
        "${dotenv.env['SERVER_BASE_URL']}/api/social/posts/${widget.post['id']}/comment/");
    final token = await storage.read(key: "token");
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
        widget.post['comments'].removeWhere((comment) => comment['id'] == -1);
        widget.post['comments'].insert(0, newComment);
        _commentController.clear();
        _isSubmitting = false;
      });
    } else {
      setState(() {
        widget.post['comments'].remove(newComment);
        _commentController.clear();
        _isSubmitting = false;
      });
    }
  }

  Future<void> _deleteComment(int commentId) async {
    final commentToDelete = widget.post['comments']
        .firstWhere((comment) => comment['id'] == commentId);
    if (commentToDelete == null) return;
    final index = widget.post['comments'].indexOf(commentToDelete);
    if (index == -1) return;
    setState(() {
      widget.post['comments'].remove(commentToDelete);
    });

    final url = Uri.parse(
        "${dotenv.env['SERVER_BASE_URL']}/api/social/comments/$commentId/delete/");
    final token = await storage.read(key: "token");
    final response = await http.delete(
      url,
      headers: {
        "Authorization": "Token $token",
      },
      body: {
        "comment": commentId.toString(),
      },
    );

    if (response.statusCode == 204) {
    } else {
      setState(() {
        widget.post['comments'].insert(index, commentToDelete);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = widget.post['user'];
    final comments = widget.post['comments'] ?? [];
    final displayComments =
        widget.showAllComments ? comments : comments.take(3).toList();

    return Card(
      margin: const EdgeInsets.all(12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.post['media'] != null)
            ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(16)),
              child: Center(
                child: Image.network(
                  widget.post['media'],
                  fit: BoxFit.cover,
                  width: widget.showAllComments
                      ? MediaQuery.of(context).size.width - 24
                      : 150,
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(user['username'],
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                Row(
                  children: [
                    widget.post['is_liked']
                        ? IconButton(
                            icon: const Icon(Icons.favorite, color: Colors.red),
                            onPressed: _unlike,
                          )
                        : IconButton(
                            icon: const Icon(Icons.favorite_border),
                            onPressed: _like,
                          ),
                    const SizedBox(width: 4),
                    Text('${widget.post['nb_likes']}'),
                  ],
                ),
              ],
            ),
          ),
          if (widget.post['content'] != null &&
              widget.post['content'].toString().isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text(widget.post['content']),
            ),
          const SizedBox(height: 12),
          if (widget.showAllComments) ...[
            Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: TextField(
                      controller: _commentController,
                      decoration: const InputDecoration(
                        hintText: "Add a comment...",
                        border: OutlineInputBorder(),
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
                ),
                const SizedBox(width: 8),
                _isSubmitting
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(strokeWidth: 2))
                    : IconButton(
                        icon: const Icon(Icons.send),
                        onPressed: _comment,
                      ),
              ],
            ),
            const SizedBox(height: 12),
          ],
          if (comments.isNotEmpty) ...[
            const Divider(height: 1, color: Colors.grey),
            const SizedBox(height: 12),
          ],
          ...displayComments.map(
            (comment) {
              final userId = comment['user']['id'];
              final username = comment['user']['username'];
              final content = comment['content'];
              final createdAt = DateTime.parse(comment['created_at']);
              final timeAgo = timeago.format(createdAt, locale: 'en_short');

              return Padding(
                padding: const EdgeInsets.only(left: 12, right: 12, bottom: 2),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () async {
                            if (userId == await storage.read(key: 'userId')) {
                              return;
                            } else {
                              if (!mounted) return;
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      ProfilePage(userId: userId),
                                ),
                              );
                            }
                          },
                          child: Text(
                            username,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            content,
                            style: const TextStyle(fontSize: 14),
                          ),
                        ),
                        PopupMenuButton<String>(
                          icon: const Icon(Icons.more_vert, size: 18),
                          onSelected: (value) {
                            if (value == 'delete') {
                              _deleteComment(comment['id']);
                            } else if (value == 'report') {
                              debugPrint('Report ${comment['id']}');
                            }
                          },
                          itemBuilder: (context) => [
                            if (widget.isOwner)
                              PopupMenuItem<String>(
                                value: 'delete',
                                child: Text(t.social.post_delete),
                              )
                            else
                              PopupMenuItem<String>(
                                value: 'report',
                                child: Text(t.social.post_report),
                              ),
                          ],
                        )
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 12),
                      child: Text(
                        timeAgo,
                        style:
                            const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}
