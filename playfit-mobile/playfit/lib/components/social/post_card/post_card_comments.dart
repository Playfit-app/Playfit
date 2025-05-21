import 'package:http/http.dart' as http;
import 'package:timeago/timeago.dart' as timeago;
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:playfit/profile_page.dart';

class PostCardComments extends StatefulWidget {
  final FlutterSecureStorage storage;
  final Map<String, dynamic> post;
  final bool showAllComments;
  final bool isOwner;

  const PostCardComments({
    super.key,
    required this.storage,
    required this.post,
    required this.showAllComments,
    required this.isOwner,
  });

  @override
  State<PostCardComments> createState() => _PostCardCommentsState();
}

class _PostCardCommentsState extends State<PostCardComments> {
  Future<void> _deleteComment(int commentId) async {
    final url = Uri.parse(
        "${dotenv.env['SERVER_BASE_URL']}/api/social/comments/$commentId/delete/");
    final token = await widget.storage.read(key: "token");
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
      setState(() {
        widget.post['comments']
            .removeWhere((comment) => comment['id'] == commentId);
      });
    } else {
      print("Failed to delete comment: ${response.statusCode}");
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final comments = widget.post['comments'] ?? [];
    final displayComments =
        widget.showAllComments ? comments : comments.take(3).toList();

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFFE9CA),
      ),
      child: Column(
        children: [
          ...displayComments.map(
            (comment) {
              final userId = comment['user']['id'];
              final username = comment['user']['username'];
              final content = comment['content'];
              final createdAt = DateTime.parse(comment['created_at']);
              final timeAgo = timeago.format(createdAt, locale: 'en_short');
      
              return Padding(
                padding: EdgeInsets.only(
                    left: screenWidth * 0.03, right: screenWidth * 0.03),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () async {
                            if (userId ==
                                await widget.storage.read(key: 'userId')) {
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
                        SizedBox(width: screenWidth * 0.02),
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
                              const PopupMenuItem<String>(
                                value: 'delete',
                                child: Text('Delete'),
                              )
                            else
                              const PopupMenuItem<String>(
                                value: 'report',
                                child: Text('Report'),
                              ),
                          ],
                        )
                      ],
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: screenWidth * 0.03),
                      child: Text(
                        timeAgo,
                        style:
                            const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ),
                    if (comment != displayComments.last)
                      Padding(
                        padding: EdgeInsets.only(
                          top: screenHeight * 0.02,
                          left: screenWidth * 0.07,
                          right: screenWidth * 0.07,
                        ),
                        child: const Divider(
                          height: 1,
                          color: Color(0xFFE57207),
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
